import 'package:flutter/material.dart';
import 'package:gamers_glint/widgets/game_card.dart';
import 'widgets/two_rad.dart';

class HomePage extends StatelessWidget {
  final String? nickname;
  final String? avatarUrl;
  final int? numGames;
  final double? percent;
  final double widthHeight = 100;
  final int? id;
  final List<GameCard>? recent;
  final int achCount;
  const HomePage({
    Key? key,
    this.nickname,
    this.avatarUrl,
    this.numGames,
    this.percent,
    this.id,
    this.recent,
    required this.achCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Wrap(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        runSpacing: 20,
        children: [
          Container(
            width: 360,
            height: widthHeight + 100,
            alignment: Alignment.center,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (nickname != null)
                        Text(
                          '$nickname',
                          softWrap: false,
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (avatarUrl != null)
                        Image.network(
                          avatarUrl!,
                          width: widthHeight,
                          height: widthHeight,
                        ),
                      if (numGames != null)
                        Text(
                          '$numGames games',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  if (percent != null)
                    SizedBox(
                      height: widthHeight,
                      width: widthHeight,
                      child: NestedRadialProgress(
                        heightProgress: widthHeight,
                        widthProgress: widthHeight,
                        progress: percent!.toStringAsFixed(2),
                      ),
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  SizedBox(
                      width: widthHeight,
                      height: widthHeight,
                      child: Center(
                        child: Text("Achievement: $achCount"),
                      ))
                ],
              ),
            ),
          ),
          SizedBox(
              height: 470,
              width: screenWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 230,
                      maxCrossAxisExtent: 130, // максимальная ширина элемента
                      crossAxisSpacing: 3, // расстояние между столбцами
                      mainAxisSpacing: 10, // расстояние между строками
                    ),
                    itemCount: recent?.length, // количество элементов в гриде
                    itemBuilder: (BuildContext context, int index) {
                      return recent?[index];
                    }),
              )),
        ],
      ),
    );
  }
}
