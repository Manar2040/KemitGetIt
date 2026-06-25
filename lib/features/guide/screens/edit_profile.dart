// ============================================================
// edit_profile_screen.dart
// KemitGetit — Guide Edit Profile Screen
// API: PUT /api/users/guide/profile
// ============================================================

import 'package:flutter/material.dart';
import 'package:kemit_get_it/features/guide/core/guide_profile_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';

class EditProfileScreen extends StatefulWidget {
  final GuideProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _specializationCtrl;
  late final TextEditingController _workingRegionsCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.profile.firstName);
    _lastNameCtrl = TextEditingController(text: widget.profile.lastName);
    _displayNameCtrl = TextEditingController(text: widget.profile.displayName);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _specializationCtrl = TextEditingController(
      text: widget.profile.specialization,
    );
    _workingRegionsCtrl = TextEditingController(
      text: widget.profile.workingRegions,
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _specializationCtrl.dispose();
    _workingRegionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final request = UpdateGuideProfileRequest(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      displayName: _displayNameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      specialization: _specializationCtrl.text.trim(),
      workingRegions: _workingRegionsCtrl.text.trim(),
    );

    final success = await GuideProfileService.updateProfile(request);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Color(0xFFB9975B),
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFFB9975B),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(
                children: [
                  _buildField(
                    label: 'First Name',
                    controller: _firstNameCtrl,
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  _divider(),
                  _buildField(
                    label: 'Last Name',
                    controller: _lastNameCtrl,
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  _divider(),
                  _buildField(
                    label: 'Display Name',
                    controller: _displayNameCtrl,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                children: [
                  _buildField(
                    label: 'Bio',
                    controller: _bioCtrl,
                    maxLines: 4,
                    hint: 'Tell tourists about yourself...',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCard(
                children: [
                  _buildField(
                    label: 'Specialization',
                    controller: _specializationCtrl,
                    hint: 'e.g. Historical, Cultural',
                  ),
                  _divider(),
                  _buildField(
                    label: 'Working Regions',
                    controller: _workingRegionsCtrl,
                    hint: 'e.g. Cairo, Luxor, Aswan',
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    color: Color(0xFFF0F0F0),
    indent: 16,
  );
}
