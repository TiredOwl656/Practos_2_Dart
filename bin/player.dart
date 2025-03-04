import 'board.dart';
import 'dart:io';

class Player {
  final String name;
  final Board board;

  Player(this.name, this.board);

  List<int> getCoordinatesFromInput(String prompt) {
    while (true) {
      stdout.write(prompt);
      String? input = stdin.readLineSync()?.toUpperCase();
      if (input == null || input.isEmpty) {
        print('\n\nНе правильно ввел, давай по новой. Пример: A5');
        continue;
      }

      if (input.length < 2) {
        print('\nНе правильно ввел, давай по новой. Пример: A5');
        continue;
      }

      int row = input.codeUnitAt(0) - 65;
      int? col = int.tryParse(input.substring(1));

      if (col == null) {
          print('\nНе правильно ввел, давай по новой. Пример: A5');
          continue;
      }else{
        col--;
      }

      if (row >= 0 && row < board.size && col >= 0 && col < board.size) {
        return [row, col];
      } else {
        print('\nВ этой игре корабли не могут по суше передвигать, располагайте их в диапозоне водоема, пж');
      }
    }
  }
}
