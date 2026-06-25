import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:grad_imp_1/core/constants/app_durations.dart';

class PPGChart extends StatefulWidget {
  final Color lineColor;
  const PPGChart({super.key, this.lineColor = Colors.blue});

  @override
  State<PPGChart> createState() => _PPGChartState();
}

class _PPGChartState extends State<PPGChart> {
  List<FlSpot> spots = [];
  double xValue = 0;
  final int maxPoints = 200;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    generatePPG();
  }

  void generatePPG() {
    _timer = Timer.periodic(AppDurations.chartUpdate, (timer) {
      // Smooth PPG wave
      double y = 2 + 1.2 * sin(xValue * 0.1) + 0.3 * sin(xValue * 0.2);

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        spots.add(FlSpot(xValue, y));
        if (spots.length > maxPoints) {
          spots.removeAt(0);
        }
        xValue++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 4,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: widget.lineColor),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true, // Important for PPG smoothness
              spots: spots,
              color: widget.lineColor,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
