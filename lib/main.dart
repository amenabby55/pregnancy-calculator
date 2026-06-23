import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const PregnancyCalculatorApp());

class PregnancyCalculatorApp extends StatelessWidget {
  const PregnancyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kikokotoo cha Umri wa Mimba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const PregnancyWheelScreen(),
    );
  }
}

class PregnancyWheelScreen extends StatefulWidget {
  const PregnancyWheelScreen({super.key});

  @override
  State<PregnancyWheelScreen> createState() => _PregnancyWheelScreenState();
}

class _PregnancyWheelScreenState extends State<PregnancyWheelScreen> {
  double _monthAngle = 0.0;
  double _dayAngle = 0.0;

  static const List<String> _swahiliMonths = [
    'JANUARI', 'FEBRUARI', 'MACHI', 'APRILI', 'MEI', 'JUNI',
    'JULAI', 'AGOSTI', 'SEPTEMBA', 'OKTOBA', 'NOVEMBA', 'DISEMBA'
  ];

  DateTime calculateEDD(int month, int day) {
    final now = DateTime.now();
    final lmp = DateTime(now.year, month, day);
    return lmp.add(const Duration(days: 280));
  }

  int get selectedMonth {
    double norm = (_monthAngle % (2 * pi));
    if (norm < 0) norm += 2 * pi;
    double adjusted = (norm + pi / 2) % (2 * pi);
    int sector = (adjusted / (2 * pi / 12)).floor();
    return (sector % 12) + 1;
  }

  int get selectedDay {
    double norm = (_dayAngle % (2 * pi));
    if (norm < 0) norm += 2 * pi;
    int day = ((norm / (2 * pi)) * 31).floor() + 1;
    return day.clamp(1, 31);
  }

  int get clampedDay {
    final month = selectedMonth;
    final year = DateTime.now().year;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return min(selectedDay, daysInMonth);
  }

  @override
  Widget build(BuildContext context) {
    final edd = calculateEDD(selectedMonth, clampedDay);
    String eddDay = edd.day.toString();
    String eddMonth = _swahiliMonths[edd.month - 1];
    String eddYear = edd.year.toString();
    String eddText = '$eddDay $eddMonth $eddYear';

    return Scaffold(
      backgroundColor: const Color(0xFFF5DEB3),
      appBar: AppBar(
        title: const Text(
          'Kikokotoo cha Umri wa Mimba',
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFE4B5),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _monthAngle += details.delta.dx * 0.01;
                    _dayAngle += details.delta.dx * 0.01;
                  });
                },
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: PregnancyWheelPainter(
                    monthAngle: _monthAngle,
                    dayAngle: _dayAngle,
                    swahiliMonths: _swahiliMonths,
                    selectedMonth: selectedMonth,
                    selectedDay: clampedDay,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF8B5A2B),
            child: Column(
              children: [
                const Text(
                  'TAREHE YA KUJIFUNGUA (EDD)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  eddText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PregnancyWheelPainter extends CustomPainter {
  final double monthAngle;
  final double dayAngle;
  final List<String> swahiliMonths;
  final int selectedMonth;
  final int selectedDay;

  PregnancyWheelPainter({
    required this.monthAngle,
    required this.dayAngle,
    required this.swahiliMonths,
    required this.selectedMonth,
    required this.selectedDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 * 0.95;
    final innerRadius = outerRadius * 0.65;

    _drawRing(canvas, center,
        radius: outerRadius,
        thickness: outerRadius - innerRadius,
        color: const Color(0xFFF4D03F));
    _drawMonthLabels(canvas, center, (outerRadius + innerRadius) / 2);

    _drawRing(canvas, center,
        radius: innerRadius,
        thickness: innerRadius * 0.5,
        color: const Color(0xFFE67E22));
    _drawDayLabels(canvas, center, innerRadius * 0.75);

    final pointerSize = 12.0;
    final pointerTop = Offset(center.dx, center.dy - outerRadius + 10);
    final pointerPath = Path()
      ..moveTo(pointerTop.dx, pointerTop.dy)
      ..lineTo(pointerTop.dx - pointerSize / 2, pointerTop.dy - pointerSize)
      ..lineTo(pointerTop.dx + pointerSize / 2, pointerTop.dy - pointerSize)
      ..close();
    canvas.drawPath(pointerPath, Paint()..color = Colors.brown);
  }

  void _drawRing(Canvas canvas, Offset center,
      {required double radius, required double thickness, required Color color}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawMonthLabels(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 12; i++) {
      double angle = monthAngle + (2 * pi * i / 12) - pi / 2;
      final label = swahiliMonths[i];
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        center.dx + radius * cos(angle) - textPainter.width / 2,
        center.dy + radius * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  void _drawDayLabels(Canvas canvas, Offset center, double radius) {
    const daysToShow = [1, 10, 20, 31];
    for (int d in daysToShow) {
      double angle = dayAngle + (2 * pi * (d - 1) / 31) - pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: d.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        center.dx + radius * cos(angle) - textPainter.width / 2,
        center.dy + radius * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant PregnancyWheelPainter oldDelegate) {
    return monthAngle != oldDelegate.monthAngle ||
        dayAngle != oldDelegate.dayAngle ||
        selectedMonth != oldDelegate.selectedMonth ||
        selectedDay != oldDelegate.selectedDay;
  }
}
