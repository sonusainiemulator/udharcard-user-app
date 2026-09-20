import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/app_colors.dart';
import '../../config/dimensions.dart';
import '../../config/styles.dart';
import '../../themes/themes.dart';
import '../../views/widgets/spacing.dart';
import '../app_constants.dart';

class Helpers {
  static showToast({
    Color? bgColor,
    Color? textColor,
    String? msg,
    ToastGravity? gravity = ToastGravity.CENTER,
  }) {
    return Fluttertoast.showToast(
      msg: msg ?? 'Field must not be empty!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: bgColor ?? Colors.red,
      textColor: textColor ?? Colors.white,
      fontSize: 16.sp,
    );
  }

  static bool _isToastVisible = false;
  static showSnackBar({
    String msg = "Field must not be empty!",
    String title = "Notification",
    int? durationTime = 3,
    Widget? icon,
    Widget? titleText,
    Widget? messageText,
    Color? textColor,
    Color? bgColor,
    SnackPosition? snackPosition = SnackPosition.BOTTOM,
  }) {
    if (_isToastVisible) {
      debugPrint("A toast is already visible. Skipping...");
      return;
    }

    _isToastVisible = true;
    bool _isError =
        (title == 'Failed' ||
            title == 'Error!' ||
            title == 'Error' ||
            title == 'error');

    Get.snackbar(
      title,
      msg,
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
      backgroundColor: bgColor ?? (_isError ? const Color(0xFFDC2626) : const Color(0xFF1E293B)),
      colorText: textColor ?? Colors.white,
      icon: icon ??
          Icon(
            _isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 22.sp,
          ),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 300),
      duration: Duration(seconds: durationTime ?? 3),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          _isToastVisible = false;
        }
      },
    );
  }

  /// Premium, elegant success notification for OTP and confirmations
  static showSuccessSnackBar({
    required String title,
    required String msg,
    int durationTime = 3,
    SnackPosition snackPosition = SnackPosition.TOP,
  }) {
    if (_isToastVisible) {
      Get.closeCurrentSnackbar();
      _isToastVisible = false;
    }

    _isToastVisible = true;
    Get.snackbar(
      title,
      msg,
      snackPosition: snackPosition,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      borderRadius: 14.r,
      backgroundColor: const Color(0xFF0F766E),
      colorText: Colors.white,
      icon: Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
      titleText: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        msg,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF0F766E).withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 350),
      duration: Duration(seconds: durationTime),
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          _isToastVisible = false;
        }
      },
    );
  }

  /// hide keyboard automatically when click anywhere in screen
  static hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static notFound({double? top, String? text}) => Center(
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: top ?? Dimensions.screenHeight * .25),
          height: 200.h,
          width: 200.h,
          child: Image.asset(
            Get.isDarkMode
                ? "$rootImageDir/not_found_dark.webp"
                : "$rootImageDir/not_found.webp",
            fit: BoxFit.cover,
          ),
        ),
        VSpace(20.h),
        Text(
          text ?? "No data found",
          style: Styles.baseStyle.copyWith(
            color: AppThemes.getIconBlackColor(),
          ),
        ),
      ],
    ),
  );

  static appLoader({Color? color}) => Center(
    child: CircularProgressIndicator(color: color ?? AppColors.mainColor),
  );

  static String numberFormatWithAsFixed2([
    String? currencySymbol,
    String? amount,
  ]) {
    if (amount == null || amount.isEmpty) return "";

    try {
      double parsedAmount = double.parse(amount);
      if (parsedAmount == parsedAmount.toInt()) {
        return NumberFormat('#,##0').format(parsedAmount);
      } else {
        return NumberFormat.currency(
          symbol: currencySymbol,
        ).format(parsedAmount);
      }
    } catch (e) {
      return "";
    }
  }
}

extension StringExtension on String {
  String toCapital() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
