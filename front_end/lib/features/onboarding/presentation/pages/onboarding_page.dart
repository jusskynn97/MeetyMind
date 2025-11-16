import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:front_end/app/routes/routes.dart';
import 'package:front_end/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:go_router/go_router.dart';
import 'package:front_end/app/theme/colors.dart';
import '../../data/models/onboarding_item.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Precache Lottie animations
    for (var item in _items) {
      precacheLottie(item.image, context);
    }
  }

  Future<void> precacheLottie(String asset, BuildContext context) async {
    await DefaultAssetBundle.of(context).loadString(asset);
  }

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Record & Transcribe Effortlessly',
      description: 'Capture every word of your meetings and generate accurate transcripts automatically.',
      image: 'assets/animations/onboarding/recording_onboarding.json',
    ),
    OnboardingItem(
      title: 'Summarize & Visualize',
      description: 'AI summarizes discussions and creates a visual mind map for better understanding.',
      image: 'assets/animations/onboarding/visulize_onboarding.json',
    ),
    OnboardingItem(
      title: 'Organize & Share',
      description: 'Store audio, transcripts, and notes securely — share instantly with your teammates.',
      image: 'assets/animations/onboarding/share_onboarding.json',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _currentPage = 2;
    _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);  
  }

  void _finishOnboarding() {
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _items.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                      child: OnboardingContent(item: _items[i], isActive: i == _currentPage,),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildBottomControls(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage < _items.length - 1
              ? TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                )
              : const SizedBox(width: 64),
          _buildPageIndicator(),
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: ColorManager.primary,
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.primarySolid.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                _currentPage == _items.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(_items.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? ColorManager.primarySolid : ColorManager.textSecondary,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
