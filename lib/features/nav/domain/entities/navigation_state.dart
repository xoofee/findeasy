import 'package:easyroute/easyroute.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required String voiceText,
    required double distanceToNextTurn,
    required bool deviated,
    required IndoorInstruction currentInstruction,
  }) = _NavigationState;
}
