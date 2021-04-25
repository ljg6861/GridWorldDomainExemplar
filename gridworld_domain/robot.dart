import 'dart:math';

import 'gridworld_tile.dart';
import 'obstacle.dart';

enum Direction { up, down, left, right }

enum RandomStatus { clockwise, counterclockwise, breakdown }

class Robot {
  GridWorldTile _currentTile;

  GridWorldTile get currentTile => this._currentTile;

  void updateCurrentTile(GridWorldTile newTile) {
    if (_currentTile != null) {
      _currentTile.hasRobot = false;
    }
    newTile.hasRobot = true;
    this._currentTile = newTile;
  }

  //returns reward
  int moveFromCurrentTileInDirection(Direction direction) {
    GridWorldTile nextTile;
    switch (direction) {
      case Direction.up:
        nextTile = this._currentTile.topNode;
        break;
      case Direction.down:
        nextTile = this._currentTile.bottomNode;
        break;
      case Direction.left:
        nextTile = this._currentTile.leftNode;
        break;
      case Direction.right:
        nextTile = this._currentTile.rightNode;
        break;
    }
    if (nextTile != null && !(nextTile is Obstacle)) {
      updateCurrentTile(nextTile);
      if (nextTile.state == 21) {
        return -10;
      }
      if (nextTile.state == 23) {
        return 10;
      }
      return 0;
    } else {
      return -10;
    }
  }

  //returns reward
  List randomlyAdvanceToTile(Random random) {
    final mappedStatusAndDirection = getStatusAndDirection(random);
    final randomStatus = mappedStatusAndDirection['status'];
    Direction direction = mappedStatusAndDirection['direction'];
    if (randomStatus == RandomStatus.breakdown) {
      return [-10 + this._currentTile.state == 21 ? -10 : 0, direction];
    }
    if (randomStatus != null) {
      direction = switchDirectionBasedOnStatus(direction, randomStatus);
    }
    return [moveFromCurrentTileInDirection(direction), direction];
  }

  Direction switchDirectionBasedOnStatus(Direction direction, RandomStatus status) {
    Direction returnDirection;
    if (status == RandomStatus.counterclockwise) {
      switch (direction) {
        case Direction.up:
          returnDirection = Direction.left;
          break;
        case Direction.left:
          returnDirection = Direction.down;
          break;
        case Direction.down:
          returnDirection = Direction.right;
          break;
        case Direction.right:
          returnDirection = Direction.up;
          break;
      }
    } else {
      //clockwise
      switch (direction) {
        case Direction.up:
          returnDirection = Direction.right;
          break;
        case Direction.right:
          returnDirection = Direction.down;
          break;

        case Direction.down:
          returnDirection = Direction.left;
          break;

        case Direction.left:
          returnDirection = Direction.up;
          break;
      }
    }
    return returnDirection;
  }

  Map getStatusAndDirection(Random random) {
    double randomDirectionNumber = random.nextDouble();
    Direction direction;
    if (randomDirectionNumber <= 0.25) {
      direction = Direction.left;
    } else if (randomDirectionNumber > 0.25 && randomDirectionNumber <= 0.5) {
      direction = Direction.right;
    } else if (randomDirectionNumber > 0.5 && randomDirectionNumber <= 0.75) {
      direction = Direction.down;
    } else {
      direction = Direction.up;
    }
    double randomStatusNumber = random.nextDouble();
    RandomStatus randomStatus;
    if (randomStatusNumber <= 0.05) {
      randomStatus = RandomStatus.clockwise;
    } else if (randomStatusNumber > 0.05 && randomStatusNumber <= 0.10) {
      randomStatus = RandomStatus.counterclockwise;
    } else if (randomStatusNumber > 0.1 && randomStatusNumber <= 0.2) {
      randomStatus = RandomStatus.breakdown;
    }
    return {'status': randomStatus, 'direction': direction};
  }

  double computeStateValue(GridWorldTile tile, Map<String, Map<GridWorldTile, int>> transits,
      Map<String, double> rewards, Map<GridWorldTile, double> values, Direction direction) {
    Map<GridWorldTile, int> targetCount = transits[tile.state.toString() + direction.toString()];
    Iterable<int> valuesIterable = targetCount.values;
    int total = 0;
    valuesIterable.toList().forEach((element) {
      total += element;
    });
    double value = 0;
    targetCount.entries.forEach((mapEntry) {
      GridWorldTile targetTile = mapEntry.key;
      double reward = rewards[tile.state.toString() + direction.toString() + targetTile.state.toString()];
      double compute = reward + 0.5 * values[targetTile];
      value += (mapEntry.value / total) * compute;
    });
    return value;
  }

  double optimallyAdvanceToTile(Map<String, Map<GridWorldTile, int>> transits,
      Map<String, double> rewards, Map<GridWorldTile, double> values,){
    Direction bestDirection = null;
    double bestValue = double.negativeInfinity;
    Direction.values.forEach((direction) {
      double stateValue = computeStateValue(this._currentTile, transits, rewards, values, direction);
      if (stateValue > bestValue){
        bestValue = stateValue;
        bestDirection = direction;
      }
    });
    final mappedStatusAndDirection = getStatusAndDirection(Random());
    final randomStatus = mappedStatusAndDirection['status'];
    if (randomStatus == RandomStatus.breakdown) {
      return -10;
    }
    if (randomStatus != null) {
      bestDirection = switchDirectionBasedOnStatus(bestDirection, randomStatus);
    }
    return this.moveFromCurrentTileInDirection(bestDirection).toDouble();
  }
}
