// import 'package:flutter/material.dart';
// import 'package:kemit_get_it/features/guide/models/all.dart';

// class TouristTripDetailsView extends StatefulWidget {
//   final TripDetailsModel trip;
//   const TouristTripDetailsView({super.key, required this.trip});

//   @override
//   State<TouristTripDetailsView> createState() => _TouristTripDetailsViewState();
// }

// class _TouristTripDetailsViewState extends State<TouristTripDetailsView> {
//   bool isPaid = false;

//   @override
//   Widget build(BuildContext context) {
//     final trip = widget.trip;
//     final tourist =
//         trip.pendingRequests.isNotEmpty ? trip.pendingRequests[0] : null;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Trip Details",
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Tourist Info Row ──
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundImage: AssetImage(
//                     tourist?.image ?? "lib/features/guide/images/i (2).webp",
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       tourist?.name ?? "Tourist",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     GestureDetector(
//                       onTap: () {},
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFB9975B),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text(
//                           "View Profile",
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Spacer(),

//                 // ── Status Badge ──
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isPaid ? Colors.green : Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (isPaid) ...[
//                         const Icon(Icons.circle, color: Colors.white, size: 8),
//                         const SizedBox(width: 4),
//                       ],
//                       Text(
//                         isPaid ? "Paid" : "Pending",
//                         style: TextStyle(
//                           color: isPaid ? Colors.white : Colors.black54,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ── Trip Places Cards ──
//             ...trip.itinerary.map(
//               (item) => Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.horizontal(
//                         left: Radius.circular(12),
//                       ),
//                       child: Image.asset(
//                         trip.image,
//                         width: 90,
//                         height: 80,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item.dayTitle.replaceAll(
//                                 RegExp(r'Day \d+ : '),
//                                 '',
//                               ),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             Text(
//                               item.description,
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             RichText(
//                               text: const TextSpan(
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.black,
//                                 ),
//                                 children: [
//                                   TextSpan(
//                                     text: "Price   ",
//                                     style: TextStyle(color: Colors.grey),
//                                   ),
//                                   TextSpan(text: "Around 7\$"),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // ── Details Section ──
//             const Text(
//               "Details",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "Travel Type",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 const Icon(Icons.person_outline, size: 16),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   tourist?.info.split('•')[0].trim() ?? "Solo",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             Text(
//                               "Languages",
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             SizedBox(height: 6),
//                             Text(
//                               "English",
//                               style: TextStyle(fontWeight: FontWeight.w500),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Additional Services",
//                     style: TextStyle(color: Colors.grey, fontSize: 13),
//                   ),
//                   const SizedBox(height: 6),
//                   const Text(
//                     "Meals included , Accommodation",
//                     style: TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ── Dates ──
//             _buildDateRow("Start Date", trip.date.split(' - ')[0]),
//             const SizedBox(height: 10),
//             _buildDateRow(
//               "End Date",
//               trip.date.split(' - ').length > 1
//                   ? trip.date.split(' - ')[1]
//                   : "",
//             ),

//             const SizedBox(height: 28),

//             // ── Cancel Trip Button (تظهر بس لو مش Paid) ──
//             if (!isPaid)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // handle cancel logic
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB9975B),
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     "Cancel Trip",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDateRow(String label, String date) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 100,
//           child: Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(date, style: const TextStyle(fontSize: 14)),
//         ),
//       ],
//     );
//   }
// }
