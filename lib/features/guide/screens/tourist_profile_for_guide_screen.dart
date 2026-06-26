// // ============================================================
// //  tourist_profile_for_guide_screen.dart
// //  Tourist Profile Screen — as seen by the Guide
// // ============================================================

// import 'package:flutter/material.dart';
// import 'package:kemit_get_it/features/guide/models/all.dart';

// // TODO: import your chat screen when navigating via "Chat With"
// // import 'package:kemit_get_it/features/guide/screens/guide_chat_screen.dart';

// class TouristProfileForGuideScreen extends StatefulWidget {
//   /// The tourist's ID — used to fetch full profile from backend.
//   final String touristId;

//   /// Optional: pass a pre-loaded profile to skip the loading state
//   /// (e.g. when navigating from a list that already has basic info).
//   final TouristProfileModel? preloadedProfile;

//   const TouristProfileForGuideScreen({
//     super.key,
//     required this.touristId,
//     this.preloadedProfile,
//   });

//   @override
//   State<TouristProfileForGuideScreen> createState() =>
//       _TouristProfileForGuideScreenState();
// }

// class _TouristProfileForGuideScreenState
//     extends State<TouristProfileForGuideScreen> {
//   // ── State ────────────────────────────────────────────────
// TouristProfileModel? _profile;
//   bool _isLoading = true;

//   // ── Palette ──────────────────────────────────────────────
//   static const _kGold = Color(0xFFB9975B);
//   static const _kDark = Color(0xFF1A1A1A);
//   static const _kGrey = Color(0xFF9E9E9E);
//   static const _kCardBg = Color(0xFFF5F5F5);

//   // ── Lifecycle ────────────────────────────────────────────
//   @override
// void initState() {
//   super.initState();

//   if (widget.preloadedProfile != null) {
//     _profile = widget.preloadedProfile;
//     _isLoading = false;
//   } else {
//     _fetchProfile();
//   }
// }

//   // ── Data ─────────────────────────────────────────────────
//   Future<void> _fetchProfile() async {
//   try {
//     final profile = await TouristRepository.getProfile(
//       widget.touristId,
//     );

//     if (!mounted) return;

//     setState(() {
//       _profile = profile;
//       _isLoading = false;
//     });
//   } catch (e) {
//     if (!mounted) return;

//     setState(() {
//       _isLoading = false;
//     });
//   }
// }
//   // ── Navigation ───────────────────────────────────────────
//   void _onChatWith() {
//     // TODO: navigate to guide chat screen, e.g.:
//     // Navigator.push(context, MaterialPageRoute(
//     //   builder: (_) => GuideChatScreen(
//     //     guideId: <your-guide-id>,
//     //     conversation: GuideChatConversation(
//     //       conversationId: ...,
//     //       touristId: widget.touristId,
//     //       touristName: _profile!.name,
//     //       touristAvatarUrl: _profile!.avatarUrl,
//     //     ),
//     //   ),
//     // ));
//   }

//   // ── Build ────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _profile == null
//               ? const Center(child: Text('Profile not found'))
//               : _buildBody(),
//     );
//   }

//   // ── AppBar ────────────────────────────────────────────────
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: const BackButton(color: _kDark),
//       centerTitle: true,
//       title: const Text(
//         'Profile',
//         style: TextStyle(
//           color: _kDark,
//           fontWeight: FontWeight.w700,
//           fontSize: 18,
//         ),
//       ),
//     );
//   }

//   // ── Body ─────────────────────────────────────────────────
//   Widget _buildBody() {
//     final p = _profile!;
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//       child: Column(
//         children: [
//           // ── Avatar ────────────────────────────────────────
//           _buildAvatar(p),
//           const SizedBox(height: 16),

//           // ── Name ──────────────────────────────────────────
//           Text(
//             p.name,
//             style: const TextStyle(
//               color: _kDark,
//               fontWeight: FontWeight.w700,
//               fontSize: 22,
//             ),
//           ),
//           const SizedBox(height: 4),

//           // ── Email ─────────────────────────────────────────
//           Text(
//             p.email,
//             style: const TextStyle(
//               color: _kGrey,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 24),

//           // ── Chat With button ───────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _onChatWith,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _kGold,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 0,
//               ),
//               child: const Text(
//                 'Chat With',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // ── Info cards grid ────────────────────────────────
//           _buildInfoGrid(p),
//           const SizedBox(height: 20),

//           // ── Interests ─────────────────────────────────────
//           if (p.interests.isNotEmpty) _buildInterests(p.interests),
//         ],
//       ),
//     );
//   }

//   // ── Avatar ────────────────────────────────────────────────
//   Widget _buildAvatar(TouristProfileForGuide p) {
//     return CircleAvatar(
//       radius: 54,
//       backgroundColor: _kGold.withOpacity(0.12),
//       backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
//       child: p.avatarUrl == null
//           ? Text(
//               p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
//               style: const TextStyle(
//                 fontSize: 40,
//                 fontWeight: FontWeight.bold,
//                 color: _kGold,
//               ),
//             )
//           : null,
//     );
//   }

//   // ── Info grid ─────────────────────────────────────────────
//   Widget _buildInfoGrid(TouristProfileForGuide p) {
//     final items = <_InfoItem>[
//       if (p.phone != null)
//         _InfoItem(icon: Icons.phone_outlined, label: 'Phone', value: p.phone!),
//       if (p.language != null)
//         _InfoItem(
//             icon: Icons.language_outlined,
//             label: 'Language',
//             value: p.language!),
//       if (p.nationality != null)
//         _InfoItem(
//             icon: Icons.public_outlined,
//             label: 'Nationality',
//             value: p.nationality!),
//       if (p.age != null)
//         _InfoItem(
//             icon: Icons.cake_outlined,
//             label: 'Age',
//             value: p.age!.toString()),
//     ];

//     if (items.isEmpty) return const SizedBox.shrink();

//     // Build rows of 2
//     final rows = <Widget>[];
//     for (int i = 0; i < items.length; i += 2) {
//       final left = items[i];
//       final right = i + 1 < items.length ? items[i + 1] : null;
//       rows.add(
//         Row(
//           children: [
//             Expanded(child: _buildInfoCard(left)),
//             const SizedBox(width: 12),
//             Expanded(
//               child: right != null
//                   ? _buildInfoCard(right)
//                   : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       );
//       if (i + 2 < items.length) rows.add(const SizedBox(height: 12));
//     }

//     return Column(children: rows);
//   }

//   Widget _buildInfoCard(_InfoItem item) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       decoration: BoxDecoration(
//         color: _kCardBg,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(item.icon, color: _kGold, size: 20),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.label,
//                   style: const TextStyle(
//                     color: _kGold,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   item.value,
//                   style: const TextStyle(
//                     color: _kDark,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Interests ─────────────────────────────────────────────
//   Widget _buildInterests(List<String> interests) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _kCardBg,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: const [
//               Icon(Icons.interests_outlined, color: _kGold, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Interests',
//                 style: TextStyle(
//                   color: _kGold,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: interests
//                 .map(
//                   (tag) => Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: const Color(0xFFE0E0E0)),
//                     ),
//                     child: Text(
//                       tag,
//                       style: const TextStyle(
//                         color: _kDark,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Helper ────────────────────────────────────────────────────
// class _InfoItem {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoItem({required this.icon, required this.label, required this.value});
// }
