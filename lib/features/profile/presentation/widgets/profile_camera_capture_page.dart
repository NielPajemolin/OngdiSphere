import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:ongdisphere/core/theme/theme.dart';

class ProfileCameraCapturePage extends StatefulWidget {
  const ProfileCameraCapturePage({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<ProfileCameraCapturePage> createState() =>
      _ProfileCameraCapturePageState();
}

class _ProfileCameraCapturePageState extends State<ProfileCameraCapturePage> {
  CameraController? _controller;
  File? _capturedImage;
  bool _isReady = false;
  bool _isCapturing = false;
  bool _isSwitchingCamera = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  Offset? _focusIndicatorPosition;
  bool _showFocusIndicator = false;

  static const Duration _cameraInitTimeout = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera available on this device');
      }

      final frontIndex = widget.cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _selectedCameraIndex = frontIndex >= 0 ? frontIndex : 0;
      await _initializeController(_selectedCameraIndex);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open camera: $e')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _initializeController(int cameraIndex) async {
    final controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize().timeout(_cameraInitTimeout);
    await controller.setFlashMode(_flashMode);
    final minZoom = await controller.getMinZoomLevel();
    final maxZoom = await controller.getMaxZoomLevel();
    await controller.setZoomLevel(minZoom);

    if (!mounted) {
      await controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _isReady = true;
      _capturedImage = null;
      _minZoom = minZoom;
      _maxZoom = maxZoom;
      _currentZoom = minZoom;
      _baseZoom = minZoom;
    });
  }

  Future<void> _disposeActiveController() async {
    final activeController = _controller;
    _controller = null;
    if (mounted) {
      setState(() => _isReady = false);
    }
    await activeController?.dispose();
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2 ||
        _isSwitchingCamera ||
        _isCapturing ||
        _capturedImage != null) {
      return;
    }

    final previousCameraIndex = _selectedCameraIndex;

    setState(() {
      _isSwitchingCamera = true;
      _isReady = false;
    });

    try {
      final nextCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
      await _disposeActiveController();
      _selectedCameraIndex = nextCameraIndex;
      await _initializeController(nextCameraIndex);
    } catch (e) {
      _selectedCameraIndex = previousCameraIndex;

      try {
        await _disposeActiveController();
        await _initializeController(previousCameraIndex);
      } catch (_) {
        // Keep primary error message from the original failure.
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to switch camera: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  Future<void> _toggleFlashMode() async {
    final controller = _controller;
    if (controller == null || !_isReady || _isCapturing || _capturedImage != null) {
      return;
    }

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      _ => FlashMode.off,
    };

    try {
      await controller.setFlashMode(nextMode);
      if (mounted) {
        setState(() => _flashMode = nextMode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Flash not available: $e')),
        );
      }
    }
  }

  IconData _flashIconForMode(FlashMode mode) {
    return switch (mode) {
      FlashMode.auto => Icons.flash_auto_rounded,
      FlashMode.always || FlashMode.torch => Icons.flash_on_rounded,
      _ => Icons.flash_off_rounded,
    };
  }

  String _flashLabelForMode(FlashMode mode) {
    return switch (mode) {
      FlashMode.auto => 'Auto',
      FlashMode.always || FlashMode.torch => 'On',
      _ => 'Off',
    };
  }

  bool get _isFrontLensActive {
    if (widget.cameras.isEmpty || _selectedCameraIndex >= widget.cameras.length) {
      return false;
    }
    return widget.cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  Future<File> _normalizeCapturedOutput(XFile capture) async {
    final original = File(capture.path);
    if (!_isFrontLensActive) {
      return original;
    }

    try {
      final sourceBytes = await original.readAsBytes();
      final decodedImage = img.decodeImage(sourceBytes);
      if (decodedImage == null) {
        return original;
      }

      final unmirrored = img.flipHorizontal(decodedImage);
      final normalizedPath = '${capture.path}_nomirror.jpg';
      final normalizedBytes = img.encodeJpg(unmirrored, quality: 92);
      final normalizedFile = File(normalizedPath);
      await normalizedFile.writeAsBytes(normalizedBytes, flush: true);
      return normalizedFile;
    } catch (_) {
      return original;
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (!_isReady || controller == null || _isCapturing || _capturedImage != null) {
      return;
    }

    setState(() => _isCapturing = true);
    try {
      final file = await controller.takePicture();
      final normalizedFile = await _normalizeCapturedOutput(file);
      if (!mounted) {
        return;
      }
      setState(() {
        _capturedImage = normalizedFile;
        _isCapturing = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isCapturing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    }
  }

  void _useCapturedPhoto() {
    final image = _capturedImage;
    if (image == null) {
      return;
    }
    Navigator.of(context).pop(image);
  }

  void _retakePhoto() {
    if (_isCapturing) {
      return;
    }
    setState(() => _capturedImage = null);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  Future<void> _onScaleUpdate(ScaleUpdateDetails details) async {
    if (details.pointerCount < 2) {
      return;
    }

    final controller = _controller;
    if (!_isReady || controller == null || _capturedImage != null) {
      return;
    }

    final nextZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom).toDouble();
    if ((nextZoom - _currentZoom).abs() < 0.02) {
      return;
    }

    await _setZoomLevel(nextZoom);
  }

  Future<void> _setZoomLevel(double value) async {
    final controller = _controller;
    if (!_isReady || controller == null || _capturedImage != null) {
      return;
    }

    final nextZoom = value.clamp(_minZoom, _maxZoom).toDouble();

    try {
      await controller.setZoomLevel(nextZoom);
      if (mounted) {
        setState(() => _currentZoom = nextZoom);
      }
    } catch (_) {
      // Ignore transient zoom update failures.
    }
  }

  Future<void> _handleTapToFocus(Offset localPosition, Size previewBounds) async {
    final controller = _controller;
    if (!_isReady || controller == null || _capturedImage != null) {
      return;
    }

    final width = previewBounds.width;
    final height = previewBounds.height;
    if (width <= 0 || height <= 0) {
      return;
    }

    final normalizedPoint = Offset(
      (localPosition.dx / width).clamp(0.0, 1.0),
      (localPosition.dy / height).clamp(0.0, 1.0),
    );

    setState(() {
      _focusIndicatorPosition = localPosition;
      _showFocusIndicator = true;
    });

    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(normalizedPoint);
      await controller.setExposurePoint(normalizedPoint);
    } catch (_) {
      // Focus/exposure points are not supported on all devices.
    }

    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _showFocusIndicator = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview(Color loaderColor) {
    final controller = _controller;
    if (!_isReady || controller == null) {
      return Center(
        child: CircularProgressIndicator(color: loaderColor),
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return Center(
        child: CircularProgressIndicator(color: loaderColor),
      );
    }

    // Keep camera aspect ratio correct and crop overflow instead of stretching.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildPreviewLayer(Color loaderColor) {
    if (_capturedImage != null) {
      return Image.file(
        _capturedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _handleTapToFocus(details.localPosition, constraints.biggest);
          },
          onScaleStart: _onScaleStart,
          onScaleUpdate: (details) {
            _onScaleUpdate(details);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCameraPreview(loaderColor),
              if (_showFocusIndicator && _focusIndicatorPosition != null)
                Positioned(
                  left: _focusIndicatorPosition!.dx - 26,
                  top: _focusIndicatorPosition!.dy - 26,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showFocusIndicator ? 1 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 700;

    return Scaffold(
      backgroundColor: colors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildPreviewLayer(colors.secondary),
            ),
            if (_capturedImage == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final shortestSide = constraints.biggest.shortestSide;
                        final guideSize = (shortestSide * 0.62).clamp(210.0, 340.0);
                        return Container(
                          width: guideSize,
                          height: guideSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: colors.surface.withValues(alpha: 0.78),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.18),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.primary.withValues(alpha: 0.45),
                        Colors.transparent,
                        colors.primary.withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CameraActionChip(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: const Color(0xFFFDF8FC),
                    iconColor: colors.tertiaryText,
                    textColor: colors.tertiaryText,
                    borderColor: colors.secondary.withValues(alpha: 0.16),
                  ),
                  Row(
                    children: [
                      _CameraActionChip(
                        icon: _flashIconForMode(_flashMode),
                        label: _flashLabelForMode(_flashMode),
                        onTap: _capturedImage == null ? _toggleFlashMode : null,
                        backgroundColor: const Color(0xFFFDF8FC),
                        iconColor: colors.tertiaryText,
                        textColor: colors.tertiaryText,
                        borderColor: colors.secondary.withValues(alpha: 0.16),
                      ),
                      const SizedBox(width: 8),
                      _CameraActionChip(
                        icon: Icons.cameraswitch_rounded,
                        label: 'Switch',
                        onTap: widget.cameras.length > 1 && !_isSwitchingCamera && _capturedImage == null
                            ? _switchCamera
                            : null,
                        backgroundColor: const Color(0xFFFDF8FC),
                        iconColor: colors.tertiaryText,
                        textColor: colors.tertiaryText,
                        borderColor: colors.secondary.withValues(alpha: 0.16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 30 : 18,
                  8,
                  isTablet ? 30 : 18,
                  isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [Color(0xFFFFFBFD), Color(0xFFF8F1F7)],
                  ),
                  border: Border.all(
                    color: colors.secondary.withValues(alpha: 0.12),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0E000000),
                      blurRadius: 22,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    if (_capturedImage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Preview Photo',
                        style: TextStyle(
                          color: colors.tertiaryText,
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Retake or use this photo',
                        style: TextStyle(
                          color: colors.tertiaryText.withValues(alpha: 0.72),
                          fontSize: isTablet ? 13 : 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else
                      const SizedBox(height: 8),
                    _capturedImage == null
                        ? Column(
                            children: [
                              GestureDetector(
                                onTap: _takePhoto,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  width: isTablet ? 84 : 76,
                                  height: isTablet ? 84 : 76,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colors.primary,
                                        colors.secondary.withValues(alpha: 0.95),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.secondary.withValues(alpha: 0.22),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.surface,
                                      border: Border.all(
                                        color: colors.secondary.withValues(alpha: 0.26),
                                        width: 2,
                                      ),
                                    ),
                                    child: _isCapturing
                                        ? Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: colors.primary,
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt_rounded,
                                            color: colors.primary,
                                            size: isTablet ? 30 : 27,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pinch to zoom  •  Tap to focus',
                                style: TextStyle(
                                  color: colors.tertiaryText.withValues(alpha: 0.62),
                                  fontSize: 11.3,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _retakePhoto,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Retake'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _useCapturedPhoto,
                                  icon: const Icon(Icons.check_circle_outline_rounded),
                                  label: const Text('Use Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraActionChip extends StatelessWidget {
  const _CameraActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.borderColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: isEnabled ? 1 : 0.46,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}