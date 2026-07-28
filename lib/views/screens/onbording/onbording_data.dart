import '../../../utils/app_constants.dart';

class OnBordingData {
  String imagePath;
  String title;
  String description;
  bool isLottie;

  OnBordingData({
    required this.imagePath,
    required this.title,
    required this.description,
    this.isLottie = false,
  });
}

List<OnBordingData> onBordingDataList = [
  OnBordingData(
    imagePath: "https://assets10.lottiefiles.com/packages/lf20_9n6u5p4v.json",
    title: "Voice Mode with AI",
    description: "Talk to Udharcard using Gemini AI to manage your app hands-free with Hindi audio alerts.",
    isLottie: true,
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_1.webp",
    title: "Send Money More Wisely",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_2.webp",
    title: "Smart Money Management",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_3.webp",
    title: "Easiest way to Send Money",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
];
