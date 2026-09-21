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
    imagePath: "$rootImageDir/onbording_1.webp",
    title: "Scan & Pay Any Store",
    description:
        "Pay your favourite stores instantly by scanning their QR code — no cash needed, no hassle.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_2.webp",
    title: "Your Digital Udhar Passbook",
    description:
        "Track your credit limit, outstanding balance, and every transaction with every store — all in one place.",
  ),
  OnBordingData(
    imagePath: "$rootImageDir/onbording_3.webp",
    title: "Send & Settle Anytime",
    description:
        "Pay off your udhar balance directly from the app using Razorpay — fast, secure, and hassle-free.",
  ),
];
