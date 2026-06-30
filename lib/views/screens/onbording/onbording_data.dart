import '../../../utils/app_constants.dart';

class OnBordingData {
  String imagePath;
  String title;
  String description;

  OnBordingData({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

List<OnBordingData> onBordingDataList = [
  OnBordingData(
    imagePath: "$rootImageDir/onbording_1.webp",
    title: "Send Money More Wisely",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_2.webp",
    title: "Smart Money Management",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_3.webp",
    title: "Easiest way to Send Money",
    description:
        "Lorem Ipsum is simply dummy text of the\nprinting and typesetting industry.",
  ),
];
