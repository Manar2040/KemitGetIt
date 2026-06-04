import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/tourist_models.dart';
import '../viewmodel/tourist_profile_viewmodel.dart';

/// Edit-profile screen for tourists.
///
/// Accepts the current [TouristProfileResponse] as a route argument.
/// Calls PUT /api/users/tourist/profile and POST /api/users/upload-profile-image
/// via [TouristProfileViewModel].
class EditProfileView extends StatefulWidget {
  /// Pass the current profile as an argument from the route:
  ///   Navigator.pushNamed(context, AppRoutes.editProfile, arguments: profile);
  final TouristProfileResponse? profile;
  const EditProfileView({super.key, this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers mirroring UpdateTouristProfileDto fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _genderController;
  late TextEditingController _aboutTextController;
  late TextEditingController _experienceTextController;
  late TextEditingController _ageController;
  late TextEditingController _touristTypeController;
  late TextEditingController _countryController;
  late TextEditingController _languageController;

  File? _pickedImageFile;
  final _picker = ImagePicker();
  final _vm = TouristProfileViewModel();
  TouristProfileResponse? _profile;

  @override
  void initState() {
    super.initState();
    // Support both passing profile via constructor OR route arguments
    _profile = widget.profile;
    _initControllers();
    _vm.addListener(_onVmChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pick up profile from route arguments if not passed via constructor
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is TouristProfileResponse && _profile == null) {
      _profile = arg;
      _initControllers();
    }
  }

  void _initControllers() {
    final p = _profile;
    _firstNameController     = TextEditingController(text: p?.firstName ?? '');
    _lastNameController      = TextEditingController(text: p?.lastName ?? '');
    _genderController        = TextEditingController(text: p?.gender ?? '');
    _aboutTextController     = TextEditingController(text: p?.aboutText ?? '');
    _experienceTextController= TextEditingController(text: p?.experienceText ?? '');
    _ageController           = TextEditingController(text: p?.age?.toString() ?? '');
    _touristTypeController   = TextEditingController(text: p?.touristTypePreference ?? '');
    _countryController       = TextEditingController(text: p?.countryOfResidence ?? '');
    _languageController      = TextEditingController(text: p?.preferredLanguage ?? '');
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _aboutTextController.dispose();
    _experienceTextController.dispose();
    _ageController.dispose();
    _touristTypeController.dispose();
    _countryController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _pickedImageFile = File(picked.path));
      // Upload immediately
      await _vm.uploadProfileImage(picked.path);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final age = int.tryParse(_ageController.text.trim());
    final req = UpdateTouristProfileRequest(
      firstName:             _firstNameController.text.trim().isEmpty ? null : _firstNameController.text.trim(),
      lastName:              _lastNameController.text.trim().isEmpty  ? null : _lastNameController.text.trim(),
      gender:                _genderController.text.trim().isEmpty    ? null : _genderController.text.trim(),
      aboutText:             _aboutTextController.text.trim().isEmpty ? null : _aboutTextController.text.trim(),
      experienceText:        _experienceTextController.text.trim().isEmpty ? null : _experienceTextController.text.trim(),
      age:                   age,
      touristTypePreference: _touristTypeController.text.trim().isEmpty ? null : _touristTypeController.text.trim(),
      countryOfResidence:    _countryController.text.trim().isEmpty   ? null : _countryController.text.trim(),
      preferredLanguage:     _languageController.text.trim().isEmpty  ? null : _languageController.text.trim(),
    );

    final success = await _vm.updateProfile(req);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // signal caller to reload
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          if (_vm.isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFFB0915E), fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ────────────────────────────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      _buildAvatarWidget(),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: _vm.isUploadingImage ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFB0915E),
                              shape: BoxShape.circle,
                            ),
                            child: _vm.isUploadingImage
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Error banner ──────────────────────────────────────────────────
                if (_vm.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Form fields ───────────────────────────────────────────────────
                _buildTextField('First Name',   _firstNameController,      Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField('Last Name',    _lastNameController,       Icons.person_outline),
                const SizedBox(height: 16),
                _buildDropdownField('Gender', _genderController, Icons.wc_outlined, ['Male', 'Female']),
                const SizedBox(height: 16),
                _buildTextField('Age',          _ageController,            Icons.celebration_outlined,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDropdownField('Country of Residence', _countryController, Icons.public_outlined, ['Egypt', 'USA', 'UK', 'France', 'Germany', 'UAE', 'Saudi Arabia', 'Kuwait']),
                const SizedBox(height: 16),
                _buildDropdownField('Preferred Language', _languageController, Icons.language_outlined, ['English', 'Arabic', 'French', 'Spanish', 'German', 'Italian']),
                const SizedBox(height: 16),
                _buildDropdownField('Tourist Type Preference', _touristTypeController, Icons.explore_outlined, ['Historical', 'Adventure', 'Relaxation', 'Cultural', 'Nature', 'Luxury']),
                const SizedBox(height: 16),
                _buildTextField('About Me',     _aboutTextController,      Icons.info_outline,
                    maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('Travel Experience', _experienceTextController, Icons.luggage_outlined,
                    maxLines: 3),
                const SizedBox(height: 40),

                // ── Save button ───────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _vm.isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.textDisabled,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: _vm.isSaving
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Save Changes', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWidget() {
    String? networkUrl = _vm.profile?.profileImageUrl ?? _profile?.profileImageUrl;
    if (networkUrl != null && networkUrl.isNotEmpty && !networkUrl.startsWith('http')) {
      networkUrl = '${ApiConstants.baseUrl}$networkUrl';
    }

    ImageProvider? imageProvider;
    if (_pickedImageFile != null) {
      imageProvider = FileImage(_pickedImageFile!);
    } else if (networkUrl != null && networkUrl.isNotEmpty) {
      imageProvider = NetworkImage(networkUrl);
    }

    return CircleAvatar(
      radius: 60,
      backgroundImage: imageProvider,
      backgroundColor: AppColors.borderLight,
      child: imageProvider == null
          ? const Icon(Icons.person, size: 60, color: Colors.grey)
          : null,
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFB0915E), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          // Only age has a specific validator; all others are optional
          validator: label == 'Age'
              ? (value) {
                  if (value == null || value.isEmpty) return null; // optional
                  final age = int.tryParse(value);
                  if (age == null || age < 10 || age > 120) {
                    return 'Age must be between 10 and 120';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
  Widget _buildDropdownField(
    String label,
    TextEditingController controller,
    IconData icon,
    List<String> items,
  ) {
    // Find matching item case-insensitively to prevent Dropdown assertion errors
    String? currentValue;
    if (controller.text.isNotEmpty) {
      final textLower = controller.text.toLowerCase();
      try {
        currentValue = items.firstWhere((item) => item.toLowerCase() == textLower);
      } catch (e) {
        // If not found at all, we can't use it, so leave it null
        currentValue = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFFB0915E), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              controller.text = val;
            }
          },
        ),
      ],
    );
  }
}
