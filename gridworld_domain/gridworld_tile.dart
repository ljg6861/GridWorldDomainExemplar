class GridWorldTile{
  final GridWorldTile leftNode;
  GridWorldTile rightNode;
  final GridWorldTile topNode;
  GridWorldTile bottomNode;
  final int state;
  bool hasRobot = false;

  GridWorldTile(this.leftNode, this.rightNode, this.topNode, this.bottomNode, this.state);
}