import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/app_colors.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/services/ai_service.dart';
import 'package:paysecure/services/voice_service.dart';
import 'package:paysecure/views/widgets/spacing.dart';

class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen> {
  final AIService _aiService = AIService();
  final VoiceService _voiceService = VoiceService();
  
  bool _isListening = false;
  bool _isProcessing = false;
  String _spokenText = "Tap the microphone and start speaking...";
  String _aiResponse = "";

  @override
  void initState() {
    super.initState();
    _aiService.initialize();
    _voiceService.initialize();
  }

  void _toggleListening() async {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _isProcessing = true;
      });
      _processVoiceInput();
    } else {
      _aiResponse = "";
      final started = await _voiceService.startListening((text) {
        setState(() {
          _spokenText = text;
        });
      });
      if (started) {
        setState(() => _isListening = true);
      } else {
        Get.snackbar(
          "Microphone Permission",
          "Please enable microphone permission in device Settings to use Voice Mode.",
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _processVoiceInput() async {
    if (_spokenText.isEmpty || _spokenText == "Tap the microphone and start speaking...") {
      setState(() => _isProcessing = false);
      return;
    }

    final response = await _aiService.generateResponse(_spokenText);
    setState(() {
      _aiResponse = response;
      _isProcessing = false;
    });

    await _voiceService.speak(_aiResponse);
  }

  @override
  void dispose() {
    _voiceService.stopSpeaking();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Udharcard Voice Mode", style: t.titleLarge?.copyWith(fontSize: 20.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.mainColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: Dimensions.kDefaultPadding,
        child: Column(
          children: [
            VSpace(20.h),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? AppColors.darkCardColor : AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You:",
                        style: t.titleMedium?.copyWith(color: AppColors.mainColor, fontWeight: FontWeight.bold),
                      ),
                      VSpace(10.h),
                      Text(
                        _spokenText,
                        style: t.bodyLarge?.copyWith(fontSize: 16.sp),
                      ),
                      VSpace(30.h),
                      if (_isProcessing)
                        Center(child: CircularProgressIndicator(color: AppColors.mainColor))
                      else if (_aiResponse.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Udharcard AI:",
                              style: t.titleMedium?.copyWith(color: AppColors.greenColor, fontWeight: FontWeight.bold),
                            ),
                            VSpace(10.h),
                            Text(
                              _aiResponse,
                              style: t.bodyLarge?.copyWith(fontSize: 16.sp),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            VSpace(30.h),
            if (_isListening)
              _buildNativeSoundWave(),
            VSpace(20.h),
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isListening ? 90.h : 80.h,
                width: _isListening ? 90.h : 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.redAccent : AppColors.mainColor,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : AppColors.mainColor).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
            ),
            VSpace(40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNativeSoundWave() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(7, (index) {
          final heights = [20.h, 35.h, 50.h, 40.h, 55.h, 30.h, 22.h];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 10.0, end: heights[index % heights.length]),
            duration: Duration(milliseconds: 300 + (index * 70)),
            curve: Curves.easeInOut,
            builder: (context, val, child) {
              return Container(
                width: 6.w,
                height: val,
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
