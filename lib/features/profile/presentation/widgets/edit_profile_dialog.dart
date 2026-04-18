import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ongdisphere/features/auth/auth.dart';
import 'package:ongdisphere/features/profile/presentation/widgets/profile_camera_capture_page.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/widgets.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  File? _selectedImage;
  bool _removePhotoRequested = false;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AuthCubit>().currenUser;
    _nameController = TextEditingController(text: currentUser?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 35,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _removePhotoRequested = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _captureWithCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) {
        return;
      }

      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera available on this device')),
        );
        return;
      }

      final File? capturedImage = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (_) => ProfileCameraCapturePage(cameras: cameras),
        ),
      );

      if (!mounted || capturedImage == null) {
        return;
      }

      setState(() {
        _selectedImage = capturedImage;
        _removePhotoRequested = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open in-app camera on this device.'),
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    final colors = AppTheme.colorsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sheetHorizontalPadding = screenWidth >= 700 ? 28.0 : 20.0;
    final sheetVerticalPadding = screenWidth >= 700 ? 26.0 : 22.0;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Theme.of(sheetContext).dividerColor.withValues(alpha: 0.45),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            sheetHorizontalPadding,
            14,
            sheetHorizontalPadding,
            sheetVerticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Update Profile Photo',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: colors.tertiaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick a new photo from your camera or gallery.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.tertiaryText.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ImageOptionButton(
                      icon: Icons.camera_alt_rounded,
                      title: 'Camera',
                      subtitle: 'Take a new photo',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _captureWithCamera();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ImageOptionButton(
                      icon: Icons.photo_library_rounded,
                      title: 'Gallery',
                      subtitle: 'Pick from photos',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        _pickImageFromGallery();
                      },
                    ),
                  ),
                ],
              ),
              if (isDark) const SizedBox(height: 2),
            ],
          ),
        );
      },
    );
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _removePhotoRequested = true;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currenUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      String? pictureUrl = _removePhotoRequested
          ? ''
          : currentUser.profilePictureUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        pictureUrl = await authCubit.authRepo.uploadProfilePicture(
          currentUser.uid,
          _selectedImage!,
        );
      }

      // Update profile
      final success = await authCubit.updateProfile(
        uid: currentUser.uid,
        name: _nameController.text.trim(),
        profilePictureUrl: pictureUrl,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final isCompact = screenWidth < 360;
    final isTablet = screenWidth >= 700;
    final dialogRadius = isTablet ? 32.0 : isCompact ? 22.0 : 28.0;
    final insetPadding = isTablet ? 28.0 : isCompact ? 12.0 : 16.0;
    final contentHorizontalPadding = isTablet ? 28.0 : isCompact ? 16.0 : 22.0;
    final headerFontSize = isTablet ? 24.0 : isCompact ? 20.0 : 22.0;
    final avatarSize = isTablet ? 132.0 : isCompact ? 104.0 : 116.0;
    final actionSpacing = isTablet ? 14.0 : 12.0;
    final stackActions = screenWidth < 420;
    final cardShadow = const [
      BoxShadow(
        color: Color(0x0E000000),
        blurRadius: 22,
        offset: Offset(0, 10),
      ),
    ];

    final currentUser = context.read<AuthCubit>().currenUser;
    final userInitial = (currentUser?.name?.isNotEmpty ?? false)
        ? currentUser!.name!.characters.first.toUpperCase()
        : 'U';
    MemoryImage? existingProfileImage;
    final profilePictureValue = currentUser?.profilePictureUrl;
    if (!_removePhotoRequested &&
        profilePictureValue != null &&
        profilePictureValue.isNotEmpty) {
      try {
        existingProfileImage = MemoryImage(base64Decode(profilePictureValue));
      } catch (_) {
        existingProfileImage = null;
      }
    }

    final hasPhoto = _selectedImage != null || existingProfileImage != null;

    return Dialog(
      insetPadding: EdgeInsets.all(insetPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              contentHorizontalPadding,
              isTablet ? 24 : 20,
              contentHorizontalPadding,
              isTablet ? 22 : 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 18 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF241D2A), const Color(0xFF1A141F)]
                          : const [Color(0xFFFFF7FB), Color(0xFFF5ECF8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.secondary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: colors.tertiaryText,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: headerFontSize,
                                fontWeight: FontWeight.w800,
                                color: colors.tertiaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Update your name and photo. Changes sync instantly.',
                              style: TextStyle(
                                fontSize: isTablet ? 13.5 : 12.5,
                                height: 1.25,
                                color: colors.tertiaryText.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: isDark
                            ? Theme.of(context).cardColor.withValues(alpha: 0.94)
                            : Colors.white.withValues(alpha: 0.7),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: colors.tertiaryText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 420 : double.infinity,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF241D2A), const Color(0xFF1A141F)]
                              : const [Color(0xFFFFFBFD), Color(0xFFF8F1F7)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: colors.secondary.withValues(alpha: 0.12),
                        ),
                        boxShadow: cardShadow,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: avatarSize,
                                height: avatarSize,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFF8A8CB), Color(0xFF8F6EA8)],
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : existingProfileImage,
                                  child: _selectedImage == null &&
                                          existingProfileImage == null
                                      ? Text(
                                          userInitial,
                                          style: TextStyle(
                                            color: colors.tertiaryText,
                                            fontSize: isTablet ? 38 : isCompact ? 30 : 34,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Material(
                                  color: colors.secondary,
                                  shape: const CircleBorder(),
                                  elevation: 3,
                                  shadowColor: Colors.black26,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _isLoading ? null : _showImageSourceDialog,
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            hasPhoto ? 'Photo selected' : 'Add a profile photo',
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w700,
                              color: colors.tertiaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap the camera button to update your image.',
                            style: TextStyle(
                              fontSize: isTablet ? 12.5 : 11.5,
                              color: colors.tertiaryText.withValues(alpha: 0.68),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (hasPhoto) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: TextButton.icon(
                                onPressed: _isLoading ? null : _removePhoto,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Remove photo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFD23F57),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    side: BorderSide(
                                      color: const Color(0xFFD23F57).withValues(alpha: 0.18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AppSectionCard(
                  title: 'Display Name',
                  subtitle: 'Use up to 30 characters.',
                  icon: Icons.badge_outlined,
                  child: TextField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.done,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: colors.tertiaryText.withValues(alpha: 0.45),
                      ),
                      filled: true,
                        fillColor: isDark
                          ? Theme.of(context).cardColor.withValues(alpha: 0.96)
                          : const Color(0xFFFDF8FC),
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12, end: 10),
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: colors.tertiaryText.withValues(alpha: 0.65),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.secondary.withValues(alpha: 0.16),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.secondary.withValues(alpha: 0.16),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: colors.secondary,
                          width: 2,
                        ),
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: colors.tertiaryText,
                      fontSize: isTablet ? 16 : 15,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Keep actions fixed and obvious for quicker edits.
                stackActions
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: BorderSide(
                                  color: colors.secondary.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Discard',
                                style: TextStyle(
                                  color: colors.tertiaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _PrimarySaveButton(
                            label: _isLoading ? 'Saving...' : 'Save Changes',
                            isLoading: _isLoading,
                            onPressed: _saveProfile,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.fromHeight(isTablet ? 50 : 46),
                                side: BorderSide(
                                  color: colors.secondary.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Discard',
                                style: TextStyle(
                                  color: colors.tertiaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: actionSpacing),
                          Expanded(
                            child: _PrimarySaveButton(
                              label: _isLoading ? 'Saving...' : 'Save Changes',
                              isLoading: _isLoading,
                              onPressed: _saveProfile,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageOptionButton extends StatelessWidget {
  const _ImageOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 700;
    final iconContainerSize = isTablet ? 40.0 : 36.0;

    return Material(
      color: isDark
          ? Theme.of(context).cardColor.withValues(alpha: 0.95)
          : const Color(0xFFFDF8FC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: colors.tertiaryText, size: isTablet ? 20 : 19),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w700,
                  color: colors.tertiaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isTablet ? 12.5 : 12,
                  color: colors.tertiaryText.withValues(alpha: 0.62),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimarySaveButton extends StatelessWidget {
  const _PrimarySaveButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.primaryText,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: colors.secondary.withValues(alpha: 0.26)),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                colors.secondary.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: colors.secondary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
