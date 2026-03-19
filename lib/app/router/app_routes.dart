import 'package:flutter/material.dart';
import 'package:ongdisphere/shared/widgets/loading.dart';

/// Creates a custom route with an enhanced horizontal slide transition.
///
/// This combines slide and fade effects for a smooth, modern navigation transition.
/// The entering page slides in from the right while fading in.
/// Includes smooth pop animation with reverse effects.
Route slideTransitionRoute(
  Widget page, {
  Duration duration = const Duration(milliseconds: 400),
  Curve curve = Curves.easeOutCubic,
}) {
  return PageRouteBuilder(
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const slideBegin = Offset(1.0, 0.0);
      const slideEnd = Offset.zero;

      // Forward animation
      final slideTween = Tween(begin: slideBegin, end: slideEnd)
          .chain(CurveTween(curve: curve));
      
      final fadeTween = Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: curve));

      // Reverse animation for when popping back
      final reverseSlide = SlideTransition(
        position: secondaryAnimation.drive(
          Tween(begin: slideEnd, end: slideBegin)
              .chain(CurveTween(curve: Curves.easeInCubic)),
        ),
        child: child,
      );

      // Combine forward and reverse animations
      return SlideTransition(
        position: animation.drive(slideTween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: reverseSlide,
        ),
      );
    },
  );
}

/// Animated page switcher for smooth transitions between two pages.
///
/// Used for toggling between login/signup pages. Slides from right with fade.
/// Usage: AnimatedPageSwitcher(
///   showFirstPage: isLoginPage,
///   firstPage: LoginPage(),
///   secondPage: SignupPage(),
/// )
class AnimatedPageSwitcher extends StatelessWidget {
  final bool showFirstPage;
  final Widget firstPage;
  final Widget secondPage;
  final Duration duration;
  final Curve curve;

  const AnimatedPageSwitcher({
    super.key,
    required this.showFirstPage,
    required this.firstPage,
    required this.secondPage,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final Widget currentPage = showFirstPage ? firstPage : secondPage;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        // Animate in pages slide from right and fade
        const slideBegin = Offset(1.0, 0.0);
        const slideEnd = Offset.zero;
        final slideTween = Tween(begin: slideBegin, end: slideEnd)
            .chain(CurveTween(curve: curve));
        
        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(showFirstPage),
        child: currentPage,
      ),
    );
  }
}

/// Loading overlay widget with scale and fade animation.
///
/// Shows a loading dialog with animated entry.
/// Usage: AppAnimations.buildLoadingOverlay(context, 'Logging in...')
class AppAnimations {
  /// Build a loading dialog with smooth scale and fade animation
  static Widget buildLoadingOverlay(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return FadeTransition(
          opacity: AlwaysStoppedAnimation(value),
          child: ScaleTransition(
            scale: AlwaysStoppedAnimation(
              Tween<double>(begin: 0.8, end: 1.0).transform(value),
            ),
            child: child,
          ),
        );
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: LoadingScreen(message: message, isFullScreen: false),
        ),
      ),
    );
  }

  /// Build a logout confirmation dialog with smooth animations.
  ///
  /// Shows animated dialog with icon bounce effect and staggered button animation.
  /// Usage: showGeneralDialog(
  ///   context: context,
  ///   pageBuilder: ...,
  ///   transitionBuilder: (context, a1, a2, child) => 
  ///     AppAnimations.buildLogoutDialog(context, a1, onConfirm),
  /// )
  static Widget buildLogoutDialog(
    BuildContext context,
    Animation<double> animation,
    VoidCallback onConfirm, {
    Curve curve = Curves.easeOutBack,
  }) {
    final theme = Theme.of(context);
    
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: curve)),
        child: FadeTransition(
          opacity: animation,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 16,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning icon with elastic bounce animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
                        )),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Logout?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You will need to login again to access your account.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Animate buttons with stagger effect
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                    )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: onConfirm,
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
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

  /// Show animated logout loading overlay with smooth transitions.
  ///
  /// Call after logout confirmation. Shows full-screen loading animation before logout.
  static OverlayEntry buildLogoutLoadingOverlay({
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutBack,
  }) {
    return OverlayEntry(
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, value, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.85 * value),
            child: Center(
              child: ScaleTransition(
                scale: AlwaysStoppedAnimation(
                  Tween<double>(begin: 0.75, end: 1.0).transform(value),
                ),
                child: FadeTransition(
                  opacity: AlwaysStoppedAnimation(value),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: LoadingScreen(message: 'Logging out...', isFullScreen: false),
      ),
    );
  }
}