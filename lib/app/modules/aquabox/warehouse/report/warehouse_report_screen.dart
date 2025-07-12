import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* --------- model giao dịch --------- */
class _Trans {
  final int month;          // 5,6,7
  final bool isIn;          // true=nhập, false=xuất
  final int value;       // kg (feed) | qty (equip)
  _Trans(this.month, this.isIn, this.value);
}

/* --------- screen --------- */
class WarehouseReportScreen extends StatelessWidget {
  WarehouseReportScreen({super.key}) {
    _fakeData();
    _aggregate();
  }

  /* ---------- 1) sinh dữ liệu ---------- */
  final _rng = Random();
  final List<_Trans> _feedList  = [];   // kg
  final List<_Trans> _equipList = [];   // qty

  void _fakeData() {
    for (int m = 5; m <= 7; m++) {
      // Thức ăn: 20 phiếu nhập, 15 phiếu xuất
      for (int i = 0; i < 20; i++) {
        _feedList.add(_Trans(m, true,  80 + _rng.nextInt(150)));
      }
      for (int i = 0; i < 15; i++) {
        _feedList.add(_Trans(m, false, 60 + _rng.nextInt(120)));
      }

      // Thiết bị: 5 phiếu nhập, 4 phiếu xuất
      for (int i = 0; i < 5; i++)  {
        _equipList.add(_Trans(m, true,  1 + _rng.nextInt(4))); // 1–4 bộ
      }
      for (int i = 0; i < 4; i++)  {
        _equipList.add(_Trans(m, false, 1 + _rng.nextInt(3)));
      }
    }
  }

  /* ---------- 2) tổng hợp ---------- */
  late final List<_MonthPair> _feedRows;
  late final List<_MonthPair> _equipRows;

  void _aggregate() {
    _feedRows  = _agg(_feedList);
    _equipRows = _agg(_equipList);
  }

  List<_MonthPair> _agg(List<_Trans> src) {
    final rows = <_MonthPair>[];
    for (int m = 5; m <= 7; m++) {
      double inV = 0, outV = 0;
      for (var t in src.where((e) => e.month == m)) {
        t.isIn ? inV += t.value : outV += t.value;
      }
      rows.add(_MonthPair('Tháng $m', inV, outV));
    }
    return rows;
  }

  /* ---------- 3) UI ---------- */
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final chartH = h * 0.37;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo kho theo tháng'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _chartSection(
                  title: 'Thức ăn (kg)',
                  data: _feedRows,
                  colorIn: Colors.blue.shade700,
                  colorOut: Colors.blue.shade200,
                  height: chartH,
                ),
                const SizedBox(height: 20),
                _chartSection(
                  title: 'Thiết bị (số lượng)',
                  data: _equipRows,
                  colorIn: Colors.orange.shade700,
                  colorOut: Colors.orange.shade300,
                  height: chartH,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------- helper: build chart ---------- */
  Widget _chartSection({
    required String title,
    required List<_MonthPair> data,
    required Color colorIn,
    required Color colorOut,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SfCartesianChart(
        title: ChartTitle(
            text: title,
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(),
        series: [
          ColumnSeries<_MonthPair, String>(
            name: 'Nhập',
            width: 0.4,
            dataSource: data,
            xValueMapper: (d, _) => d.month,
            yValueMapper: (d, _) => d.inVal,
            color: colorIn,
          ),
          ColumnSeries<_MonthPair, String>(
            name: 'Xuất',
            width: 0.4,
            dataSource: data,
            xValueMapper: (d, _) => d.month,
            yValueMapper: (d, _) => d.outVal,
            color: colorOut,
          ),
        ],
      ),
    );
  }
}

/* ---------- pair for each month ---------- */
class _MonthPair {
  final String month;
  final double inVal;
  final double outVal;
  _MonthPair(this.month, this.inVal, this.outVal);
}
