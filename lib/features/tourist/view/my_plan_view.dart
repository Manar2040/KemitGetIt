import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/place.dart';
import '../viewmodel/places_viewmodel.dart';

/// My Plan screen — shows places the tourist has saved to their plan.
///
/// Backed by [MyPlanViewModel] → [MyPlanService] → GET/DELETE /api/myplan
class MyPlanView extends StatefulWidget {
  const MyPlanView({super.key});

  @override
  State<MyPlanView> createState() => _MyPlanViewState();
}

class _MyPlanViewState extends State<MyPlanView> {
  final _vm = MyPlanViewModel();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
    _vm.loadPlan();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Plan',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state
    if (_vm.isLoading && _vm.planItems.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    // Error state
    if (_vm.errorMessage != null && _vm.planItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(_vm.errorMessage!, textAlign: TextAlign.center,
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _vm.loadPlan,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_vm.planItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('Your plan is empty',
                style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text('Add places from the Places section.',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Review the places you selected.',
            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text('Places in Plan', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _vm.loadPlan,
              color: AppColors.primary,
              child: ListView.separated(
                itemCount: _vm.planItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _vm.planItems[index];
                  return _buildPlanCard(item);
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MyPlanItem item) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.placeName,
                        style: AppTextStyles.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Remove button
                    GestureDetector(
                      onTap: _vm.isModifying
                          ? null
                          : () async {
                              final ok = await _vm.removePlace(item.placeId);
                              if (!ok && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_vm.errorMessage ?? 'Could not remove.'),
                                  ),
                                );
                              }
                            },
                      child: const Icon(Icons.close, size: 18, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                if (item.location != null)
                  Text(
                    item.location!,
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 100,
        height: 70,
        color: AppColors.borderLight,
        child: const Icon(Icons.image, color: AppColors.textHint),
      );
}
