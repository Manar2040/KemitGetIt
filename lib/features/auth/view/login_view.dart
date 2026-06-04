import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  @override
  State<LoginView> createState() => _LoginViewState();
}
class _LoginViewState extends State<LoginView> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  late final AuthViewModel _vm;
  @override
  void initState() {
    super.initState();
    _vm = AuthViewModel();
    _vm.addListener(_onVmChanged);
  }
  void _onVmChanged() {
    if (!mounted) return;

    if (_vm.navTarget == AuthNavTarget.profileCompletion) {
      _vm.consumeNavTarget();
      // First-time tourist: profile not yet complete → go to onboarding form
      Navigator.pushReplacementNamed(context, AppRoutes.profileForm);
      return;
    }

    if (_vm.navTarget == AuthNavTarget.home) {
      _vm.consumeNavTarget();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Welcome back!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    // Guide home – also lands on home for now; guide section handled separately
  }
  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text('Login', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    'Join our community and experience a seamless way of finding your perfect match',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 32),
                  // Email
                  Text('Email', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  // Password
                  Text('Password', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: !_showPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Error banner
                  if (_vm.errorMessage != null) ...[
                    _buildErrorBanner(_vm.errorMessage!),
                    const SizedBox(height: 16),
                  ],
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _vm.isLoading
                          ? null
                          : () => _vm.login(
                                email:    _emailController.text,
                                password: _passwordController.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.textDisabled,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: _vm.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(AppColors.surface),
                              ),
                            )
                          : Text('Continue', style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Haven't registered yet? ", style: AppTextStyles.bodyText),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.roleSelection),
                          child: Text(
                            'Register',
                            style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.borderLight, width: 1),
        color: AppColors.surface,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
}
}
