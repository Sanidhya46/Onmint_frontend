import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import '../config/app_colors.dart';
import '../config/app_config.dart';

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
      _checkAuth();
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

  Future<void> _checkAuth() async {
    // Show splash for 1.8 seconds to ensure visibility
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      final user = authProvider.currentUser;
      
      // Check if user is a vendor
      if (user != null && AppConfig.vendorRoles.contains(user.role.toLowerCase())) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Not a vendor, logout and go to register
        await authProvider.logout();
        Navigator.pushReplacementNamed(context, '/register');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/register');
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
                        Icons.medical_services,
                        size: screenSize.width * 0.25,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'OnMint',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
