import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../viewmodel/hold_request_viewmodel.dart';
import '../../../data/models/hold_request_models.dart';

class MyRequestsView extends StatefulWidget {
  const MyRequestsView({super.key});

  @override
  State<MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<MyRequestsView> {
  final _vm = HoldRequestViewModel();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onStateChanged);
    _vm.loadMyRequests();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onStateChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryDark),
          iconSize: 20,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Requests',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: _vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vm.errorMessage != null
              ? Center(child: Text(_vm.errorMessage!))
              : _vm.myRequests.isEmpty
                  ? const Center(child: Text('You have no requests yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vm.myRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final req = _vm.myRequests[index];
                        return _buildRequestCard(req);
                      },
                    ),
    );
  }

  Widget _buildRequestCard(HoldRequestDto req) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                req.requestType == 'ReadyTrip' ? (req.tripTitle ?? 'Ready Trip') : 'Private Trip',
                style: AppTextStyles.heading3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(req.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.status,
                  style: AppTextStyles.label.copyWith(color: _getStatusColor(req.status), fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Guide: ${req.guideName ?? 'Unknown'}', style: AppTextStyles.bodyTextSmall),
          const SizedBox(height: 4),
          Text('Dates: ${_formatDate(req.startDate)} - ${_formatDate(req.endDate)}', style: AppTextStyles.bodyTextSmall),
          const SizedBox(height: 4),
          Text('Travelers: ${req.numberOfTravelers} (${req.travelerType})', style: AppTextStyles.bodyTextSmall),
          if (req.totalPrice > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Price: ${req.totalPrice} ${req.currency ?? 'EGP'}',
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendingrequest':
        return Colors.orange;
      case 'accepted':
      case 'paid':
      case 'active':
      case 'completed':
        return AppColors.success;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      case 'paymentpending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
