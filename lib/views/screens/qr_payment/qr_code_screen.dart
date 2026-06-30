import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/controllers/profile_controller.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareQrCode() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Get.snackbar(
          'QR Code',
          'QR Code captured successfully!',
          backgroundColor: AppColors.mainColor,
          colorText: AppColors.whiteColor,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(16.r),
          borderRadius: 12.r,
        );
      }
    } catch (e) {
      debugPrint('Error capturing QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        final userName = profileController.userName.isNotEmpty
            ? profileController.userName
            : 'User';
        final qrData = profileController.qrLink;

        return Scaffold(
          backgroundColor:
              Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
          appBar: CustomAppBar(
            title: storedLanguage['My QR Code'] ?? 'My QR Code',
          ),
          body: SingleChildScrollView(
            padding: Dimensions.kDefaultPadding,
            child: Column(
              children: [
                VSpace(24.h),

                // ── QR Card ──────────────────────────────────────────────
                RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? AppColors.darkCardColor
                          : AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainColor.withValues(alpha: .12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Gradient border
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainColor,
                                  AppColors.secondaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                        // White inner card
                        Container(
                          margin: EdgeInsets.all(3.r),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? AppColors.darkCardColor
                                : AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 28.h,
                            horizontal: 24.w,
                          ),
                          child: Column(
                            children: [
                              // User name
                              Text(
                                userName.toUpperCase(),
                                style: context.t.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  letterSpacing: 0.5,
                                  color: AppThemes.getIconBlackColor(),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              VSpace(4.h),
                              // QR ID / UPI ID
                              if (qrData.isNotEmpty)
                                Text(
                                  qrData.length > 30
                                      ? '${qrData.substring(0, 30)}...'
                                      : qrData,
                                  style: context.t.bodySmall?.copyWith(
                                    color: AppColors.greyColor,
                                    fontSize: 13.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              VSpace(24.h),

                              // QR code with center logo
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Decorative corner frame
                                  Container(
                                    padding: EdgeInsets.all(12.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.mainColor
                                            .withValues(alpha: .15),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: QrImageView(
                                      data: qrData.isEmpty
                                          ? 'udharcard-payment'
                                          : qrData,
                                      version: QrVersions.auto,
                                      size: 220.h,
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: AppThemes.getIconBlackColor(),
                                      ),
                                      eyeStyle: QrEyeStyle(
                                        color: AppColors.mainColor,
                                        eyeShape: QrEyeShape.square,
                                      ),
                                    ),
                                  ),
                                  // Center logo overlay
                                  Container(
                                    width: 44.h,
                                    height: 44.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: .1),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(6.h),
                                    child: Image.asset(
                                      '$rootImageDir/app_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),

                              VSpace(20.h),

                              // Scan to pay label
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 16.h,
                                    color: AppColors.greyColor,
                                  ),
                                  HSpace(6.w),
                                  Text(
                                    storedLanguage['Scan to pay'] ??
                                        'Scan to pay with any UPI app',
                                    style: context.t.bodySmall?.copyWith(
                                      color: AppColors.greyColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                VSpace(32.h),

                // ── Share / Download Button ──────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton.icon(
                    onPressed: _shareQrCode,
                    icon: Icon(Icons.share_rounded, size: 20.h),
                    label: Text(
                      storedLanguage['Share QR Code'] ?? 'Share QR Code',
                      style: context.t.bodyMedium?.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      foregroundColor: AppColors.whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),

                VSpace(12.h),

                // ── Save to Gallery Button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: OutlinedButton.icon(
                    onPressed: _shareQrCode,
                    icon: Icon(
                      Icons.download_rounded,
                      size: 20.h,
                      color: AppColors.mainColor,
                    ),
                    label: Text(
                      storedLanguage['Save to Gallery'] ?? 'Save to Gallery',
                      style: context.t.bodyMedium?.copyWith(
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.mainColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                ),

                VSpace(24.h),

                // ── Hint text ───────────────────────────────────────────
                Text(
                  storedLanguage['qr_hint'] ??
                      'Show this QR code to receive payment.\nOther users can scan it with any UPI app.',
                  textAlign: TextAlign.center,
                  style: context.t.bodySmall?.copyWith(
                    color: AppColors.greyColor,
                    fontSize: 13.sp,
                    height: 1.6,
                  ),
                ),

                VSpace(32.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
