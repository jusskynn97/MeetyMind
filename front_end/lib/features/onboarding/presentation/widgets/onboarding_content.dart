import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/models/onboarding_item.dart';
import 'package:front_end/app/theme/colors.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;
  final bool isActive;

  const OnboardingContent({super.key, required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: maxHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🟢 Hình minh họa với hiệu ứng gradient mờ phía sau
              Expanded(
                flex: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Vầng sáng gradient mờ
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: ColorManager.primary,
                      ),
                      foregroundDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    // Hình minh họa
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Lottie.asset(
                        item.image,
                        animate: isActive,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🖋️ Nội dung chữ
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: ColorManager.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
