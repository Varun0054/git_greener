import 'package:flutter/material.dart';
import '../models/contribution_day.dart';

class ContributionGraph extends StatelessWidget {
  final List<ContributionDay> days;

  const ContributionGraph({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const cellSize = 11.0;
        const gap = 2.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: (cellSize + gap) * 53,
              height: (cellSize + gap) * 7 + 20, 
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: gap,
                  crossAxisSpacing: gap,
                  childAspectRatio: 1,
                ),
                itemCount: 53 * 7,
                itemBuilder: (context, index) {
                  if (index >= days.length) return const SizedBox.shrink();
                  
                  final day = days[index];
                  return Tooltip(
                    message: '${day.contributionCount} contributions on ${day.date.year}-${day.date.month}-${day.date.day}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: day.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
