import 'gridworld_tile.dart';

class Obstacle extends GridWorldTile {
  Obstacle(GridWorldTile leftNode, GridWorldTile rightNode, GridWorldTile topNode, GridWorldTile bottomNode)
      : super(leftNode, rightNode, topNode, bottomNode, null);
}
