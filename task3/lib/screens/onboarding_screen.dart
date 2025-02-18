import 'package:flutter/material.dart';
import 'package:task3/models/onboarding_content.dart';
import 'package:task3/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Explore the world easily",
      subtitle: "To your desire",
      image: "image/Group 32.png",
    ),
    OnboardingContent(
      title: "Reach the unknown spot",
      subtitle: "To your destination",
      image: "image/Group 33.png",
    ),
    OnboardingContent(
      title: "Make connects with Travello",
      subtitle: "To your dream trip",
      image: "image/Group 34.png",
    ),
  ];

  void _handleNextPage() {
    if (_currentPage == _contents.length - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _contents.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(content: _contents[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    _contents.length,
                    (index) => buildDot(index),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: _handleNextPage,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index
            ? const Color(0xFFFF4D67)
            : const Color(0xFFFF4D67).withOpacity(0.3),
      ),
    );
  }
}
