import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';
import 'package:latlong2/latlong.dart';

/// Widget for displaying a POI marker on the map
class PoiMarkerWidget extends ConsumerWidget {
  final Poi poi;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final bool showLabel;

  const PoiMarkerWidget({
    super.key,
    required this.poi,
    this.isSelected = false,
    this.onTap,
    this.size = 24.0,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getPoiColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.white,
                width: isSelected ? 3.0 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getPoiIcon(),
              color: Colors.white,
              size: size * 0.6,
            ),
          ),
          if (showLabel && poi.name.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                poi.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getPoiIcon() {
    if (poi.type == PoiType.parkingSpace) return Icons.local_parking;
    if (poi.type == PoiType.shop) return Icons.shopping_bag;
    if (poi.type == PoiType.elevator) return Icons.elevator;
    if (poi.type == PoiType.toilet) return Icons.wc;
    if (poi.type == PoiType.stairs) return Icons.stairs;
    if (poi.type == PoiType.escalator) return Icons.escalator;
    if (poi.type == PoiType.entrance || poi.type == PoiType.exit) return Icons.door_front_door;
    return Icons.location_on;
  }

  Color _getPoiColor() {
    if (poi.type == PoiType.parkingSpace) return Colors.blue;
    if (poi.type == PoiType.shop) return Colors.purple;
    if (poi.type == PoiType.elevator) return Colors.orange;
    if (poi.type == PoiType.toilet) return Colors.teal;
    if (poi.type == PoiType.stairs) return Colors.brown;
    if (poi.type == PoiType.escalator) return Colors.indigo;
    if (poi.type == PoiType.entrance || poi.type == PoiType.exit) return Colors.green;
    return Colors.grey;
  }
}