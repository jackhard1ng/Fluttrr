import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/utils.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../config/routes.dart';

/// Splash screen with beautiful brand experience and auto-login check
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _taglineFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    // Logo fade and scale animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _taglineFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Stagger the animations
    _fadeController.forward();
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _slideController.forward();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));

    // Initialize auth controller
    final authController = Get.put(AuthController());
    final isLoggedIn = await authController.isLoggedIn();

    if (isLoggedIn) {
      // Initialize profile controller for logged-in users
      Get.put(ProfileController());
      Nav.toHome();
    } else {
      Nav.toLogin();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppGradients.splashGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle background pattern (butterfly wing shapes)
              Positioned(
                top: -100,
                right: -100,
                child: _buildBackgroundShape(200, 0.03),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: _buildBackgroundShape(180, 0.02),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Butterfly logo with animations
                    AnimatedBuilder(
                      animation: Listenable.merge([_fadeController, _scaleController]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withAlpha(77),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/lgo1.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(35),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.flutter_dash,
                                    size: 70,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Wordmark logo with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _taglineFadeAnimation,
                        child: Image.asset(
                          'assets/lttrrlogo.jpg',
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.accentBlue],
                              ).createShader(bounds),
                              child: const Text(
                                'fluttrr.',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Tagline with fade animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _taglineFadeAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryBlue.withAlpha(51),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            'Find Your People',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withAlpha(179),
                              letterSpacing: 3,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl * 2),

                    // Loading indicator
                    FadeTransition(
                      opacity: _taglineFadeAnimation,
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue.withAlpha(179),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom tagline
              Positioned(
                bottom: AppSpacing.xl,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _taglineFadeAnimation,
                  child: Text(
                    'Platonic friendships, real connections',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(102),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundShape(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryBlue.withAlpha((opacity * 255).round()),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
