import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/services/api_client.dart';

/// Screen for requesting a password-reset email.
///
/// Calls POST /api/auth/forgot-password.
/// The backend always returns 200 regardless of whether the email exists,
/// to prevent user enumeration. We reflect this in the UX.
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Import via AuthViewModel helper so we don't duplicate service logic
      final vm = AuthViewModel();
      await vm.forgotPassword(email);
      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
      vm.dispose();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Only pretend success if it's a validation thing from backend, 
          // but backend always returns 200 anyway. 
          // If we get an ApiException, it might be a real 500 error from SMTP.
          _errorMessage = e.userMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Connection error: Could not reach the server.';
        });
      }
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
          child: _emailSent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Forgot Password', style: AppTextStyles.heading1),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address and we\'ll send you a link to reset your password.',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 40),

        Text('Email', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderLight, width: 1),
            color: AppColors.surface,
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyText,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              hintStyle: AppTextStyles.hint,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textDisabled,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                    ),
                  )
                : Text('Send Reset Link', style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.12),
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.success),
        ),
        const SizedBox(height: 32),
        Text(
          'Check your inbox',
          style: AppTextStyles.heading1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_emailController.text.trim()}, '
          'you\'ll receive a password reset link shortly.',
          style: AppTextStyles.subtitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: Text('Back to Login', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
