import 'package:flutter/material.dart';
import '../design_system/colors.dart';
import '../design_system/spacing.dart';
import '../utils/haptic_feedback.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.shopping_cart_outlined,
      title: 'Welcome to Grocli',
      description:
          'Your smart grocery list assistant that helps you organize shopping efficiently.',
      color: GrocliColors.primaryGreen,
    ),
    OnboardingPage(
      icon: Icons.chat_bubble_outline,
      title: 'AI-Powered Suggestions',
      description:
          'Chat with our AI assistant to get smart recommendations and recipe ideas.',
      color: GrocliColors.accentBlue,
    ),
    OnboardingPage(
      icon: Icons.check_circle_outline,
      title: 'Track Your Items',
      description:
          'Easily add, check off, and organize items by category. Swipe to delete!',
      color: GrocliColors.secondaryOrange,
    ),
    OnboardingPage(
      icon: Icons.accessibility_new,
      title: 'Accessible & Intuitive',
      description:
          'Designed with accessibility in mind - works great with screen readers and supports text scaling.',
      color: GrocliColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      GrocliHaptics.light();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      GrocliHaptics.success();
      widget.onComplete();
    }
  }

  void _skipOnboarding() {
    GrocliHaptics.light();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Semantics(
                  button: true,
                  label: 'Skip onboarding',
                  child: const Text('SKIP'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  GrocliHaptics.selection();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(GrocliSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(
                          horizontal: GrocliSpacing.xxs,
                        ),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? GrocliColors.primaryGreen
                              : GrocliColors.divider,
                          borderRadius: BorderRadius.circular(
                            GrocliSpacing.borderRadiusRound,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: GrocliSpacing.lg),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Semantics(
                      button: true,
                      label: _currentPage < _pages.length - 1
                          ? 'Next page'
                          : 'Get started',
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'NEXT'
                            : 'GET STARTED',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GrocliSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(GrocliSpacing.xl),
              decoration: BoxDecoration(
                color: page.color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: GrocliSpacing.xl),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GrocliSpacing.md),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GrocliColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
