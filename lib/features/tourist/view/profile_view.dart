import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/themes/text_styles.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/tourist_profile_viewmodel.dart';
import '../../../data/models/tourist_models.dart';
import '../../../core/services/token_storage.dart';

/// Tourist profile screen – reads data from the real backend via
/// [TouristProfileViewModel] → [TouristProfileService] → [ApiClient].
///
/// The old [MockProfileRepository] is no longer used anywhere in this flow.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _vm = TouristProfileViewModel();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadProfile();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  Future<void> _refresh() => _vm.loadProfile();

  @override
  Widget build(BuildContext context) {
    if (_vm.isLoading && _vm.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_vm.errorMessage != null && _vm.profile == null) {
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
            'Profile Error',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(_vm.errorMessage!, style: AppTextStyles.subtitle, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: _vm.loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await TokenStorage.instance.clearAll();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _vm.profile;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('No profile data.')));
    }

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
          'Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAvatar(profile),
                const SizedBox(height: 16),
                Text(
                  _vm.displayName,
                  style: AppTextStyles.heading2.copyWith(color: Colors.black),
                ),
                Text(
                  profile.email ?? '',
                  style: AppTextStyles.bodyText.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to edit; reload on return so changes reflect
                    await Navigator.pushNamed(context, AppRoutes.editProfile, arguments: profile);
                    _vm.loadProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB0915E),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.myRequests);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB0915E),
                    side: const BorderSide(color: Color(0xFFB0915E), width: 1.5),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'My Trip Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoGrid(profile),
                const SizedBox(height: 24),
                _buildInterestsSection(profile.interests),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await TokenStorage.instance.clearAll();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(TouristProfileResponse profile) {
    String? imageUrl = profile.profileImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      // Import ApiConstants if not already there, or we can use a hardcoded fallback or import.
      // Wait, let's just make sure ApiConstants is imported.
      imageUrl = '${ApiConstants.baseUrl}$imageUrl';
    }

    return CircleAvatar(
      radius: 60,
      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
          ? NetworkImage(imageUrl)
          : null,
      backgroundColor: AppColors.borderLight,
      child: (imageUrl == null || imageUrl.isEmpty)
          ? const Icon(Icons.person, size: 60, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfoGrid(TouristProfileResponse profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildInfoCard(Icons.phone_outlined,    'Phone',       profile.phoneNumber ?? 'N/A'),
        _buildInfoCard(Icons.language_outlined, 'Language',    profile.preferredLanguage ?? 'N/A'),
        _buildInfoCard(Icons.public_outlined,   'Nationality', profile.countryOfResidence ?? 'N/A'),
        _buildInfoCard(Icons.celebration_outlined, 'Age',     profile.age?.toString() ?? 'N/A'),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFB0915E), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFB0915E),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(List<String> interests) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_bike_outlined, color: Color(0xFFB0915E), size: 20),
              SizedBox(width: 8),
              Text(
                'Interests',
                style: TextStyle(
                  color: Color(0xFFB0915E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (interests.isEmpty)
            Text(
              'No interests selected.',
              style: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.textSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((i) => _buildInterestChip(i)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB0915E),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
