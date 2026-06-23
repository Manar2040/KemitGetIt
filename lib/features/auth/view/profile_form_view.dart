import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/profile_completion_viewmodel.dart';
/// First-time tourist onboarding screen.
///
/// Changes from the old version:
///   - Interests now come from GET /api/interests (real IDs, not hardcoded strings)
///   - Submit calls POST /api/users/tourist/complete-profile with integer interestIds
///   - No more [User] dependency – profile data comes from the backend response
class ProfileFormView extends StatefulWidget {
  // Keep the optional [user] param for backward compat with any remaining callers,
  // but we no longer use it for the API call.
  final dynamic user;
  final Function(dynamic)? onSave;
  const ProfileFormView({super.key, this.user, this.onSave});
  @override
  State<ProfileFormView> createState() => _ProfileFormViewState();
}
class _ProfileFormViewState extends State<ProfileFormView> {
  final _phoneController = TextEditingController();
  final _ageController   = TextEditingController();
  String? _selectedCountry;
  String? _selectedLanguage;
  late final ProfileCompletionViewModel _vm;
  final List<String> _countryOptions = [
    'United States', 'Canada', 'United Kingdom', 'Australia', 'Germany',
    'France', 'Spain', 'Italy', 'Japan', 'China', 'India', 'Brazil',
    'Mexico', 'Egypt', 'South Africa', 'United Arab Emirates', 'Singapore',
    'Thailand', 'New Zealand', 'Sweden', 'Netherlands', 'Belgium',
    'Switzerland', 'Austria', 'Poland', 'Greece', 'Portugal', 'Ireland',
    'Norway', 'Denmark',
  ];
  final List<String> _languageOptions = [
    'English', 'Spanish', 'French', 'German', 'Italian', 'Portuguese',
    'Dutch', 'Swedish', 'Norwegian', 'Danish', 'Polish', 'Greek', 'Turkish',
    'Russian', 'Arabic', 'Chinese (Mandarin)', 'Chinese (Cantonese)',
    'Japanese', 'Korean', 'Thai', 'Vietnamese', 'Hindi', 'Bengali', 'Urdu',
    'Indonesian', 'Tagalog', 'Hebrew', 'Finnish', 'Czech', 'Hungarian',
  ];
  @override
  void initState() {
    super.initState();
    _vm = ProfileCompletionViewModel();
    _vm.addListener(_onVmChanged);
    // Load real interests from the backend immediately
    _vm.loadInterests();
  }
  void _onVmChanged() {
    if (!mounted) return;
    if (_vm.profileCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      });
    }
  }
  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  bool _validateLocalForm() {
    if (_phoneController.text.trim().isEmpty) {
      _vm.setError('Please enter your phone number');
      return false;
    }
    if (_phoneController.text.trim().length < 10) {
      _vm.setError('Please enter a valid phone number (min 10 digits)');
      return false;
    }
    if (_ageController.text.trim().isEmpty) {
      _vm.setError('Please enter your age');
      return false;
    }
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 10 || age > 120) {
      _vm.setError('Please enter a valid age (10\u2013120)');
      return false;
    }
    if (_selectedCountry == null) {
      _vm.setError('Please select your country');
      return false;
    }
    if (_selectedLanguage == null) {
      _vm.setError('Please select your preferred language');
      return false;
    }
    return true;
  }
  Future<void> _submitForm() async {
    if (!_validateLocalForm()) return;
    final age = int.parse(_ageController.text.trim());
    await _vm.completeProfile(
      phone:    _phoneController.text.trim(),
      age:      age,
      country:  _selectedCountry!,
      language: _selectedLanguage!,
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Center(child: _buildProfilePhotoPicker()),
                  const SizedBox(height: 32),
                  _buildPhoneField(),
                  const SizedBox(height: 24),
                  _buildAgeField(),
                  const SizedBox(height: 24),
                  _buildCountryField(),
                  const SizedBox(height: 24),
                  _buildLanguageField(),
                  const SizedBox(height: 32),
                  _buildInterestsSection(),
                  const SizedBox(height: 28),
                  if (_vm.errorMessage != null) ...[
                    _buildErrorMessage(),
                    const SizedBox(height: 16),
                  ],
                  _buildContinueButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          splashRadius: 24,
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell us more about you', style: AppTextStyles.heading1),
        const SizedBox(height: 8),
        Text(
          'Please provide the following information to help us find the best experiences for you',
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
  Widget _buildPhoneField() {
    return _buildFormFieldContainer(
      label: 'Phone',
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: 'e.g. 01012345678',
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
  Widget _buildAgeField() {
    return _buildFormFieldContainer(
      label: 'Age',
      child: TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: 'e.g. 25',
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
  Widget _buildCountryField() {
    return _buildFormFieldContainer(
      label: 'Country of residence',
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text('Select nationality', style: AppTextStyles.hint),
          ),
          underline: const SizedBox(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.expand_more, color: AppColors.textSecondary),
          ),
          items: _countryOptions.map((c) => DropdownMenuItem(
            value: c,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(c, style: AppTextStyles.bodyText, overflow: TextOverflow.ellipsis),
            ),
          )).toList(),
          onChanged: (v) => setState(() => _selectedCountry = v),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  Widget _buildLanguageField() {
    return _buildFormFieldContainer(
      label: 'Preferred Language',
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text('Select language', style: AppTextStyles.hint),
          ),
          underline: const SizedBox(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.expand_more, color: AppColors.textSecondary),
          ),
          items: _languageOptions.map((l) => DropdownMenuItem(
            value: l,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(l, style: AppTextStyles.bodyText, overflow: TextOverflow.ellipsis),
            ),
          )).toList(),
          onChanged: (v) => setState(() => _selectedLanguage = v),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: AppTextStyles.label),
        const SizedBox(height: 16),
        if (_vm.isLoadingInterests)
          const Center(child: CircularProgressIndicator())
        else if (_vm.availableInterests.isEmpty)
          Text(
            'Could not load interests. Please check your connection.',
            style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.error),
          )
        else
          Column(
            children: _vm.availableInterests.asMap().entries.map((entry) {
              final idx      = entry.key;
              final interest = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: idx < _vm.availableInterests.length - 1 ? 12 : 0,
                ),
                child: _buildInterestItem(interest.id, interest.name),
              );
            }).toList(),
          ),
      ],
    );
  }
  Widget _buildInterestItem(int id, String name) {
    final isSelected = _vm.selectedInterestIds.contains(id);
    return GestureDetector(
      onTap: () => _vm.toggleInterest(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderLight, width: 1.5),
          color: AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderGrey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : AppColors.surface,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: AppColors.surface),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: isSelected
                    ? AppTextStyles.bodyText.copyWith(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w500)
                    : AppTextStyles.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildErrorMessage() {
    return Container(
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
              _vm.errorMessage!,
              style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _vm.isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: _vm.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              )
            : Text('Continue', style: AppTextStyles.button),
      ),
    );
  }
  Widget _buildFormFieldContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.borderLight, width: 1),
            color: AppColors.surface,
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildProfilePhotoPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _vm.pickImage,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight, width: 2),
                  image: _vm.selectedImagePath != null
                      ? DecorationImage(
                          image: FileImage(File(_vm.selectedImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _vm.selectedImagePath == null
                    ? const Icon(Icons.person, size: 50, color: AppColors.textSecondary)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.surface, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('Profile Photo', style: AppTextStyles.label),
      ],
    );
  }
}