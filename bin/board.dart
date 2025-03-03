import 'dart:io';
import 'dart:math';
import 'ship.dart';

class Board {
  final int size;
  late List<List<String>> board;
  List<Ship> ships = [];
  int nextShipId = 1;

  Board(this.size) {
    board = List.generate(size, (_) => List.filled(size, '.'));
  }

  void printBoard({bool showShips = false}) {
    stdout.write("   ");
    for (int i = 1; i <= size; i++) {
      stdout.write("$i ");
    }
    stdout.writeln();

    for (int i = 0; i < size; i++) {
      stdout.write("${String.fromCharCode(65 + i)}  ");
      for (int j = 0; j < size; j++) {
        if (showShips) {
          stdout.write("${board[i][j]} ");
        } else {
          if (board[i][j] == 'S') {
            stdout.write(". ");
          } else {
            stdout.write("${board[i][j]} ");
          }
        }
      }
      stdout.writeln();
    }
  }

  bool placeShip(int startRow, int startCol, int endRow, int endCol, int expectedLength) {
    // Определяем ориентацию по координатам начала и конца
    bool horizontal = startRow == endRow;
    bool vertical = startCol == endCol;

    if (!horizontal && !vertical) {
      print('\nВ этой игре корабли могут смотреть только на 4 стороны света. Ставте корабли либо горизонтально, либо вертикально');
      return false;
    }

    int actualLength;

    if (horizontal) {
      actualLength = (endCol - startCol).abs() + 1;
    } else {
      actualLength = (endRow - startRow).abs() + 1;
    }

    // Проверяем длину корабля
    if (actualLength != expectedLength) {
      print('Корабль по размерам не подошел. Я ждал, что длина будет: $expectedLength, А ты написал так, что получилось: $actualLength');
      return false;
    }

    // Проверяем валидность размещения (с использованием длины и координат)
    if (!isValidPlacement(startRow, startCol, actualLength, horizontal)) {
      return false;
    }

    // Размещаем корабль
    List<List<int>> shipCoordinates = [];
    if (horizontal) {
      int start = min(startCol, endCol); // Обеспечиваем правильное направление
      for (int i = 0; i < actualLength; i++) {
        board[startRow][start + i] = 'S';
        shipCoordinates.add([startRow, start + i]);
      }
    } else {
      int start = min(startRow, endRow); // Обеспечиваем правильное направление
      for (int i = 0; i < actualLength; i++) {
        board[start + i][startCol] = 'S';
        shipCoordinates.add([start + i, startCol]);
      }
    }

    // Создаем копию списка координат для originalCoordinates
    List<List<int>> originalShipCoordinates = shipCoordinates.map((coord) => List<int>.from(coord)).toList();

    Ship newShip = Ship(
      id: nextShipId,
      length: actualLength,
      originalCoordinates: originalShipCoordinates,  // Сохраняем копию здесь
      coordinates: shipCoordinates,
    );
    ships.add(newShip);
    nextShipId++;
    return true;
  }

  bool isValidPlacement(int row, int col, int length, bool horizontal) {
    if (horizontal) {
      if (col + length > size) return false;
      for (int i = 0; i < length; i++) {
        if (row < 0 || row >= size || col + i < 0 || col + i >= size || board[row][col + i] != '.') {
          return false;
        }
      }
    } else {
      if (row + length > size) return false;
      for (int i = 0; i < length; i++) {
        if (row + i < 0 || row + i >= size || col < 0 || col >= size || board[row + i][col] != '.') {
          return false;
        }
      }
    }

    // Дополнительная проверка на окружение корабля
    int startRow = max(0, row - 1);
    int endRow = min(size - 1, (horizontal ? row : row + length));
    int startCol = max(0, col - 1);
    int endCol = min(size - 1, (horizontal ? col + length : col));

    for (int i = startRow; i <= endRow; i++) {
      for (int j = startCol; j <= endCol; j++) {
        if (board[i][j] == 'S') {
          return false;
        }
      }
    }

    return true;
  }


  bool shoot(int row, int col) {
    if (board[row][col] == 'S') {
      board[row][col] = 'X';
      // Проверяем, уничтожен ли корабль
      Ship? sunkShip = isShipSunk(row, col);
      if (sunkShip != null) {
        surroundSunkShip(sunkShip);
        print('\nОпа, потанул!');
      }
      return true;
    } else if (board[row][col] == '.') {
      board[row][col] = 'O';
      return false;
    } else {
      return false;
    }
  }

  Ship? isShipSunk(int row, int col) {
    for (Ship ship in ships) {
      if (!ship.sunk) {
        // Проверяем, содержит ли корабль данные координаты
        bool hit = false;
        for (var coord in ship.coordinates) {
          if (coord[0] == row && coord[1] == col) {
            hit = true;
            break;
          }
        }

        if (hit) {
          //Удаляем координаты попадания. Если список координат пуст - корабль уничтожен
          ship.coordinates.removeWhere((coord) => coord[0] == row && coord[1] == col);

          if (ship.coordinates.isEmpty) {
            ship.sunk = true;
            return ship;
          } else {
            return null;
          }
        }
      }
    }
    return null;
  }

  void surroundSunkShip(Ship sunkShip) {
      int startRow = size;
      int endRow = 0;
      int startCol = size;
      int endCol = 0;

      // Определяем границы корабля, используя originalCoordinates
      for (var coord in sunkShip.originalCoordinates) {
        startRow = min(startRow, coord[0]);
        endRow = max(endRow, coord[0]);
        startCol = min(startCol, coord[1]);
        endCol = max(endCol, coord[1]);
      }

      // Окружаем корабль промахами
      for (int i = max(0, startRow - 1); i <= min(size - 1, endRow + 1); i++) {
        for (int j = max(0, startCol - 1); j <= min(size - 1, endCol + 1); j++) {
          if (board[i][j] == '.') {
            board[i][j] = 'O';
          }
        }
      }
    }

  bool allShipsSunk() {
    for (Ship ship in ships) {
      if (!ship.sunk) {
        return false;
      }
    }
    return true;
  }
}