import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularSeekBar(
              width: double.infinity,
              height: 250,
              barWidth: 8,
              startAngle: 45,
              sweepAngle: 360,
              progress: 200,
              strokeCap: StrokeCap.round,
              progressGradientColors: [
                Colors.lightBlue,
                Colors.deepPurpleAccent,
                Colors.purple
              ],
              dashWidth: 80,
              dashGap: 15,
              animation: true,
            ),
            Text("Please Wait...")
          ],
        ),
      ),
    );
  }
}
