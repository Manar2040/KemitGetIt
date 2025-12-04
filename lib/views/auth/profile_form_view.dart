import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../core/constants/app_colors.dart';
import '../../core/themes/text_styles.dart';
import '../home/home_view.dart';
class ProfileFormView extends StatefulWidget {
  final User user;
  final Function(User)? onSave;

  const ProfileFormView({
    super.key,
    required this.user,
    this.onSave,
  });

  @override
  State<ProfileFormView> createState() => _ProfileFormViewState();
}

class _ProfileFormViewState extends State<ProfileFormView> {
  late TextEditingController phoneController;
  late TextEditingController ageController;

  String? selectedCountry;
  String? selectedLanguage;
  Set<String> selectedInterests = {};
  bool isLoading = false;
  String? errorMessage;

  final List<String> interestOptions = [
    'Art',
    'History',
    'Food',
    'Culture',
    'Other',
  ];

  final List<String> countryOptions = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Spain',
    'Italy',
    'Japan',
    'China',
    'India',
    'Brazil',
    'Mexico',
    'Egypt',
    'South Africa',
    'United Arab Emirates',
    'Singapore',
    'Thailand',
    'New Zealand',
    'Sweden',
    'Netherlands',
    'Belgium',
    'Switzerland',
    'Austria',
    'Poland',
    'Greece',
    'Portugal',
    'Ireland',
    'Norway',
    'Denmark',
  ];

  final List<String> languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Polish',
    'Greek',
    'Turkish',
    'Russian',
    'Arabic',
    'Chinese (Mandarin)',
    'Chinese (Cantonese)',
    'Japanese',
    'Korean',
    'Thai',
    'Vietnamese',
    'Hindi',
    'Bengali',
    'Urdu',
    'Indonesian',
    'Tagalog',
    'Hebrew',
    'Finnish',
    'Czech',
    'Hungarian',
  ];

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.user.phone ?? '');
    ageController = TextEditingController(text: widget.user.age?.toString() ?? '');
    selectedCountry = widget.user.country;
    selectedLanguage = widget.user.language;
    selectedInterests = Set<String>.from(widget.user.interests);
  }

  @override
  void dispose() {
    phoneController.dispose();
    ageController.dispose();
    super.dispose();
  }

  bool validateForm() {
    if (phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (phoneController.text.trim().length < 10) {
      _showError('Please enter a valid phone number');
      return false;
    }
    if (ageController.text.trim().isEmpty) {
      _showError('Please enter your age');
      return false;
    }
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 18 || age > 120) {
      _showError('Please enter a valid age (18-120)');
      return false;
    }
    if (selectedCountry == null || selectedCountry!.isEmpty) {
      _showError('Please select your country');
      return false;
    }
    if (selectedLanguage == null || selectedLanguage!.isEmpty) {
      _showError('Please select your language');
      return false;
    }
    if (selectedInterests.isEmpty) {
      _showError('Please select at least one interest');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    setState(() => errorMessage = message);
  }

  Future<void> submitForm() async {
    if (!validateForm()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final updatedUser = widget.user.copyWith(
      phone: phoneController.text.trim(),
      age: int.tryParse(ageController.text.trim()),
      country: selectedCountry,
      language: selectedLanguage,
      interests: selectedInterests.toList(),
    );

    setState(() => isLoading = false);

    if (mounted) {
      // Call the callback if provided
      if (widget.onSave != null) {
        widget.onSave!(updatedUser);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Navigate back with result
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeView(user: updatedUser)),
);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Header Section
              _buildHeader(),
              const SizedBox(height: 32),

              // Phone Field
              _buildPhoneField(),
              const SizedBox(height: 24),

              // Age Field
              _buildAgeField(),
              const SizedBox(height: 24),

              // Country Dropdown
              _buildCountryField(),
              const SizedBox(height: 24),

              // Language Dropdown
              _buildLanguageField(),
              const SizedBox(height: 32),

              // Interests Section
              _buildInterestsSection(),
              const SizedBox(height: 28),

              // Error Message
              if (errorMessage != null) _buildErrorMessage(),
              const SizedBox(height: 24),

              // Continue Button
              _buildContinueButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us more about you',
          style: AppTextStyles.heading1,
        ),
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
        controller: phoneController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: 'phone',
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAgeField() {
    return _buildFormFieldContainer(
      label: 'Age',
      child: TextField(
        controller: ageController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.bodyText,
        decoration: InputDecoration(
          hintText: 'age',
          hintStyle: AppTextStyles.hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
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
          value: selectedCountry,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'nationality',
              style: AppTextStyles.hint,
            ),
          ),
          underline: const SizedBox(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ),
          items: countryOptions.map((country) {
            return DropdownMenuItem(
              value: country,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  country,
                  style: AppTextStyles.bodyText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedCountry = value);
          },
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
          value: selectedLanguage,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'language',
              style: AppTextStyles.hint,
            ),
          ),
          underline: const SizedBox(),
          icon: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(
              Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ),
          items: languageOptions.map((language) {
            return DropdownMenuItem(
              value: language,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  language,
                  style: AppTextStyles.bodyText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedLanguage = value);
          },
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
        Text(
          'Interests',
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 16),
        Column(
          children: interestOptions.asMap().entries.map((entry) {
            int index = entry.key;
            String interest = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < interestOptions.length - 1 ? 12 : 0,
              ),
              child: _buildInterestItem(interest),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestItem(String interest) {
    final isSelected = selectedInterests.contains(interest);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedInterests.remove(interest);
          } else {
            selectedInterests.add(interest);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
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
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.surface,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                interest,
                style: isSelected
                    ? AppTextStyles.bodyText.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      )
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
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: AppTextStyles.bodyTextSmall.copyWith(
                color: AppColors.error,
              ),
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
        onPressed: isLoading ? null : submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.surface),
                ),
              )
            : Text(
                'Continue',
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  Widget _buildFormFieldContainer({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
            color: AppColors.surface,
          ),
          child: child,
        ),
      ],
    );
  }
}