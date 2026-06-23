import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import '../config/app_config.dart';
import '../config/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    // Delay initialization to allow splash to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _setupAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();

      // Show splash for 1.8 seconds to ensure visibility
      await Future.delayed(const Duration(milliseconds: 1800));

      if (!mounted) return;

      // Check if we're in development mode
      if (AppConfig.developmentMode) {
        // Clear any existing auth data for testing if configured
        if (AppConfig.forceLogoutOnStart) {
          await authProvider.forceLogout();
        }
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      // PRODUCTION AUTHENTICATION FLOW
      if (authProvider.isAuthenticated && authProvider.isAdmin) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Clear any invalid cached data
        if (authProvider.isAuthenticated && !authProvider.isAdmin) {
          await authProvider.logout();
        }
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Handle initialization error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Image.asset(
            'images/splash_screen.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: screenSize.width * 0.25,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'OnMint Admin',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (AppConfig.developmentMode)
                        Padding(
                          padding: EdgeInsets.only(top: screenSize.height * 0.04),
                          child: Text(
                            'Development Mode',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenSize.width * 0.03,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
