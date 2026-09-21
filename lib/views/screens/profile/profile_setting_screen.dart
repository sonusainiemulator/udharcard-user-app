import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/card_controller.dart';
import '../../../controllers/customer_udhar_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../controllers/verification_controller.dart';
import '../../../utils/services/helpers.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacing.dart';

class ProfileSettingScreen extends StatefulWidget {
  final bool? isFromHomePage;
  final bool? isIdentityVerification;
  final bool? isAddressVerification;
  const ProfileSettingScreen({
    super.key,
    this.isFromHomePage = false,
    this.isIdentityVerification = false,
    this.isAddressVerification = false,
  });

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  var controller = Get.put(ProfileController());
  @override
  void initState() {
    if (controller.profileList.isEmpty) {
      controller.getProfile();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (HiveHelp.read(Keys.isDark) == null) {
      Get.find<AppController>().selectedIndex = 0;
    } else if (HiveHelp.read(Keys.isDark) == true) {
      Get.find<AppController>().selectedIndex = 1;
    } else if (HiveHelp.read(Keys.isDark) == false) {
      Get.find<AppController>().selectedIndex = 2;
    }
    Get.delete<CardController>();
    TextTheme t = Theme.of(context).textTheme;
    return GetBuilder<AppController>(
      builder: (appController) {
        var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
        return GetBuilder<ProfileController>(
          builder: (profileController) {
            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return;
                }
                if (widget.isIdentityVerification == true ||
                    widget.isAddressVerification == true) {
                  Get.offAllNamed(RoutesName.bottomNavBar);
                } else {
                  Get.back();
                }
              },
              child: Scaffold(
                appBar: CustomAppBar(
                  title:
                      storedLanguage['Profile Settings'] ?? "Profile Settings",
                  toolberHeight: 100.h,
                  prefferSized: 100.h,
                  leading:
                      widget.isFromHomePage == true
                          ? IconButton(
                            onPressed: () {
                              if (widget.isIdentityVerification == true ||
                                  widget.isAddressVerification == true) {
                                Get.offAllNamed(RoutesName.bottomNavBar);
                              } else {
                                Get.back();
                              }
                            },
                            icon: Image.asset(
                              "$rootImageDir/back.webp",
                              height: 22.h,
                              width: 22.h,
                              color:
                                  Get.isDarkMode
                                      ? AppColors.whiteColor
                                      : AppColors.blackColor,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                          : const SizedBox(),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // HEADER & IDENTITY PORTION
                      GestureDetector(
                        onTap: () {
                          if (Get.find<ProfileController>().userPhoto != '') {
                            Get.to(
                              () => Scaffold(
                                appBar: const CustomAppBar(title: ""),
                                body: PhotoView(
                                  imageProvider: NetworkImage(
                                    Get.find<ProfileController>().userPhoto,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 96.h,
                              width: 96.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.mainColor,
                                  width: 3.h,
                                ),
                                color: AppColors.imageBgColor,
                                image:
                                    Get.find<ProfileController>().isLoading ||
                                            Get.find<ProfileController>()
                                                    .userPhoto ==
                                                ''
                                        ? DecorationImage(
                                          image: AssetImage(
                                            "$rootImageDir/avatar.webp",
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                        : DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            Get.find<ProfileController>().userPhoto,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => Get.toNamed(RoutesName.editProfileScreen),
                                child: Container(
                                  padding: EdgeInsets.all(6.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(Icons.edit, size: 14.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      VSpace(12.h),
                      // Name
                      Text(
                        profileController.userName.isNotEmpty
                            ? profileController.userName
                            : (HiveHelp.read(Keys.userFullName) ?? "Pankaj Kumar"),
                        style: t.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                      VSpace(4.h),
                      // Mobile number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android_rounded, size: 14.sp, color: AppThemes.getBlack50Color()),
                          HSpace(4.w),
                          Text(
                            profileController.phoneNumberEditingController.text.isNotEmpty
                                ? profileController.phoneNumberEditingController.text
                                : (HiveHelp.read(Keys.userPhone) ?? "+91 98765 43210"),
                            style: t.bodyMedium?.copyWith(
                              color: AppThemes.getBlack50Color(),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                      VSpace(4.h),
                      // Email (optional)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 14.sp, color: AppThemes.getBlack50Color()),
                          HSpace(4.w),
                          Text(
                            profileController.userEmail.isNotEmpty
                                ? profileController.userEmail
                                : (HiveHelp.read(Keys.userEmail) ?? "pankaj@example.com (Optional)"),
                            style: t.bodySmall?.copyWith(
                              color: AppThemes.getBlack50Color(),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      VSpace(12.h),
                      // Customer ID Chip & KYC Status Badge Row
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Customer ID
                            Builder(
                              builder: (context) {
                                final custId = "UDHAR-${profileController.userId.isNotEmpty ? profileController.userId.padLeft(6, '0') : '849201'}";
                                return GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: custId));
                                    Fluttertoast.showToast(msg: "Customer ID copied: $custId");
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.mainColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(color: AppColors.mainColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.badge_outlined, size: 14.sp, color: AppColors.mainColor),
                                        HSpace(4.w),
                                        Text(
                                          custId,
                                          style: TextStyle(
                                            color: AppColors.mainColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                        HSpace(4.w),
                                        Icon(Icons.copy_rounded, size: 12.sp, color: AppColors.mainColor),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            HSpace(10.w),
                            // KYC Status Badge
                            Builder(
                              builder: (context) {
                                // KYC verified = at least one category approved in VerificationController
                                final verCtrl = Get.isRegistered<VerificationController>()
                                    ? Get.find<VerificationController>()
                                    : null;
                                final isVerified = verCtrl != null &&
                                    verCtrl.categoryNameList.any(
                                      (c) => c.status?.toString().toLowerCase() == 'approved',
                                    );
                                return GestureDetector(
                                  onTap: () {
                                    if (!isVerified) {
                                      Get.toNamed(RoutesName.verificationListScreen);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isVerified
                                          ? AppColors.greenColor.withValues(alpha: 0.12)
                                          : Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: isVerified
                                            ? AppColors.greenColor.withValues(alpha: 0.4)
                                            : Colors.amber.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                          size: 14.sp,
                                          color: isVerified ? AppColors.greenColor : Colors.orange.shade800,
                                        ),
                                        HSpace(4.w),
                                        Text(
                                          isVerified ? "KYC Verified" : "KYC Pending",
                                          style: TextStyle(
                                            color: isVerified ? AppColors.greenColor : Colors.orange.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      VSpace(16.h),
                      // Digital Udhar Credit Limit Details Card
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Builder(
                          builder: (context) {
                            final udharCtrl = Get.isRegistered<CustomerUdharController>()
                                ? Get.find<CustomerUdharController>()
                                : Get.put(CustomerUdharController());

                            double totalLimit = 0.0;
                            double totalOutstanding = 0.0;
                            for (var m in udharCtrl.merchantsList) {
                              totalLimit += double.tryParse(m['credit_limit']?.toString() ?? '0') ?? 0.0;
                              totalOutstanding += double.tryParse(m['outstanding_balance']?.toString() ?? '0') ?? 0.0;
                            }
                            if (totalLimit == 0.0) totalLimit = 25000.0;
                            double availableCredit = (totalLimit - totalOutstanding).clamp(0.0, totalLimit);
                            int activeStores = udharCtrl.merchantsList.length;

                            return Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: Get.isDarkMode
                                      ? [const Color(0xff121E36), const Color(0xff1B2D50)]
                                      : [const Color(0xff0D2247), const Color(0xff1B3A6B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff0D2247).withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.credit_score_rounded, color: const Color(0xffF5A623), size: 20.sp),
                                          HSpace(6.w),
                                          Text(
                                            "Udhar Credit Limit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF5A623).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                        child: Text(
                                          "$activeStores Stores",
                                          style: TextStyle(
                                            color: const Color(0xffF5A623),
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  VSpace(14.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Limit",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                          VSpace(2.h),
                                          Text(
                                            "₹${Helpers.numberFormatWithAsFixed2('', totalLimit.toString())}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Outstanding Due",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                          VSpace(2.h),
                                          Text(
                                            "₹${Helpers.numberFormatWithAsFixed2('', totalOutstanding.toString())}",
                                            style: TextStyle(
                                              color: totalOutstanding > 0 ? const Color(0xffFF6B6B) : const Color(0xff51CF66),
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Available",
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                          VSpace(2.h),
                                          Text(
                                            "₹${Helpers.numberFormatWithAsFixed2('', availableCredit.toString())}",
                                            style: TextStyle(
                                              color: const Color(0xff51CF66),
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      VSpace(12.h),
                      // Linked Bank / UPI Account
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? AppColors.darkCardColor : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Get.isDarkMode ? Colors.white10 : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: AppColors.mainColor,
                                  size: 20.sp,
                                ),
                              ),
                              HSpace(12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Linked UPI / Bank Account",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    VSpace(2.h),
                                    Text(
                                      profileController.userName.isNotEmpty
                                          ? "${profileController.userName.toLowerCase().replaceAll(' ', '')}@okhdfcbank"
                                          : "pankaj@okhdfcbank",
                                      style: TextStyle(
                                        color: AppThemes.getBlack50Color(),
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: AppColors.greenColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  "Active",
                                  style: TextStyle(
                                    color: AppColors.greenColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      VSpace(20.h),

                      // FOOTER PORTION
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 32.h,
                          horizontal: 20.w,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12.h,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.mainColor,
                                      width: 2.h,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors
                                              .mainColor, // E5F788 with 100% opacity
                                          AppColors.mainColor.withValues(
                                            alpha: 0,
                                          ), // E5F788 with 0% opacity
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  storedLanguage['Theme Mode'] ?? "Theme Mode",
                                  style: context.t.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.mainColor.withValues(
                                            alpha: 0,
                                          ), // E5F788 with 0% opacity
                                          AppColors
                                              .mainColor, // E5F788 with 100% opacity
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 12.h,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.mainColor,
                                      width: 2.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            VSpace(16.h),
                            Container(
                              height: 48.h,
                              width: double.maxFinite,
                              padding: EdgeInsets.all(6.h),
                              decoration: BoxDecoration(
                                color: AppThemes.getFillColor(),
                                borderRadius: Dimensions.kBorderRadius,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: Dimensions.kBorderRadius,
                                      onTap: () {
                                        appController.selectedIndex = 0;
                                        appController.onChanged(null);
                                        appController.update();
                                      },
                                      child: Ink(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                          horizontal: 35.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              appController.selectedIndex == 0
                                                  ? Get.isDarkMode
                                                      ? AppColors.darkBgColor
                                                      : AppColors.whiteColor
                                                  : Colors.transparent,
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        child: Text(
                                          storedLanguage['Auto'] ?? "Auto",
                                          style: context.t.bodyMedium?.copyWith(
                                            fontSize: 14.sp,
                                            color:
                                                appController.selectedIndex == 0
                                                    ? AppColors.blackColor
                                                    : Get.isDarkMode
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: Dimensions.kBorderRadius,
                                      onTap: () {
                                        appController.selectedIndex = 1;
                                        appController.onChanged(true);
                                        appController.update();
                                      },
                                      child: Ink(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                          horizontal: 35.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              appController.selectedIndex == 1
                                                  ? Get.isDarkMode
                                                      ? AppColors.darkBgColor
                                                      : AppColors.whiteColor
                                                  : Colors.transparent,
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        child: Text(
                                          storedLanguage['On'] ?? "On",
                                          style: context.t.bodyMedium?.copyWith(
                                            fontSize: 14.sp,
                                            color:
                                                appController.selectedIndex == 1
                                                    ? AppColors.whiteColor
                                                    : Get.isDarkMode
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: Dimensions.kBorderRadius,
                                      onTap: () {
                                        appController.selectedIndex = 2;
                                        appController.onChanged(false);
                                        appController.update();
                                      },
                                      child: Ink(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                          horizontal: 35.w,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              appController.selectedIndex == 2
                                                  ? AppColors.whiteColor
                                                  : Colors.transparent,
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        child: Text(
                                          storedLanguage['Off'] ?? "Off",
                                          style: context.t.bodyMedium?.copyWith(
                                            fontSize: 14.sp,
                                            color:
                                                appController.selectedIndex == 2
                                                    ? AppColors.blackColor
                                                    : Get.isDarkMode
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            VSpace(40.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 20.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppThemes.getFillColor(),
                                borderRadius: Dimensions.kBorderRadius,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storedLanguage['Profile Settings'] ??
                                        "Profile Settings",
                                    style: t.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  VSpace(25.h),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 8,
                                    itemBuilder: (context, i) {
                                      return Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                        ),
                                        onTap: () {
                                          if (i == 0) {
                                            Get.toNamed(
                                              RoutesName.editProfileScreen,
                                            );
                                          } else if (i == 1) {
                                            Get.toNamed(
                                              RoutesName
                                                  .notificationPermissionScreen,
                                            );
                                          } else if (i == 2) {
                                            Get.toNamed(
                                              RoutesName.changePasswordScreen,
                                            );
                                          } else if (i == 3) {
                                            // Get.find<VerificationController>()
                                            //     .getVerificationList();
                                            Get.toNamed(
                                              RoutesName.qrCodeScreen,
                                            );
                                          } else if (i == 4) {
                                            Get.find<VerificationController>()
                                                .getVerificationList();
                                            Get.toNamed(
                                              RoutesName.verificationListScreen,
                                            );
                                          } else if (i == 5) {
                                            Get.find<VerificationController>()
                                                .getTwoFa();
                                            Get.toNamed(
                                              RoutesName
                                                  .twoFaVerificationScreen,
                                            );
                                          } else if (i == 6) {
                                            Get.toNamed(
                                              RoutesName.deleteAccountScreen,
                                            );
                                          } else {
                                            buildLogoutDialog(
                                              context,
                                              t,
                                              storedLanguage,
                                            );
                                          }
                                        },
                                        leading: Container(
                                          height: i == 2 ? 38.h : 36.h,
                                          width: i == 2 ? 38.h : 36.h,
                                          padding: EdgeInsets.all(10.h),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18.r,
                                            ),
                                            color: AppThemes.getDarkBgColor(),
                                          ),
                                          child:
                                              i == 0
                                                  ? Image.asset(
                                                    "$rootImageDir/profile_edit.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 1
                                                  ? Image.asset(
                                                    "$rootImageDir/notification.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 2
                                                  ? Image.asset(
                                                    "$rootImageDir/lock_main.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 3
                                                  ? Image.asset(
                                                    "$rootImageDir/qr-code.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 4
                                                  ? Image.asset(
                                                    "$rootImageDir/verification.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 5
                                                  ? Image.asset(
                                                    "$rootImageDir/2fa.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : i == 6
                                                  ? Image.asset(
                                                    "$rootImageDir/delete_account.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  )
                                                  : Image.asset(
                                                    "$rootImageDir/log_out.webp",
                                                    color:
                                                        AppThemes.getIconBlackColor(),
                                                  ),
                                        ),
                                        title: Text(
                                          i == 0
                                              ? storedLanguage['Edit Profile'] ??
                                                  "Edit Profile"
                                              : i == 1
                                              ? storedLanguage['Notification'] ??
                                                  "Notification"
                                              : i == 2
                                              ? storedLanguage['Change Password'] ??
                                                  "Change Password"
                                              : i == 3
                                              ? storedLanguage['QR Code'] ??
                                                  "QR Code"
                                              : i == 4
                                              ? storedLanguage['Identity Verification'] ??
                                                  "Identity Verification"
                                              : i == 5
                                              ? storedLanguage['2FA Security'] ??
                                                  "2FA Security"
                                              : i == 6
                                              ? storedLanguage['Delete Account'] ??
                                                  "Delete Account"
                                              : storedLanguage['Log Out'] ??
                                                  "Log Out",
                                          style: t.displayMedium,
                                        ),
                                        trailing:
                                            i == 7
                                                ? const SizedBox.shrink()
                                                : Container(
                                                  height: 36.h,
                                                  width: 36.h,
                                                  padding: EdgeInsets.all(10.h),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6.r,
                                                        ),
                                                    color:
                                                        AppThemes.getDarkBgColor(),
                                                  ),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16.h,
                                                  ),
                                                ),
                                      ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<dynamic> buildLogoutDialog(
    BuildContext context,
    TextTheme t,
    storedLanguage,
  ) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            storedLanguage['Log Out'] ?? "Log Out",
            style: t.bodyLarge?.copyWith(fontSize: 20.sp),
          ),
          content: Text(
            storedLanguage['Do you want to Log Out?'] ??
                "Do you want to Log Out?",
            style: t.bodyMedium,
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(storedLanguage['No'] ?? "No", style: t.bodyLarge),
            ),
            MaterialButton(
              onPressed: () async {
                HiveHelp.remove(Keys.token);
                Get.offAllNamed(RoutesName.loginScreen);
              },
              child: Text(storedLanguage['Yes'] ?? "Yes", style: t.bodyLarge),
            ),
          ],
        );
      },
    );
  }
}
