import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({super.key, required this.totalSteps, required this.currentStep});
  final int totalSteps;
  final int currentStep; // 0-based

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index == totalSteps - 1 ? 0 : AppSpacing.xs),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}