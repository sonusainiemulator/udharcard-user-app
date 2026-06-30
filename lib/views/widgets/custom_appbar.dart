import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../themes/themes.dart';
import '../../utils/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String? title;
  final double? toolberHeight;
  final double? prefferSized;
  final Color? bgColor;
  final bool? isReverseIconBgColor;
  final bool? isTitleMarginTop;
  final double? fontSize;
  final Widget? titleWidget;
  final void Function()? onBackPressed;
  const CustomAppBar({
    super.key,
    this.leading,
    this.actions,
    this.title,
    this.titleWidget,
    this.toolberHeight,
    this.prefferSized,
    this.isReverseIconBgColor = false,
    this.isTitleMarginTop = false,
    this.bgColor,
    this.onBackPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    return AppBar(
      toolbarHeight: toolberHeight ?? 100.h,
      backgroundColor: bgColor,
      centerTitle: true,
      title:
          titleWidget ??
          Padding(
            padding:
                isTitleMarginTop == true
                    ? EdgeInsets.only(top: Platform.isIOS ? 40.h : 20.h)
                    : EdgeInsets.zero,
            child: Text(
              title ?? "",
              style: t.titleMedium?.copyWith(fontSize: fontSize ?? 26.sp),
            ),
          ),
      leading:
          leading ??
          IconButton(
            onPressed:
                onBackPressed ??
                () {
                  Get.back();
                },
            icon: Image.asset(
              "$rootImageDir/back.webp",
              height: 22.h,
              width: 22.h,
              color: AppThemes.getIconBlackColor(),
              fit: BoxFit.fitHeight,
            ),
          ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(prefferSized ?? 70.h);
}
