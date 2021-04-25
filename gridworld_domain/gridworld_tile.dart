import 'dart:math';

import 'robot.dart';

class GridWorldTile{
  final GridWorldTile leftNode;
  GridWorldTile rightNode;
  final GridWorldTile topNode;
  Direction bestDirection;
  GridWorldTile bottomNode;
  final int state;
  bool hasRobot = false;
  double value = Random().nextDouble();

  GridWorldTile(this.leftNode, this.rightNode, this.topNode, this.bottomNode, this.state);
}