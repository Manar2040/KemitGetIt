import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/text_styles.dart';
import '../../routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => errorMessage = null);

    // Validation
    if (emailController.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please enter your email');
      return;
    }
    if (passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please enter your password');
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login successful!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Header
              Text('Login', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'Join our community and experience a seamless way of finding your perfect match',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 32),

              // Email Field
              Text('Email', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildTextField(
                controller: emailController,
                hintText: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Password Field
              Text('Password', style: AppTextStyles.label),
              const SizedBox(height: 8),
              _buildTextField(
                controller: passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: !showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => showPassword = !showPassword),
                ),
              ),
              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to forgot password screen
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

              // Error Message
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: AppTextStyles.bodyTextSmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              if (errorMessage != null) const SizedBox(height: 16),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.textDisabled,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.surface,
                            ),
                          ),
                        )
                      : Text('Continue', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 28),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.bodyTextSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.borderLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Apple Login Button
              _buildSocialButton(
                label: 'Login with Apple',
                icon: Icons.apple,
                onTap: () {
                  // Handle Apple Login
                },
                iconColor: AppColors.textPrimary,
              ),
              const SizedBox(height: 12),

              // Google Login Button
              _buildSocialButton(
                label: 'Login with Google',
                icon: Image.asset(
                      "lib/core/assets/images/google.png",
                      width: 22,
                     height: 22,
                  ),
                onTap: () {
                  // Handle Google Login
                },
                isOutlined: true,
              ),
              const SizedBox(height: 28),

              // Register Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Haven't registered yet? ",
                      style: AppTextStyles.bodyText,
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.roleSelection),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required dynamic icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
          color: isOutlined ? AppColors.surface : AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is IconData
                ? Icon(
                    icon,
                    color: iconColor ?? AppColors.textSecondary,
                    size: 24,
                  )
                : icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}