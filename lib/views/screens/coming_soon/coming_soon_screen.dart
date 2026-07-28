import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/app_colors.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/spacing.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureName;

  const ComingSoonScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(featureName, style: t.titleLarge?.copyWith(fontSize: 20.sp)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.mainColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: Dimensions.kDefaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 100.sp,
              color: AppColors.mainColor,
            ),
            VSpace(30.h),
            Text(
              "Coming Soon!",
              style: t.headlineMedium?.copyWith(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
              ),
            ),
            VSpace(16.h),
            Text(
              "We are working hard to bring you the $featureName feature. Stay tuned for updates!",
              textAlign: TextAlign.center,
              style: t.bodyLarge?.copyWith(
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ),
            VSpace(50.h),
            AppButton(
              text: "Go Back",
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
