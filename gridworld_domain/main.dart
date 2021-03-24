import 'dart:math';
import 'gridworld_tile.dart';
import 'obstacle.dart';
import 'robot.dart';

void main(){
  List<GridWorldTile> tiles = createTiles();
  Robot robot = new Robot();
  robot.updateCurrentTile(tiles[0]);
  runRandomSimulation(robot, tiles);
}

List<GridWorldTile> createTiles(){
  List<GridWorldTile> tiles = [];
  int state = 1;
  for (int i = 0; i < 25; i++){
    GridWorldTile newTile;
    if (i == 12 || i == 17) {
      newTile = Obstacle(i % 5 == 0 ? null : tiles[i - 1], null, i > 5 ? tiles[i - 5] : null, null);
    } else{
      newTile = GridWorldTile(i % 5 == 0 ? null : tiles[i - 1], null, i > 5 ? tiles[i - 5] : null, null, state);
      state += 1;
    }
    tiles.add(newTile);
    //add this tile as right node of previous tile
    if (i % 5 != 0){
      tiles[i - 1].rightNode = newTile;
    }
    //add this tile as bottom node of above tile
    if (i > 5){
      tiles[i-5].bottomNode = newTile;
    }
  }
  return tiles;
}

void runRandomSimulation(Robot robot, List<GridWorldTile> tiles){
  final random = new Random();
  List<double> totalRewards = [];
  for (int i = 0; i < 10000; i++){
    int iterations = 0;
    int total = 0;
    while (true){
      iterations += 1;
      int reward = robot.randomlyAdvanceToTile(random);
      total += reward;
      //end state
      if (robot.currentTile.state == 23){
        robot.updateCurrentTile(tiles[0]);
        totalRewards.add(total/iterations);
        break;
      }
    }
  }
  calculateRandomData(totalRewards);
}

void calculateRandomData(List<double> totalStatesVisited){
  //mean
  double mean;
  double total = 0;
  totalStatesVisited.forEach((element) {
    total += element;
  });
  mean = total/totalStatesVisited.length;
  print(mean);
}
