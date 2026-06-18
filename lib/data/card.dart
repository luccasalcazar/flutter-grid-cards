class CardData {
  final int id;
  final String title;
  int width; // em unidades de grid
  int height; // em unidades de grid

  CardData({
    required this.id,
    required this.title,
    this.width = 1,
    this.height = 1,
  });
}