import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kemit_get_it/features/guide/core/verification_service.dart';
import 'package:kemit_get_it/features/guide/screens/main_screen.dart';
import 'package:kemit_get_it/routes/app_routes.dart';

// ── Enum يمثّل كل حالات التحقق ──────────────────────────────────────────────
enum VerificationStatus { notSubmitted, pending, rejected, approved }

VerificationStatus parseVerificationStatus(String raw) {
  switch (raw.toLowerCase()) {
    case 'pending':
      return VerificationStatus.pending;
    case 'approved':
      return VerificationStatus.approved;
    case 'rejected':
      return VerificationStatus.rejected;
    default:
      return VerificationStatus.notSubmitted;
  }
}

// ── الشاشة الرئيسية ──────────────────────────────────────────────────────────
class ProfileVerificationScreen extends StatefulWidget {
  /// يتبعت من الـ Profile API أو Login response
  final String verificationStatusRaw;

  /// سبب الرفض — بييجي من الـ API لو الحالة Rejected
  final String? rejectionReason;

  const ProfileVerificationScreen({
    super.key,
    required this.verificationStatusRaw,
    this.rejectionReason,
  });

  @override
  State<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen> {
  late VerificationStatus _status;

  @override
  void initState() {
    super.initState();
    _status = parseVerificationStatus(widget.verificationStatusRaw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: switch (_status) {
        VerificationStatus.notSubmitted => _SubmitFormView(
          onSubmitSuccess:
              () => setState(() => _status = VerificationStatus.pending),
        ),
        VerificationStatus.pending => const _PendingView(),
        VerificationStatus.rejected => _RejectedView(
          reason: widget.rejectionReason,
          onResubmitSuccess:
              () => setState(() => _status = VerificationStatus.pending),
        ),
        VerificationStatus.approved => const _ApprovedView(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1️⃣  NotSubmitted — فورم الرفع
// ══════════════════════════════════════════════════════════════════════════════
class _SubmitFormView extends StatefulWidget {
  final VoidCallback onSubmitSuccess;
  const _SubmitFormView({required this.onSubmitSuccess});

  @override
  State<_SubmitFormView> createState() => _SubmitFormViewState();
}

class _SubmitFormViewState extends State<_SubmitFormView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();
  final _regionsController = TextEditingController();

  final List<String> _allSpecializations = [
    "Historical",
    "Adventure",
    "Cultural",
  ];
  final List<String> _selectedSpecializations = [];

  File? _idImage;
  File? _personalImage;

  final _picker = ImagePicker();
  bool _isPicking = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _regionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isId) async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isId) {
            _idImage = File(image.path);
          } else {
            _personalImage = File(image.path);
          }
        });
      }
    } catch (_) {
      _showSnack("Failed to pick image");
    } finally {
      _isPicking = false;
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecializations.isEmpty) {
      _showSnack("Please select at least one specialization");
      return;
    }
    if (_idImage == null || _personalImage == null) {
      _showSnack("Please upload all documents");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GuideVerificationService.submitVerification(
        phone: _phoneController.text,
        bio: _bioController.text,
        specializations: _selectedSpecializations,
        workingRegions:
            _regionsController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
        idCardFilePath: _idImage!.path,
        personalPhotoFilePath: _personalImage!.path,
      );
      setState(() => _isLoading = false);
      widget.onSubmitSuccess();
      return;
    } catch (_) {
      setState(() => _isLoading = false);
      _showSnack("Submission failed. Please try again.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tell us more about you",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please provide the following information to complete your guide profile",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Phone
            _SectionLabel("Phone"),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration("Phone"),
              validator: (v) {
                if (v == null || v.isEmpty) return "Phone is required";
                if (v.length < 10) return "Invalid phone number";
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Specialization
            _SectionLabel("Specialization"),
            TextFormField(
              controller: _specializationController,
              readOnly: true,
              decoration: _inputDecoration("Select specializations below"),
              validator:
                  (v) =>
                      (v == null || v.isEmpty)
                          ? "Specialization is required"
                          : null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  _allSpecializations
                      .map(
                        (item) => ChoiceChip(
                          label: Text(
                            item,
                            style: const TextStyle(color: Colors.black),
                          ),
                          selected: _selectedSpecializations.contains(item),
                          selectedColor: const Color(0xFFB9975B),
                          backgroundColor: const Color(0xFFCCCCCC),
                          onSelected: (isSelected) {
                            setState(() {
                              isSelected
                                  ? _selectedSpecializations.add(item)
                                  : _selectedSpecializations.remove(item);
                              _specializationController
                                  .text = _selectedSpecializations.join(", ");
                            });
                          },
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 16),

            // Documents
            _SectionLabel("Verification Documents"),
            const SizedBox(height: 4),
            const Text(
              "Upload a clear photo of your ID card and a personal photo",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _UploadBox(
                    title: "Upload ID Card",
                    image: _idImage,
                    onTap: () => _pickImage(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UploadBox(
                    title: "Personal Photo",
                    image: _personalImage,
                    onTap: () => _pickImage(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio
            _SectionLabel("Professional Bio"),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell us about your background...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator:
                  (v) => (v == null || v.isEmpty) ? "Bio is required" : null,
            ),

            const SizedBox(height: 16),

            // Regions
            _SectionLabel("Favorite Working Regions"),
            TextFormField(
              controller: _regionsController,
              decoration: _inputDecoration("e.g. Cairo, Luxor"),
              validator:
                  (v) => (v == null || v.isEmpty) ? "Region is required" : null,
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB9975B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Submit For Verification",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2️⃣  Pending — في انتظار مراجعة الأدمن
// ══════════════════════════════════════════════════════════════════════════════
class _PendingView extends StatelessWidget {
  const _PendingView();

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      icon: Icons.hourglass_top_rounded,
      iconColor: const Color(0xFFB9975B),
      title: "Verification Under Review",
      subtitle:
          "Your documents have been submitted successfully.\nOur team will review your request and notify you once a decision is made.",
      badge: _StatusBadge(
        label: "Pending Review",
        color: const Color(0xFFFFF3CD),
        textColor: const Color(0xFF856404),
      ),
      extra: Column(
        children: [
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.guideHome,
                  ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9975B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Continue to App",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3️⃣  Rejected — مرفوض مع زر إعادة الرفع
// ══════════════════════════════════════════════════════════════════════════════
class _RejectedView extends StatelessWidget {
  final String? reason;
  final VoidCallback onResubmitSuccess;

  const _RejectedView({this.reason, required this.onResubmitSuccess});

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      icon: Icons.cancel_rounded,
      iconColor: Colors.red,
      title: "Verification Rejected",
      subtitle:
          "Unfortunately, your verification request was not approved. Please review the reason below and resubmit your documents.",
      badge: _StatusBadge(
        label: "Rejected",
        color: const Color(0xFFF8D7DA),
        textColor: const Color(0xFF842029),
      ),
      extra: Column(
        children: [
          if (reason != null && reason!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rejection Reason",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reason!,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ProfileVerificationScreen(
                            verificationStatusRaw: 'notSubmitted',
                            rejectionReason: null,
                          ),
                    ),
                  ).then((_) => onResubmitSuccess()),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                "Resubmit Documents",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB9975B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4️⃣  Approved — موافق عليه
// ══════════════════════════════════════════════════════════════════════════════
class _ApprovedView extends StatelessWidget {
  const _ApprovedView();

  @override
  Widget build(BuildContext context) {
    return _StatusLayout(
      icon: Icons.verified_rounded,
      iconColor: Colors.green,
      title: "You're Verified! 🎉",
      subtitle:
          "Your guide profile has been approved. You can now create trips, manage bookings, and use all guide features.",
      badge: _StatusBadge(
        label: "Approved",
        color: const Color(0xFFD1E7DD),
        textColor: const Color(0xFF0A3622),
      ),
      extra: Column(
        children: [
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                  ),
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text(
                "Start Creating Trips",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _StatusLayout extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final _StatusBadge badge;
  final Widget? extra;

  const _StatusLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 90, color: iconColor),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            badge,
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (extra != null) extra!,
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String title;
  final File? image;
  final VoidCallback onTap;

  const _UploadBox({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        child:
            image != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.upload_rounded,
                      color: Colors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
      ),
    );
  }
}

// ── Helper ───────────────────────────────────────────────────────────────────
InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
);

Widget _SectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
);
