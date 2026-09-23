import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/app_colors.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
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
  final ProfileController _profileCtrl = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    if (_profileCtrl.profileList.isEmpty) {
      _profileCtrl.getProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    final bool isDark = Get.isDarkMode;

    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GetBuilder<ProfileController>(
          builder: (profileCtrl) {
            final userName = profileCtrl.userName.isNotEmpty
                ? profileCtrl.userName
                : (HiveHelp.read(Keys.userFullName) ?? 'Sonu Saini');
            final userPhone = profileCtrl.phoneNumberEditingController.text.isNotEmpty
                ? profileCtrl.phoneNumberEditingController.text
                : (HiveHelp.read(Keys.userName) ?? '+91 8221825824');
            final userEmail = profileCtrl.userEmail.isNotEmpty
                ? profileCtrl.userEmail
                : 'sonu@rakebig.com';
            final creditLimit = appCtrl.walletList.isNotEmpty
                ? "${appCtrl.walletList[0].currency?.symbol ?? '₹'}${appCtrl.walletList[0].totalBalance ?? '25,000'}"
                : "₹25,000";

            return Scaffold(
              backgroundColor: isDark ? AppColors.darkBgColor : const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: isDark ? AppColors.darkBgColor : Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: widget.isFromHomePage == true || Navigator.of(context).canPop()
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.sp,
                          color: isDark ? Colors.white : AppColors.textDarkColor,
                        ),
                        onPressed: () => Get.back(),
                      )
                    : null,
                centerTitle: true,
                title: Text(
                  storedLanguage['My Profile'] ?? "My Profile",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textDarkColor,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  children: [
                    // ── Avatar with Camera Badge ──
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 90.r,
                            height: 90.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mainColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              color: AppColors.lightBlueTint,
                            ),
                            child: ClipOval(
                              child: profileCtrl.userPhoto.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: profileCtrl.userPhoto,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Image.asset(
                                        "$rootImageDir/avatar.webp",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      "$rootImageDir/avatar.webp",
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 2.r,
                            right: 2.r,
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(RoutesName.editProfileScreen);
                              },
                              child: Container(
                                width: 28.r,
                                height: 28.r,
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    VSpace(20.h),

                    // ── Information Card ──
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardColor : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.cardBorderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileRow("Name", userName, isDark),
                          _buildDivider(isDark),
                          _buildProfileRow("Mobile", userPhone, isDark),
                          _buildDivider(isDark),
                          _buildProfileRow("Email", userEmail, isDark),
                          _buildDivider(isDark),
                          _buildProfileRow("Account Type", "Customer", isDark),
                          _buildDivider(isDark),
                          _buildProfileRow("Credit Limit", creditLimit, isDark, isBoldValue: true),
                          _buildDivider(isDark),
                          _buildProfileRow("Member Since", "Sep 2026", isDark),
                        ],
                      ),
                    ),

                    VSpace(24.h),

                    // ── Menu List Items ──
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardColor : Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isDark ? Colors.white12 : AppColors.cardBorderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.edit_outlined,
                            title: "Edit Profile",
                            isDark: isDark,
                            onTap: () => Get.toNamed(RoutesName.editProfileScreen),
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: "Change Password",
                            isDark: isDark,
                            onTap: () => Get.toNamed(RoutesName.changePasswordScreen),
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: "Help & Support",
                            isDark: isDark,
                            onTap: () => Get.toNamed(RoutesName.supportTicketListScreen),
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: "About UdharCard",
                            isDark: isDark,
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: AppConstants.appName,
                                applicationVersion: "1.0.0",
                                applicationLegalese: "© 2026 Udharcard. Fast. Simple. Secure.",
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    VSpace(20.h),

                    // ── Logout Tile ──
                    GestureDetector(
                      onTap: () => _buildLogoutDialog(context, storedLanguage),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardColor : Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: const Color(0xFFDC2626),
                              size: 22.sp,
                            ),
                            HSpace(12.w),
                            Text(
                              storedLanguage['Logout'] ?? "Logout",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VSpace(30.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value, bool isDark, {bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: isDark ? Colors.white60 : AppColors.textMutedColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDarkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isDark ? Colors.white70 : AppColors.textDarkColor,
            ),
            HSpace(14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.textDarkColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textMutedColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
    );
  }

  Future<dynamic> _buildLogoutDialog(
    BuildContext context,
    Map storedLanguage,
  ) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(storedLanguage['Log Out'] ?? "Log Out"),
          content: Text(
            storedLanguage['Do you want to Log Out?'] ?? "Do you want to Log Out?",
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(storedLanguage['No'] ?? "No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(storedLanguage['Yes'] ?? "Yes"),
              onPressed: () async {
                HiveHelp.remove(Keys.token);
                Get.offAllNamed(RoutesName.loginScreen);
              },
            ),
          ],
        );
      },
    );
  }
}
