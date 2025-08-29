/*

see
- https://github.com/organicmaps/organicmaps/blob/ba879764383d7cfb04017a29e4228e7e6db531be/android/app/src/main/java/app/organicmaps/routing/NavigationService.java

https://github.com/organicmaps/organicmaps/blob/ba879764383d7cfb04017a29e4228e7e6db531be/android/app/src/main/java/app/organicmaps/sdk/routing/RoutingController.java

*/


import 'package:easyroute/easyroute.dart';
import 'package:findeasy/features/nav/domain/services/map_animation_service.dart';


// class RealtimeInstruction {
//   final bool deviated;
//   final String voiceText;
//   final double distance;
//   final IndoorInstruction currentInstruction;

//   RealtimeInstruction({
//     required this.deviated,
//     required this.voiceText,
//     required this.distance,
//     required this.currentInstruction,
//   });
// }

class NavigationService {
  MapRoute? _mapRoute;
  int currentInstructionIndex = 0;
  final MapAnimationService mapAnimationService;

  IndoorInstruction get currentInstruction => _mapRoute!.indoorInstructions[currentInstructionIndex];

  NavigationService(this.mapAnimationService);

  String startNavigation(MapRoute mapRoute) {
    _mapRoute = mapRoute;

    currentInstructionIndex = 0;
    final originPoi = _mapRoute!.originPoi;
    final originPoiType = originPoi.type;

    String originSide = '';
    if (currentInstruction.currentTurnDirection == TurnDirection.turnLeft) {
      originSide = '左邊';
    } else if (currentInstruction.currentTurnDirection == TurnDirection.turnRight) {
      originSide = '右邊';
    } else if (currentInstruction.currentTurnDirection == TurnDirection.turnSlightlyLeft) {
      originSide = '左邊';
    } else if (currentInstruction.currentTurnDirection == TurnDirection.turnSlightlyRight) {
      originSide = '右邊';
    } else if (currentInstruction.currentTurnDirection == TurnDirection.turnSharpLeft) {
      originSide = '左邊';
    } else if (currentInstruction.currentTurnDirection == TurnDirection.turnSharpRight) {
      originSide = '右邊';
    } else if (currentInstruction.currentPoiSide == PointSide.left) {
      originSide = '左邊';
    } else if (currentInstruction.currentPoiSide == PointSide.right) {
      originSide = '右邊';
    } else{
      originSide = '附近';  // TODO: should throw error, at least log
    }

    final textBeforeNextIntruction = currentInstruction.nextPoiLandmark == null ? '然後' : '看到${currentInstruction.nextPoiLandmark?.name}時';

    // text example: 請向前走，確認車位C166在您的左邊. 直行30米, 看到C159時右轉
    return'請向前走，確認${originPoiType.chineseName}${originPoi.name}在您的${originSide}. 直行${currentInstruction.distanceToNextTurn.round()}米, ${textBeforeNextIntruction}${currentInstruction.nextTurnDirection.chineseInstruction}';
  }

  // RealtimeInstruction updatePosition(Poi poi) {

  //   // final deviated = dis

  //   // project poi to the route

  //   final projectResult = projectPointToIndoorInstruction(poi, instructions);

  //   // return RealtimeInstruction(deviated: deviated, voiceText: voiceText, distance: distance, currentInstruction: currentInstruction);
  // }

  // the first and last instruction should not be considered: the segment betweenoriginPoi and snapped point should not be included. 
  void updatePosition(Poi poi) {
    List<IndoorInstruction> instructionsAtPoiLevel = poi.level == _mapRoute!.originLevel ? _mapRoute!.indoorInstructionsAtOriginLevel! : _mapRoute!.indoorInstructionsAtDestinationLevel!;

    final (distanceToRoute: distanceToRoute, projectedInstructionIndex: projectedInstructionIndex, doubledistanceToNextInstruction: doubledistanceToNextInstruction, pointSide: pointSide) = projectPointToIndoorInstruction(poi.position, instructionsAtPoiLevel);

    const maxDistanceToRoute = 10.0;
    if (distanceToRoute > maxDistanceToRoute) {
      print('too far from the route: $distanceToRoute > $maxDistanceToRoute');
      // TODO: throw error
      return;
    }

    if (projectedInstructionIndex == currentInstructionIndex) {
      // TODO: throw error
    }

  }

  void _updateCurrentInstructionIndex(int index) {
    if (index < 0 || index >= _mapRoute!.indoorInstructions.length) {
      throw ArgumentError('Index out of bounds');
    }
    currentInstructionIndex = index;
  }



}


