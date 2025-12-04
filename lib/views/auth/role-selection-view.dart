import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/text_styles.dart';
import '../../routes/app_routes.dart';

class RoleSelectionView extends StatefulWidget {
  const RoleSelectionView({Key? key}) : super(key: key);

  @override
  State<RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<RoleSelectionView> {
  String selectedRole = 'tourist';
  bool isLoading = false;

  final List<RoleItem> roles = [
    RoleItem(
      value: 'tourist',
      label: 'A Tourist',
      description: 'Explore destinations and find local guides',
      image:
          "https://avatars.mds.yandex.net/i?id=4b6fa120ed30e035cdfc517787a669b262886d2e-5320367-images-thumbs&n=13",
      icon: Icons.explore,
    ),
    RoleItem(
      value: 'guide',
      label: 'A Guide',
      description: 'Share your local knowledge and experiences',
      image:
          "https://avatars.mds.yandex.net/i?id=773994f4611ce695fcbfd52efe0f213728f7cdd1-16407139-images-thumbs&n=13",
      icon: Icons.person_pin_circle,
    ),
    RoleItem(
      value: 'provider',
      label: 'A Provider',
      description: 'Offer services and create experiences',
      image:
          "https://images.pexels.com/photos/271639/pexels-photo-271639.jpeg",
      icon: Icons.store,
    ),
  ];

  void _handleContinue() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Continuing as a $selectedRole...'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.signUp,
              arguments: null); // Will update with actual User object
        }
      });
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Header
            Text('Continue As', style: AppTextStyles.heading1),
            const SizedBox(height: 8),
            Text(
              'Choose your role to get started',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 32),

            // Role Cards
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    for (int i = 0; i < roles.length; i++) ...[
                      _buildRoleCard(roles[i]),
                      if (i < roles.length - 1) const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleContinue,
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
                    : Text(
                        'Continue as a $selectedRole',
                        style: AppTextStyles.button,
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(RoleItem role) {
    final isSelected = selectedRole == role.value;

    return GestureDetector(
      onTap: () => setState(() => selectedRole = role.value),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2.5 : 1.5,
          ),
          color: AppColors.surface,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(role.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Label with Icon
                  Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          role.label,
                          style: AppTextStyles.label.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    role.description,
                    style: AppTextStyles.bodyTextSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleItem {
  final String value;
  final String label;
  final String description;
  final String image;
  final IconData icon;

  RoleItem({
    required this.value,
    required this.label,
    required this.description,
    required this.image,
    required this.icon,
  });
}