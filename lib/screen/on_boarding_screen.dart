import 'package:flutter/material.dart';
import 'package:heart_reading/constant/dimentions.dart';
import 'package:heart_reading/screen/logain.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/file_2274790.png",
      "descriptionAr": "التعليمات لاستخدام الجهاز بشكل صحيح.",
      "descriptionEn": "How to Use the Device Correctly.",
    },
    {
      "image": "assets/wash1.png",
      "descriptionAr": "اغسل جلدك جيدًا قبل استخدام الجهاز.",
      "descriptionEn": "Wash your skin well before using the device.",
    },
    {
      "image": "assets/lamps2.png",
      "descriptionAr":
          "لا تعرض الجهاز لضوء قوي أثناء التشغيل، خاصة ضوء الشمس أو المصابيح القوية.",
      "descriptionEn":
          "Do not expose the device to strong light while using it, especially sunlight or bright lamps.",
    },
    {
      "image": "assets/dev3.png",
      "descriptionAr": "ضع الجهاز في مكانه الصحيح على الجلد.",
      "descriptionEn": "Place the device correctly on your skin.",
    },
    {
      "image": "assets/movee4.png",
      "descriptionAr": "ابقَ ثابتًا أثناء القياس للحصول على نتائج صحيحة.",
      "descriptionEn":
          "Stay still during the measurement to get accurate results.",
    },
    {
      "image": "assets/electric5.png",
      "descriptionAr":
          "ابتعد عن الأجهزة الكهربائية القوية مثل الهاتف أو الميكروويف، حتى لا تؤثر على الجهاز.",
      "descriptionEn":
          "Stay away from strong electrical devices like phones or microwaves, so they don’t affect the device.",
    },
    {
      "image": "assets/clock_2997985.png",
      "descriptionAr": "حاول القياس كل يوم في نفس الوقت.",
      "descriptionEn": "Try to measure at the same time every day.",
    },
    {
      "image": "assets/shigar7.png",
      "descriptionAr":
          "إذا كنت تقيس السكر يوميًا، اختر وقتًا ثابتًا، مثل قبل الأكل أو بعده، حتى تتمكن من مقارنة النتائج بسهولة.",
      "descriptionEn":
          "If you measure your sugar daily, choose a fixed time, like before or after eating, so you can compare results easily.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => const LoginPage(), // Replace with your login screen
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder:
                  (context, index) => OnboardingPage(
                    imagePath: onboardingData[index]['image']!,
                    descriptionAr: onboardingData[index]['descriptionAr']!,
                    descriptionEn: onboardingData[index]['descriptionEn']!,
                    isActive: _currentIndex == index,
                  ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.all(Dimentions.hightPercentage(context, 0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _finishOnboarding,
            child: const Text("Skip", style: TextStyle(color: Colors.black)),
          ),
          Row(
            children: List.generate(
              onboardingData.length,
              (index) => AnimatedContainer(
                margin: EdgeInsets.symmetric(
                  horizontal: Dimentions.widthPercentage(context, 2.5),
                ),
                duration: const Duration(milliseconds: 300),
                width: _currentIndex == index ? 16 : 8,
                height: Dimentions.hightPercentage(context, 1.5),
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: Dimentions.widthPercentage(context, 2.5),
              ),
            ),
            onPressed: _nextPage,
            child: Text(
              style: TextStyle(color: Colors.black, fontSize: 16),
              _currentIndex == onboardingData.length - 1 ? "Start" : "Next",
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String descriptionAr;
  final String descriptionEn;
  final bool isActive;

  const OnboardingPage({
    Key? key,
    required this.imagePath,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: AnimatedScale(
        scale: isActive ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 600),
        child: AnimatedSlide(
          offset: isActive ? Offset.zero : const Offset(0.5, 0),
          duration: const Duration(milliseconds: 600),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimentions.widthPercentage(context, 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath,
                    width: Dimentions.hightPercentage(context, 50),
                    height: Dimentions.hightPercentage(context, 50),
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    descriptionAr,
                    style: TextStyle(
                      fontSize: Dimentions.fontPercentage(context, 2.5),
                      fontFamily: "Lemonada",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Dimentions.hightPercentage(context, 1)),
                  Text(
                    descriptionEn,
                    style: TextStyle(
                      fontSize: Dimentions.fontPercentage(context, 2.5),
                      color: Colors.grey,
                      fontFamily: "Lemonada",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
