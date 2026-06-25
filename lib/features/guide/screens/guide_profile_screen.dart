import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kemit_get_it/features/guide/core/guide_profile_service.dart';
//import 'package:kemit_get_it/features/guide/core/trip_service.dart';
import 'package:kemit_get_it/features/guide/models/all.dart';
import 'package:kemit_get_it/features/guide/screens/edit_profile.dart';
import 'package:kemit_get_it/features/guide/screens/guide_reviews_screen.dart';
import 'package:kemit_get_it/features/guide/widgets/guide_profile_widgets.dart';
import 'package:kemit_get_it/features/guide/widgets/wallet_widget.dart';
import 'package:kemit_get_it/routes/app_routes.dart';

class GuideProfileView extends StatefulWidget {
  const GuideProfileView({super.key});

  @override
  State<GuideProfileView> createState() => _GuideProfileViewState();
}

class _GuideProfileViewState extends State<GuideProfileView> {
  GuideProfileModel? _profile;
  //List<ActiveTripModel> _completedTrips = [];

  bool _isLoading = true;
  bool _isUploadingImage = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await GuideProfileService.getProfile();
      //final trips = await TripService.getMyTrips(status: 'completed');
      if (!mounted) return;
      setState(() {
        _profile = profile;
        //_completedTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  // ── اختيار وتحميل صورة البروفايل ────────────────────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() => _isUploadingImage = true);

    final newUrl = await GuideProfileService.uploadProfileImage(
      File(picked.path),
    );

    if (!mounted) return;
    setState(() => _isUploadingImage = false);

    if (newUrl != null) {
      // نعمل refresh للبروفايل عشان نعرض الصورة الجديدة
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload photo')));
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Log out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await GuideProfileService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _goToEditProfile() async {
    if (_profile == null) return;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile!)),
    );
    if (updated == true) {
      _loadData(); // refresh البيانات بعد التعديل
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
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _confirmLogout,
            tooltip: 'Log out',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFB9975B)),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileHeaderWidget(
                            profile: _profile!,
                            onEditTap:
                                _isUploadingImage ? null : _pickAndUploadImage,
                          ),
                          if (_isUploadingImage)
                            const Positioned(
                              top: 30,
                              child: CircularProgressIndicator(
                                color: Color(0xFFB9975B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton.icon(
                          onPressed: _goToEditProfile,
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Color(0xFFB9975B),
                          ),
                          label: const Text(
                            "Edit Profile",
                            style: TextStyle(color: Color(0xFFB9975B)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AboutMeWidget(aboutMe: _profile!.bio),
                      const SizedBox(height: 20),
                      // ← ضيفي ده هنا
                      GuideInfoChipsWidget(
                        specialization: _profile!.specialization,
                        workingRegions: _profile!.workingRegions,
                      ),
                      const SizedBox(height: 20),
                      const GuideWalletWidget(),
                      const SizedBox(height: 20),
 

                      FeedbackListWidget(
                        feedbacks: _profile!.recentReviews,
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => GuideReviewsScreen(
                                    guideUserId: _profile!.userId,
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
