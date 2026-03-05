import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/auth/viewmodels/auth_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';

class SignupView extends StatefulWidget {
  final String role;
  const SignupView({Key? key, required this.role}) : super(key: key);

  @override
  State<SignupView> createState() => _SignupViewState();
}


class _SignupViewState extends State<SignupView> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool termsAccepted = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  late final AuthViewModel vm;
  late final String role;
 

@override
void initState() {
  super.initState();
  role = widget.role;
  vm = AuthViewModel();
  vm.addListener(_onVmChanged);
}

  void _onVmChanged() {
    if (vm.navTarget == AuthNavTarget.profileCompletion) {
      vm.consumeNavTarget();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.profileForm);
      return;
    }

    if (vm.navTarget == AuthNavTarget.profileVerification) {
      vm.consumeNavTarget();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.profileVerification);
      return;
    }

    if (vm.navTarget == AuthNavTarget.home) {
      vm.consumeNavTarget();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
  }

   @override
void dispose() {
  vm.removeListener(_onVmChanged);
  vm.dispose();
  usernameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: vm,
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
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
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

                  Text('Create Account', style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  Text(
                    'Join our community and experience a seamless way of finding your perfect match',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 32),

                  Text('Username', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 24),

                  Text('Email', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: emailController,
                    hintText: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

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
                      onPressed:
                          () => setState(() => showPassword = !showPassword),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Confirm Password', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscureText: !showConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed:
                          () => setState(
                            () => showConfirmPassword = !showConfirmPassword,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap:
                            () =>
                                setState(() => termsAccepted = !termsAccepted),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  termsAccepted
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                              width: 2,
                            ),
                            color:
                                termsAccepted
                                    ? AppColors.primary
                                    : AppColors.surface,
                          ),
                          child:
                              termsAccepted
                                  ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.surface,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              () => setState(
                                () => termsAccepted = !termsAccepted,
                              ),
                          child: Text(
                            'By agreeing to the terms and conditions, you are entering into a legally binding contract with the service provider.',
                            style: AppTextStyles.bodyTextSmall.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  if (vm.errorMessage != null)
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
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vm.errorMessage!,
                              style: AppTextStyles.bodyTextSmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (vm.errorMessage != null) const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          vm.isLoading
                              ? null
                              : () {
                                vm.signup(
                                  role: role,
                                  username: usernameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  confirmPassword:
                                      confirmPasswordController.text,
                                  termsAccepted: termsAccepted,
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.textDisabled,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child:
                          vm.isLoading
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
                  const SizedBox(height: 24),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyText,
                        ),
                        GestureDetector(
                          onTap:
                              () =>
                                  Navigator.pushNamed(context, AppRoutes.login),
                          child: Text(
                            'Login',
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
