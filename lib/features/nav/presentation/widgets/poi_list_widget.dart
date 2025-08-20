// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:easyroute/easyroute.dart';
// import 'package:findeasy/features/nav/presentation/providers/navigation_providers.dart';

// /// Widget for displaying a list of POIs for the current level
// class PoiListWidget extends ConsumerWidget {
//   const PoiListWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pois = ref.watch(filteredPoisProvider);
//     final selectedPoi = ref.watch(selectedPoiProvider);
//     final searchQuery = ref.watch(poiSearchProvider);

//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search POIs...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//               onChanged: (value) {
//                 ref.read(poiSearchProvider.notifier).state = value;
//               },
//             ),
//           ),
//           // POI list
//           if (pois.isNotEmpty)
//             Container(
//               constraints: const BoxConstraints(maxHeight: 300),
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: pois.length,
//                 itemBuilder: (context, index) {
//                   final poi = pois[index];
//                   final isSelected = selectedPoi?.id == poi.id;
                  
//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: _getPoiColor(poi.type),
//                       child: Icon(
//                         _getPoiIcon(poi.type),
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                     title: Text(
//                       poi.name,
//                       style: TextStyle(
//                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                     subtitle: Text(
//                       poi.type.replaceAll('amenity:', '').replaceAll('shop:', ''),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                     trailing: isSelected
//                         ? const Icon(Icons.check_circle, color: Colors.blue)
//                         : null,
//                     onTap: () {
//                       ref.read(selectedPoiProvider.notifier).state = poi;
//                     },
//                   );
//                 },
//               ),
//             )
//           else
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(
//                 searchQuery.isEmpty ? 'No POIs found' : 'No POIs match your search',
//                 style: TextStyle(color: Colors.grey[600]),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   IconData _getPoiIcon(String type) {
//     if (type.contains('parking_space')) return Icons.local_parking;
//     if (type.contains('shop')) return Icons.shopping_bag;
//     if (type.contains('elevator')) return Icons.elevator;
//     if (type.contains('toilet')) return Icons.wc;
//     if (type.contains('stairs')) return Icons.stairs;
//     if (type.contains('escalator')) return Icons.escalator;
//     if (type.contains('entrance')) return Icons.door_front_door;
//     if (type.contains('exit')) return Icons.exit_to_app;
//     return Icons.location_on;
//   }

//   Color _getPoiColor(String type) {
//     if (type.contains('parking_space')) return Colors.blue;
//     if (type.contains('shop')) return Colors.purple;
//     if (type.contains('elevator')) return Colors.orange;
//     if (type.contains('toilet')) return Colors.teal;
//     if (type.contains('stairs')) return Colors.brown;
//     if (type.contains('escalator')) return Colors.indigo;
//     if (type.contains('entrance') || type.contains('exit')) return Colors.green;
//     return Colors.grey;
//   }
// }