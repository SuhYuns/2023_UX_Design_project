
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PieChartSample3 extends StatefulWidget {
  const PieChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State {
  int touchedIndex = 0;
  int total_count = 0;
  int total_item_count = 0;
  var nullCheck2 ;
  var nullCheck1;
  var final_title = [];
  var final_item_count = [];
  var final_done_count = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  test() async {
    var storage = await SharedPreferences.getInstance();

    nullCheck1 = storage.getStringList('todo_items') ?? 'none';
    if (nullCheck1 == 'none') {
      storage.setStringList("todo_items", ["미설정"]);
      nullCheck1 = storage.getStringList('todo_items') ?? 'none';
    }
    nullCheck1 = nullCheck1 as List;

    setState(() {
      nullCheck2 = storage.getStringList('locations') ?? 'none';
      if (nullCheck2 == 'none') {
        storage.setStringList("todo_items", ["미설정"]);
        nullCheck2 = storage.getStringList('todo_items') ?? 'none';
      }
      nullCheck2 = nullCheck2 as List;

      for (var spot_num = 0; spot_num < (nullCheck2).length; spot_num++ ) {
        var item_count = 0;
        var item_done_count = 0;
        final_title.add(nullCheck2[spot_num]);
        final_item_count.add(0);
        final_done_count.add(0);
        for (var item in nullCheck1) {
          if (nullCheck2[spot_num] == jsonDecode(item)["location"]) {
            final_item_count[spot_num] += 1;
            if (jsonDecode(item)["done"] == true) {
              final_done_count[spot_num] += 1;
            }
          }
        }
      }
      total_count = (nullCheck2).length;
      total_item_count = (nullCheck1).length;
    });


    for (var i in nullCheck2) {
      print(i);
    }


  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(total_count.toInt(), (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];


      return PieChartSectionData(
        value: final_item_count[i]/total_item_count,
        title: nullCheck2[i].toString() + "\n" + (final_item_count[i]/total_item_count * 100).toStringAsFixed(1).toString() + "%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgePositionPercentageOffset: .98,
      );

    });
  }
}

class _Badge extends StatelessWidget {
  const _Badge(
      this.svgAsset, {
        required this.size,
        required this.borderColor,
      });
  final String svgAsset;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
      ),
    );
  }
}


class PieChartSample1 extends StatefulWidget {
  const PieChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State {
  int touchedIndex = 0;
  int total_count = 0;
  int total_item_count = 0;
  var nullCheck2 ;
  var nullCheck1;
  var final_title = [];
  var items = ["완료", "미완료"];
  var final_done_count = [0, 0];
  var colorsType = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test();
  }

  test() async {
    var storage = await SharedPreferences.getInstance();

    nullCheck1 = storage.getStringList('todo_items') ?? 'none';
    if (nullCheck1 == 'none') {
      storage.setStringList("todo_items", ["미설정"]);
      nullCheck1 = storage.getStringList('todo_items') ?? 'none';
    }
    nullCheck1 = nullCheck1 as List;

    setState(() {

      for (var item in nullCheck1) {
        if (jsonDecode(item)["done"] == true) {
          final_done_count[0] += 1;
        } else {
          final_done_count[1] += 1;
        }
      }
      total_item_count = (nullCheck1).length;
    });


    for (var i in nullCheck2) {
      print(i);
    }


  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(
              show: false,
            ),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: showingSections(),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];


      return PieChartSectionData(
        value: final_done_count[i]/total_item_count,
        title: items[i].toString() + "\n" + (final_done_count[i]/total_item_count * 100).toStringAsFixed(1).toString() + "%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: shadows,
        ),
        badgePositionPercentageOffset: .98,
      );

    });
  }
}
