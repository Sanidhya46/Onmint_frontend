import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auth_service/auth_service.dart';
import 'package:ui_components/ui_components.dart';
import '../../config/app_colors.dart';
import '../../config/app_config.dart';
import '../../widgets/terms_privacy_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _apiErrorMessage;
  String _selectedCountryCode = '+91';
  final List<String> _countryCodes = ['+91', '+1', '+44', '+61', '+81', '+49', '+33', '+86', '+7', '+55'];

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        '$_selectedCountryCode${_phoneController.text.trim()}',
        _passwordController.text,
      );

      if (!success) {
        if (mounted) {
          setState(() {
            _apiErrorMessage = authProvider.error
                    ?.replaceAll('Login failed: ', '')
                    .replaceAll('Exception: ', '') ??
                'Login failed. Please try again.';
          });
        }
        return;
      }

      final user = authProvider.currentUser;
      
      if (user != null && AppConfig.vendorRoles.contains(user.role.toLowerCase())) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        await authProvider.logout();
        if (mounted) {
          setState(() {
            _apiErrorMessage = 'This app is for healthcare providers only';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiErrorMessage = e.toString()
              .replaceAll('Exception: ', '')
              .replaceAll('Login failed: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefixWidget,
    Widget? suffixWidget,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    required double s,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13 * s,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF152238),
          ),
        ),
        SizedBox(height: 6 * s),
        SizedBox(
          height: 48 * s, // Fixed scaled height to prevent varying heights
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12 * s, color: Colors.grey.shade400),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 12 * s, right: 8 * s),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: const Color(0xFF0033CC), size: 20 * s),
                    if (prefixWidget != null) ...[
                      SizedBox(width: 8 * s),
                      prefixWidget,
                    ]
                  ],
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 36 * s, minHeight: 36 * s),
              suffixIcon: suffixWidget,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12 * s),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10 * s),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10 * s),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10 * s),
                borderSide: const BorderSide(color: Color(0xFF0033CC), width: 1.5),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0, color: Colors.transparent), // Hide default error text to keep layout intact
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        // Custom error message display for better spacing control
        if (validator != null && controller.text.isNotEmpty) ...[
          // We can optionally add custom error text here if needed, but keeping it simple based on the previous implementation.
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Allocate 40% for top banner, 60% for bottom form
    final topHeight = screenHeight * 0.40;
    final bottomHeight = screenHeight * 0.60;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ──── TOP: Image Banner ────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight,
            child: Image.asset(
              'images/register_login/top_banner.jpeg',
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.blue.shade50,
                  child: const Center(
                    child: Text('Onmint', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0033CC))),
                  ),
                );
              },
            ),
          ),

          // ──── BOTTOM: Form Container ────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            // Move up when keyboard appears
            top: topHeight - bottomInset,
            left: 0,
            right: 0,
            height: bottomHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final formHeight = constraints.maxHeight;
                // Calculate scale factor: decreased base height to 480 to slightly increase the size of all elements
                final s = (formHeight / 480).clamp(0.0, 1.0);

                return Padding(
                  padding: EdgeInsets.only(left: 12 * s, right: 12 * s, bottom: 12 * s),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24 * s),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20 * s,
                          offset: Offset(0, 8 * s),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20 * s, 24 * s, 20 * s, 16 * s),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Welcome Back Header ──
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8 * s),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0033CC),
                                    borderRadius: BorderRadius.circular(12 * s),
                                  ),
                                  child: Icon(Icons.login, color: Colors.white, size: 24 * s),
                                ),
                                SizedBox(width: 14 * s),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome Back!',
                                        style: TextStyle(
                                          fontSize: 20 * s,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 2 * s),
                                      Text(
                                        'Login to continue to Onmint',
                                        style: TextStyle(
                                          fontSize: 12 * s,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20 * s),

                            // ── Mobile Number Field ──
                            _buildTextField(
                              controller: _phoneController,
                              icon: Icons.call_outlined,
                              label: 'Mobile Number',
                              hint: 'Enter mobile number',
                              keyboardType: TextInputType.phone,
                              s: s,
                              onChanged: (_) {
                                if (_apiErrorMessage != null) {
                                  setState(() => _apiErrorMessage = null);
                                }
                              },
                              prefixWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 4 * s),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCountryCode,
                                      items: _countryCodes.map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0033CC),
                                            fontSize: 13 * s,
                                          ),
                                        ),
                                      )).toList(),
                                      onChanged: (v) => setState(() => _selectedCountryCode = v!),
                                      icon: Icon(Icons.keyboard_arrow_down, size: 18 * s, color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 4 * s),
                                ],
                              ),
                              validator: (v) => v!.length != 10 ? 'Enter valid 10 digit number' : null,
                            ),
                            SizedBox(height: 14 * s),

                            // ── Password Field ──
                            _buildTextField(
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: _obscurePassword,
                              s: s,
                              suffixWidget: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12 * s),
                                  child: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey,
                                    size: 20 * s,
                                  ),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),

                            // ── Error Message ──
                            if (_apiErrorMessage != null) ...[
                              SizedBox(height: 12 * s),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(10 * s),
                                  border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: const Color(0xFFDC2626), size: 18 * s),
                                    SizedBox(width: 8 * s),
                                    Expanded(
                                      child: Text(
                                        _apiErrorMessage!,
                                        style: TextStyle(
                                          fontSize: 12 * s,
                                          color: const Color(0xFFDC2626),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _apiErrorMessage = null),
                                      child: Icon(Icons.close, color: const Color(0xFFDC2626), size: 16 * s),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 10 * s),

                            // ── Remember Me & Forgot Password ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 16 * s,
                                      height: 16 * s,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) => setState(() => _rememberMe = v!),
                                        activeColor: const Color(0xFF0033CC),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * s)),
                                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                      ),
                                    ),
                                    SizedBox(width: 8 * s),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 13 * s,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: const Color(0xFF0033CC),
                                      fontSize: 13 * s,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * s),

                            // ── Login Button ──
                            SizedBox(
                              width: double.infinity,
                              height: 46 * s,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0033CC),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12 * s),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20 * s,
                                        width: 20 * s,
                                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15 * s,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 16 * s),

                            // ── OR Divider ──
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16 * s),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13 * s,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              ],
                            ),
                            SizedBox(height: 14 * s),

                            // ── Sign Up Link ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13 * s),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: const Color(0xFF0033CC),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14 * s,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ── Fixed Gap Before Terms & Conditions ──
                            SizedBox(height: 16 * s),

                            // ── Terms & Privacy ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => showTermsPrivacyDialog(context, showAgreeButton: false),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0033CC),
                                      fontSize: 12 * s,
                                    ),
                                  ),
                                ),
                                Text(
                                  '  |  ',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12 * s),
                                ),
                                GestureDetector(
                                  onTap: () => showTermsPrivacyDialog(context, isPrivacyPolicy: true, showAgreeButton: false),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0033CC),
                                      fontSize: 12 * s,
                                    ),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

