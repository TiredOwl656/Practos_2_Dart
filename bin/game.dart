import 'player.dart';
import 'board.dart';

class Game {
  late Player player1;
  late Player player2;
  late Player currentPlayer;
  final int boardSize;

  Game({this.boardSize = 10}) {
    player1 = Player('Игрок 1', Board(boardSize));
    player2 = Player('Игрок 2', Board(boardSize));
    currentPlayer = player1;
  }

  void startGame() {
    print('Приветствую тебя в Морском бою, мой друг!');

    print('\n${player1.name}, не расскажешь секрет, где корабли поставишь:\n');
    placeShips(player1);

    print('\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n${player2.name}, ну и ты расскажи уж, где спрячешь свои корабли:\n');
    placeShips(player2);

    while (true) {
      print('\nХод игрока ${currentPlayer.name}:');
      playTurn(currentPlayer, (currentPlayer == player1) ? player2 : player1);

      if ((currentPlayer == player1 ? player2 : player1).board.allShipsSunk()) {
        print('\n${currentPlayer.name}, маладэц, ты победил!');
        break;
      }

      currentPlayer = (currentPlayer == player1) ? player2 : player1;
    }
  }

  void placeShips(Player player) {
    final shipsToPlace = [5, 4, 3, 3, 2];
    int numberOfShips = shipsToPlace.length;
    for (var shipLength in shipsToPlace) {
      while (true) {
        player.board.printBoard(showShips: true);
        if(shipLength == 1){
          print('\nнадо поставить однопалубный корабль');
        }
        else if(shipLength > 1 && shipLength < 5){
          print('\nнадо поставить $shipLength-хпалубный корабль');
        }
        else if(shipLength >= 5){
          print('\nнадо поставить $shipLength-ипалубный корабль');
        }
        

        // Получаем координаты начала и конца корабля
        List<int> startCoords = player.getCoordinatesFromInput('\nГде нос корабля? (Введите координату, например, A5): ');
        int startRow = startCoords[0];
        int startCol = startCoords[1];

        List<int> endCoords = player.getCoordinatesFromInput('\nА конец где?: ');
        int endRow = endCoords[0];
        int endCol = endCoords[1];

        // Пытаемся разместить корабль
        if (player.board.placeShip(startRow, startCol, endRow, endCol, shipLength)) {
          break;
        } else {
          print('\nСюда не получилось поставить. Попытайте удачу снова.');
        }
      }
      numberOfShips--;
      if (numberOfShips == 0) {
        print('\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n');
      }
    }
  }


  void playTurn(Player attacker, Player defender) {
    defender.board.printBoard();

    while (true) {
      List<int> coords = attacker.getCoordinatesFromInput('\nВведите куда шмалять будем (например, A5): ');
      int row = coords[0];
      int col = coords[1];

      if (defender.board.shoot(row, col)) {
        print('\nХорош, попал!');
        defender.board.printBoard();
        if (defender.board.allShipsSunk()) {
          return;
        }
      } else {
        print('\nЭх! Мимо.');
        break;
      }
    }
  }
}