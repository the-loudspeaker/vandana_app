import 'package:flutter/material.dart';
import 'utils.dart';

class PatternLockScreen extends StatefulWidget {
  const PatternLockScreen({super.key});

  @override
  State<PatternLockScreen> createState() => _PatternLockScreenState();
}

class _PatternLockScreenState extends State<PatternLockScreen> {
  final List<Offset> _points = [];
  final List<int> _pattern = [];
  final List<Offset> _dotOffsets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("pattern", context),
      // backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Center(
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          children: List.generate(9, (index) {
            return drawDot(index + 1);
          }),
        ),
      ),
    );
  }

  Widget drawDot(int index) {
    return SizedBox(
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.all(10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  // void _calculateDotOffsets() {
  //   double size = 50;
  //   double margin = 10;
  //   for (int i = 0; i < 9; i++) {
  //     int row = i ~/ 3;
  //     int col = i % 3;
  //     double x = col * (size + margin) + size / 2;
  //     double y = row * (size + margin) + size / 2;
  //     _dotOffsets.add(Offset(x, y));
  //   }
  // }

  // int _getDotIndex(Offset point) {
  //   for (int i = 0; i < _dotOffsets.length; i++) {
  //     Offset dotOffset = _dotOffsets[i];
  //     double distance = sqrt(pow(point.dx - dotOffset.dx, 2) + pow(point.dy - dotOffset.dy, 2));
  //     print(dotOffset);
  //     print(distance);
  //     if (distance < 50 * 2) {
  //       return i;
  //     }
  //   }
  //   return -1;
  // }
}

// class Dot extends StatelessWidget {
//   final int index;
//
//   const Dot(this.index, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(width: 2),
//       ),
//       child: Center(
//         child: Text(
//           '$index',
//           style: const TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// class PatternPainter extends CustomPainter {
//   final List<Offset> points;
//
//   PatternPainter(this.points);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..strokeWidth = 50
//       ..color = Colors.blue;
//     for (int i = 1; i < points.length; i++) {
//       canvas.drawLine(points[i - 1], points[i], paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
