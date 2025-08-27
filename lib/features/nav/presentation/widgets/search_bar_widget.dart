import 'package:findeasy/features/nav/presentation/providers/map_providers.dart';
import 'package:findeasy/features/nav/presentation/widgets/system_menu_button.dart';
import 'package:findeasy/features/nav/presentation/widgets/poi_search_input.dart';
import 'package:findeasy/features/nav/presentation/widgets/search_results_widget.dart';
import 'package:findeasy/features/nav/presentation/widgets/voice_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easyroute/easyroute.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final ValueChanged<Poi>? onPoiSelected;
  final bool showResults;

  const SearchBarWidget({
    super.key,
    this.onPoiSelected,
    this.showResults = true,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    final currentPlace = ref.watch(currentPlaceProvider);
    late String hintText;
    if (currentPlace == null) {
      hintText = '當前位置不支持';
    } else {
      hintText = '查找車位、店鋪 (${currentPlace.name})'; // not easy to make the place name bold
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input container with integrated POI search
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                // Search icon
                Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 26,
                ),
                // const SizedBox(width: 12),
                
                // POI Search Input (replaces the old TextField)
                Expanded(
                  child: PoiSearchInput(
                    hintText: hintText,
                    onPoiSelected: widget.onPoiSelected,
                    onCleared: () {
                      // Clear search when needed
                    },
                    showBorder: false,
                  ),
                ),
                
                const VoiceButton(),
                const SystemMenuButton(),
              ],
            ),
          ),
        ),
        
        // Search results (show below search bar)
        if (widget.showResults)
          SearchResultsWidget(
            showActionButtons: true,
            onPoiSelected: widget.onPoiSelected,
          ),
      ],
    );
  }
}
