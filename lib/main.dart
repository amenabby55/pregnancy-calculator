import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const PregnancyCalculatorApp());

class PregnancyCalculatorApp extends StatelessWidget {
  const PregnancyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pregnancy Due Date Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
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
  static const List<String> _months = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
  ];

  double _monthAngle = 0;
  double _dayAngle = 0;

  bool _draggingOuter = false;
  bool _draggingInner = false;

  int get _selectedMonth {
    double norm = (_monthAngle % (2 * pi));
    if (norm < 0) norm += 2 * pi;
    double adjusted = (norm + pi / 2) % (2 * pi);
    int sector = (adjusted / (2 * pi / 12)).floor();
    return (sector % 12) + 1;
  }

  int get _selectedDay {
    double norm = (_dayAngle % (2 * pi));
    if (norm < 0) norm += 2 * pi;
    int day = ((norm / (2 * pi)) * 31).floor() + 1;
    return day.clamp(1, 31);
  }

  int get _clampedDay {
    final month = _selectedMonth;
    final year = DateTime.now().year;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return min(_selectedDay, daysInMonth);
  }

  DateTime get _edd {
    final now = DateTime.now();
    final lmp = DateTime(now.year, _selectedMonth, _clampedDay);
    return lmp.add(const Duration(days: 280));
  }

  @override
  Widget build(BuildContext context) {
    final edd = _edd;
    final monthName = _months[edd.month - 1];
    final lmpMonthName = _months[_selectedMonth - 1];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text(
          'PREGNANCY DUE DATE CALCULATOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF6D4C2F),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFF5E6C8),
            child: const Text(
              'ROTATE THE WHEELS TO SELECT YOUR LAST MENSTRUAL PERIOD (LMP)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D4C2F),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: SizedBox(
                width: 380,
                height: 380,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Wheel (Months)
                    GestureDetector(
                      onPanStart: (details) {
                        final dx = details.localPosition.dx - 190;
                        final dy = details.localPosition.dy - 190;
                        final dist = sqrt(dx * dx + dy * dy);
                        if (dist > 110 && dist < 185) {
                          _draggingOuter = true;
                        }
                      },
                      onPanUpdate: (details) {
                        if (_draggingOuter) {
                          setState(() {
                            _monthAngle += details.delta.dx * 0.015;
                          });
                        }
                      },
                      onPanEnd: (_) => _draggingOuter = false,
                      child: CustomPaint(
                        size: const Size(380, 380),
                        painter: OuterWheelPainter(
                          monthAngle: _monthAngle,
                          months: _months,
                          selectedMonth: _selectedMonth,
                        ),
                      ),
                    ),

                    // Inner Wheel (Days)
                    GestureDetector(
                      onPanStart: (details) {
                        final dx = details.localPosition.dx - 190;
                        final dy = details.localPosition.dy - 190;
                        final dist = sqrt(dx * dx + dy * dy);
                        if (dist < 105) {
                          _draggingInner = true;
                        }
                      },
                      onPanUpdate: (details) {
                        if (_draggingInner) {
                          setState(() {
                            _dayAngle += details.delta.dx * 0.02;
                          });
                        }
                      },
                      onPanEnd: (_) => _draggingInner = false,
                      child: CustomPaint(
                        size: const Size(380, 380),
                        painter: InnerWheelPainter(
                          dayAngle: _dayAngle,
                          selectedDay: _clampedDay,
                        ),
                      ),
                    ),

                    // Fixed Pointer at Top
                    Positioned(
                      top: 0,
                      child: CustomPaint(
                        size: const Size(30, 30),
                        painter: TrianglePainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5E6C8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4A857), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF6D4C2F)),
                const SizedBox(width: 10),
                Text(
                  'LMP: $_clampedDay $lmpMonthName ${DateTime.now().year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D4C2F),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF6D4C2F), const Color(0xFF8B6914)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'ESTIMATED DUE DATE (EDD)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${edd.day} $monthName ${edd.year}',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '≈ 40 weeks of pregnancy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFFD700),
                    fontStyle: FontStyle.italic,
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

class OuterWheelPainter extends CustomPainter {
  final double monthAngle;
  final List<String> months;
  final int selectedMonth;

  OuterWheelPainter({
    required this.monthAngle,
    required this.months,
    required this.selectedMonth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 5;
    final innerRadius = outerRadius - 80;

    canvas.drawCircle(center, outerRadius, Paint()..color = const Color(0xFFF4D03F));
    canvas.drawCircle(center, innerRadius, Paint()..color = const Color(0xFFFDF5E6));

    for (int i = 0; i < 12; i++) {
      double angle = monthAngle + (2 * pi * i / 12) - pi / 2;
      
      final linePaint = Paint()
        ..color = const Color(0xFFD4A857)
        ..strokeWidth = 1.5;
      
      final start = Offset(
        center.dx + (innerRadius + 5) * cos(angle),
        center.dy + (innerRadius + 5) * sin(angle),
      );
      final end = Offset(
        center.dx + (outerRadius - 5) * cos(angle),
        center.dy + (outerRadius - 5) * sin(angle),
      );
      canvas.drawLine(start, end, linePaint);

      if (i == selectedMonth - 1) {
        final highlightPaint = Paint()
          ..color = const Color(0xFFFF8C00).withOpacity(0.7)
          ..style = PaintingStyle.fill;
        
        final rect = Rect.fromCircle(center: center, radius: outerRadius - 2);
        canvas.drawArc(
          rect,
          angle - pi / 12,
          2 * pi / 12,
          true,
          highlightPaint,
        );
      }

      final midAngle = monthAngle + (2 * pi * (i + 0.5) / 12) - pi / 2;
      final textPainter = TextPainter(
        text: TextSpan(
          text: months[i],
          style: TextStyle(
            color: i == selectedMonth - 1 ? Colors.white : const Color(0xFF4A3520),
            fontSize: i == selectedMonth - 1 ? 11 : 9,
            fontWeight: i == selectedMonth - 1 ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(
        center.dx + (innerRadius + outerRadius) / 2 * cos(midAngle),
        center.dy + (innerRadius + outerRadius) / 2 * sin(midAngle),
      );
      canvas.rotate(midAngle + pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant OuterWheelPainter oldDelegate) {
    return monthAngle != oldDelegate.monthAngle ||
        selectedMonth != oldDelegate.selectedMonth;
  }
}

class InnerWheelPainter extends CustomPainter {
  final double dayAngle;
  final int selectedDay;

  InnerWheelPainter({
    required this.dayAngle,
    required this.selectedDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final innerRadius = size.width / 2 - 90;

    canvas.drawCircle(center, innerRadius, Paint()..color = const Color(0xFFFFB74D));

    for (int i = 0; i < 31; i++) {
      double angle = dayAngle + (2 * pi * i / 31) - pi / 2;
      
      if (i == selectedDay - 1) {
        final highlightPaint = Paint()..color = const Color(0xFFE65100);
        canvas.drawCircle(
          Offset(
            center.dx + (innerRadius - 22) * cos(angle),
            center.dy + (innerRadius - 22) * sin(angle),
          ),
          16,
          highlightPaint,
        );
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: i == selectedDay - 1 ? Colors.white : const Color(0xFF4A3520),
            fontSize: i == selectedDay - 1 ? 13 : 9,
            fontWeight: i == selectedDay - 1 ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final pos = Offset(
        center.dx + (innerRadius - 22) * cos(angle),
        center.dy + (innerRadius - 22) * sin(angle),
      );

      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }

    canvas.drawCircle(center, 30, Paint()..color = const Color(0xFF6D4C2F));
    
    final centerText = TextPainter(
      text: const TextSpan(
        text: 'DAYS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    centerText.layout();
    centerText.paint(
      canvas,
      Offset(center.dx - centerText.width / 2, center.dy - centerText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant InnerWheelPainter oldDelegate) {
    return dayAngle != oldDelegate.dayAngle || selectedDay != oldDelegate.selectedDay;
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) => false;
}