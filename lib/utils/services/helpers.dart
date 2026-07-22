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
    String title = "Error!",
    int? durationTime = 3,
    Widget? icon,
    Widget? titleText,
    Widget? messageText,
    Color? textColor,
    Color? bgColor,
    SnackPosition? snackPosition = SnackPosition.TOP,
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
      snackPosition: snackPosition ?? SnackPosition.TOP,
      margin: EdgeInsets.zero,
      borderRadius: 0,
      backgroundColor: _isError ? AppColors.redColor : AppColors.greenColor,
      colorText: Colors.white,
      icon: Icon(
        _isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      animationDuration: const Duration(milliseconds: 300),
      duration: Duration(seconds: durationTime ?? 3),
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
