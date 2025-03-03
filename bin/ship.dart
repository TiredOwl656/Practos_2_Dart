class Ship {
  final int id;
  final int length;
  final List<List<int>> coordinates;
  bool sunk = false;
  final List<List<int>> originalCoordinates;

  Ship({required this.id, required this.length, required this.originalCoordinates, required this.coordinates});
}