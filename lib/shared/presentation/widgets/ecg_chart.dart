import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:grad_imp_1/core/constants/app_durations.dart';

class ECGChart extends StatefulWidget {
  final Color lineColor;
  const ECGChart({super.key, this.lineColor = Colors.green});

  @override
  State<ECGChart> createState() => _ECGChartState();
}

class _ECGChartState extends State<ECGChart> {
  List<FlSpot> spots = [];
  double xValue = 0;
  final int maxPoints = 200;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    generateECG();
  }

  void generateECG() {
    _timer = Timer.periodic(AppDurations.chartUpdate, (timer) {
      double y;

      // Fake ECG Pattern
      if (xValue % 50 == 0) {
        y = 3; // R peak
      } else if (xValue % 50 == 2) {
        y = 0.5; // S drop
      } else {
        y = 1 + sin(xValue * 0.1) * 0.1; // small noise
      }

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
          maxY: 3.5,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: widget.lineColor),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: false, // Important for ECG
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
