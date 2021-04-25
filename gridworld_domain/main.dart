import 'dart:math';
import 'gridworld_tile.dart';
import 'obstacle.dart';
import 'robot.dart';

void main() {
  List<GridWorldTile> tiles = createTiles();
  Robot robot = new Robot();
  robot.updateCurrentTile(tiles[0]);
  runRandomSimulation(robot, tiles);
}

List<GridWorldTile> createTiles() {
  List<GridWorldTile> tiles = [];
  int state = 1;
  for (int i = 0; i < 25; i++) {
    GridWorldTile newTile;
    if (i == 12 || i == 17) {
      newTile = Obstacle(i % 5 == 0 ? null : tiles[i - 1], null, i > 5 ? tiles[i - 5] : null, null);
    } else {
      newTile = GridWorldTile(i % 5 == 0 ? null : tiles[i - 1], null, i > 5 ? tiles[i - 5] : null, null, state);
      state += 1;
    }
    if (i == 24) {
      newTile.value = 1;
    }
    tiles.add(newTile);
    //add this tile as right node of previous tile
    if (i % 5 != 0) {
      tiles[i - 1].rightNode = newTile;
    }
    //add this tile as bottom node of above tile
    if (i > 5) {
      tiles[i - 5].bottomNode = newTile;
    }
  }
  return tiles;
}

void runRandomSimulation(Robot robot, List<GridWorldTile> tiles) {
  final random = new Random();
  Map<String, double> rewards = {};
  Map<String, Map<GridWorldTile, int>> transits = {};
  Map<GridWorldTile, double> values = {};
  tiles.forEach((tile) {
    values[tile] = tile.value;
  });
  List<List<double>> totalRewards = [];
  for (int i = 0; i < 10000; i++) {
    List<double> rewardForIteration = [];
    while (true) {
      GridWorldTile initialTile = robot.currentTile;
      List rewardAndDirection = robot.randomlyAdvanceToTile(random);
      double reward = (rewardAndDirection[0] as int).toDouble();
      Direction direction = rewardAndDirection[1];
      GridWorldTile endTile = robot.currentTile;
      String rewardsKey = initialTile.state.toString() + direction.toString() + endTile.state.toString();
      rewards[rewardsKey] = reward;
      String transitsKey = initialTile.state.toString() + direction.toString();
      if (transits[transitsKey] == null) {
        transits[transitsKey] = {};
      }
      int timesPreviousDone = transits[transitsKey][endTile] ?? 0;
      transits[transitsKey][endTile] = timesPreviousDone + 1;
      rewardForIteration.add(reward);
      //end state
      if (robot.currentTile.state == 23) {
        robot.updateCurrentTile(tiles[0]);
        totalRewards.add(rewardForIteration);
        break;
      }
    }
  }
  calculateData(totalRewards);


  for (int i = 0; i < 100; i++) {
    tiles.forEach((tile) {
      if (!(tile is Obstacle)) {
        if (tile.state != 23) {
          double max = double.negativeInfinity;
          Direction bestDirection = null;
          Direction.values.forEach((direction) {
            double stateValue = robot.computeStateValue(tile, transits, rewards, values, direction);
            if (stateValue > max) {
              bestDirection = direction;
              max = stateValue;
            }
          });
          tile.bestDirection = bestDirection;
          if (i == 99) {
            print('tile: ' + tile.state.toString() + ' best direction = ' + bestDirection.toString());
          }
          values[tile] = max;
        }
      }
    });
  }

  List<List<double>> totalOptimalRewards = [];
  for (int i = 0; i < 10000; i++){
    List<double> rewardForIteration = [];
    while(true){
      rewardForIteration.add(robot.optimallyAdvanceToTile(transits, rewards, values));
      if (robot.currentTile.state == 23){
        robot.updateCurrentTile(tiles[0]);
        totalOptimalRewards.add(rewardForIteration);
        break;
      }
    }
  }

  calculateData(totalOptimalRewards);

}

void calculateData(List<List<double>> listedRewardData) {
  double mean;
  double max = double.negativeInfinity;
  double min = double.infinity;
  double discountFactor = 0.5;
  double totalDiscountedReward = 0;
  List<double> iteratedRewardTotal = [];
  listedRewardData.forEach((rewardPerIterationList) {
    double iteratedDiscountedReward = 0;
    for (int i = 0; i < rewardPerIterationList.length - 1; i++) {
      iteratedDiscountedReward += pow(discountFactor, i) * (rewardPerIterationList[i + 1]);
    }
    totalDiscountedReward += iteratedDiscountedReward;
    iteratedRewardTotal.add(iteratedDiscountedReward);
    if (iteratedDiscountedReward < min) {
      min = iteratedDiscountedReward;
    }
    if (iteratedDiscountedReward > max) {
      max = iteratedDiscountedReward;
    }
  });
  mean = totalDiscountedReward / listedRewardData.length;
  double standardDeviation;
  double totalOfDifferences = 0;
  for (int i = 0; i < iteratedRewardTotal.length; i++) {
    double reward = iteratedRewardTotal[i];
    double workingNumber = pow(reward - mean, 2);
    totalOfDifferences += workingNumber;
  }
  standardDeviation = sqrt(totalOfDifferences / iteratedRewardTotal.length);
  print('mean: ' + mean.toString());
  print('max: ' + max.toString());
  print('min: ' + min.toString());
  print('standard deviation: ' + standardDeviation.toString());
}
