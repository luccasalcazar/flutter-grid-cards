import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'grid_card.dart';
import 'data/card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Teste Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  double groupAlignment = -1.0;
  static const int _crossAxisCount = 4;
  static const double _mainAxisSpacing = 8;
  static const double _crossAxisSpacing = 8;
  static const double _gridPadding = 16;
  static const double _resizeThreshold = 200;
  List<CardData> cards = [
    CardData(id: 1, title: 'Card 1'),
    CardData(id: 2, title: 'Card 2'),
    CardData(id: 3, title: 'Card 3'),
    CardData(id: 4, title: 'Card 4'),
    CardData(id: 5, title: 'Card 5'),
    CardData(id: 6, title: 'Card 6'),
    CardData(id: 7, title: 'Card 7'),
    CardData(id: 8, title: 'Card 8'),
    CardData(id: 9, title: 'Card 9'),
    CardData(id: 10, title: 'Card 10'),
  ];
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  int? draggingIndex;
  final Map<int, double> _resizeAccumulator = {};

  void swapCard(int from, int to) {
    if (from == to) return;
    if (from < 0 || to < 0 || from >= cards.length || to >= cards.length) return;

    setState(() {
      final temp = cards[from];
      cards[from] = cards[to];
      cards[to] = temp;
    });
  }

  void _onResizeStart(int cardId) {
    _resizeAccumulator[cardId] = 0;
  }

  void _onResizeUpdate(CardData card, double deltaDx) {
    final key = card.id;
    final current = (_resizeAccumulator[key] ?? 0) + deltaDx;

    if (current.abs() < _resizeThreshold) {
      _resizeAccumulator[key] = current;
      return;
    }

    final steps = current ~/ _resizeThreshold;
    final nextWidth = (card.width + steps).clamp(1, _crossAxisCount);
    if (nextWidth != card.width) {
      setState(() {
        card.width = nextWidth;
      });
    }

    _resizeAccumulator[key] = current - (steps * _resizeThreshold);
  }

  void _onResizeEnd(int cardId) {
    _resizeAccumulator.remove(cardId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              mainAxisAlignment: MainAxisAlignment.center,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: labelType,
              backgroundColor: Color.fromARGB(255, 214, 91, 64),
              indicatorColor: Color.fromARGB(31, 28, 28, 28),
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: Text('First'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bookmark_border),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Second'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_border),
                  selectedIcon: Icon(Icons.star),
                  label: Text('Third'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(_gridPadding),
                child: StaggeredGrid.count(
                  crossAxisCount: _crossAxisCount,
                  mainAxisSpacing: _mainAxisSpacing,
                  crossAxisSpacing: _crossAxisSpacing,
                  children: [
                    for (int index = 0; index < cards.length; index++)
                      StaggeredGridTile.extent(
                        crossAxisCellCount: cards[index].width,
                        mainAxisExtent: (MediaQuery.of(context).size.height - 50) / 3,
                        child: DragTarget<int>(
                          onWillAcceptWithDetails:
                              (details) => details.data != index,
                          onAcceptWithDetails: (details) {
                            swapCard(details.data, index);
                          },
                          builder: (context, candidateData, rejectedData) {
                            final card = cards[index];
                            final isHover = candidateData.isNotEmpty;

                            return LongPressDraggable<int>(
                              data: index,
                              onDragStarted: () {
                                setState(() {
                                  draggingIndex = index;
                                });
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  draggingIndex = null;
                                });
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: 220,
                                  child: Opacity(
                                    opacity: 0.9,
                                    child: GridCard(
                                      data: card,
                                      onResizeStart: () {},
                                      onResizeUpdate: (_) {},
                                      onResizeEnd: () {},
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.25,
                                child: GridCard(
                                  data: card,
                                  onResizeStart: () {},
                                  onResizeUpdate: (_) {},
                                  onResizeEnd: () {},
                                ),
                              ),
                              child: AnimatedScale(
                                scale: isHover ? 1.03 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: GridCard(
                                    data: card,
                                    onResizeStart: () => _onResizeStart(card.id),
                                    onResizeUpdate: (dx) =>
                                        _onResizeUpdate(card, dx),
                                    onResizeEnd: () => _onResizeEnd(card.id),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
