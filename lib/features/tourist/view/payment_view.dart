import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String? _selectedMethod = 'Credit / Debit Card';

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
          'Payment',
          style: AppTextStyles.heading2.copyWith(color: const Color(0xFF2C3E50)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a payment method',
              style: AppTextStyles.heading2.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              title: 'Credit / Debit Card',
              subtitle: '**** **** 2003',
              leadingIcon: SizedBox(
                width: 40,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent.withOpacity(0.9)),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.amber.withOpacity(0.9)),
                      ),
                    ),
                  ],
                ),
              ),
              value: 'Credit / Debit Card',
            ),
            _buildPaymentOption(
              title: 'PayPal',
              leadingIcon: const Icon(Icons.paypal, color: Colors.blueAccent, size: 28),
              value: 'PayPal',
            ),
            _buildPaymentOption(
              title: 'Google Pay',
              leadingIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'G', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 24)),
                        TextSpan(text: 'o', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
                        TextSpan(text: 'o', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 24)),
                        TextSpan(text: 'g', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 24)),
                        TextSpan(text: 'l', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 24)),
                        TextSpan(text: 'e', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
                      ]
                    ),
                  )
                ],
              ),
              value: 'Google Pay',
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.heading3.copyWith(color: Colors.black)),
                Text('\$725', style: AppTextStyles.heading3.copyWith(color: Colors.black)),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB39256),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Payment Successful!'),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  'PAY NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? subtitle,
    required Widget leadingIcon,
    required String value,
  }) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFC1A46A), // Darker gold to match screenshot more closely
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            leadingIcon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.circle : Icons.circle_outlined,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
