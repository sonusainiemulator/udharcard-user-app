import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paysecure/utils/app_constants.dart';
import 'package:paysecure/utils/services/localstorage/hive.dart';
import 'package:paysecure/views/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/spacing.dart';
import 'package:country_code_picker/country_code_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode node = FocusNode();
  @override
  void initState() {
    node.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    AuthController controller = Get.find<AuthController>();
    TextTheme t = Theme.of(context).textTheme;
    //--------------REMEMBER ME----------------
    if (HiveHelp.read(Keys.userName) != null &&
        HiveHelp.read(Keys.isRemember) != null) {
      if (HiveHelp.read(Keys.isRemember) == true) {
        if (controller.phoneController.text.isEmpty) {
          controller.phoneController.text = HiveHelp.read(Keys.userName);
        }
      }
    }
    if (HiveHelp.read(Keys.isRemember) != null) {
      controller.isRemember = HiveHelp.read(Keys.isRemember);
    }
    return GetBuilder<AuthController>(
      builder: (_) {
        return Scaffold(
          body: Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    "$rootImageDir/shape.webp",
                    height: 153.h,
                    fit: BoxFit.cover,
                    color: AppColors.mainColor.withValues(alpha: .1),
                  ),
                ),
                Padding(
                  padding: Dimensions.kDefaultPadding,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VSpace(60.h),
                        Center(
                          child: Image.asset(
                            "$rootImageDir/app_logo.png",
                            height: 120.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        VSpace(30.h),
                        Text(
                          storedLanguage['Log In'] ?? "Log In",
                          style: t.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 30.sp,
                          ),
                        ),
                        VSpace(12.h),
                        Text(
                          storedLanguage['Hello there, log in to continue!'] ??
                              "Hello there, log in to continue!",
                          style: t.displayMedium?.copyWith(
                            color: AppThemes.getParagraphColor(),
                          ),
                        ),
                        VSpace(40.h),
                        if (!controller.isOtpSent) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: Dimensions.textFieldHeight,
                                decoration: BoxDecoration(
                                  borderRadius: Dimensions.kBorderRadius,
                                  border: Border.all(
                                    color: AppThemes.getSliderInactiveColor(),
                                    width: 1,
                                  ),
                                ),
                                child: CountryCodePicker(
                                  enabled: true,
                                  padding: EdgeInsets.zero,
                                  dialogBackgroundColor:
                                      AppThemes.getDarkCardColor(),
                                  dialogTextStyle: t.bodyMedium?.copyWith(
                                    fontSize: 16.sp,
                                  ),
                                  flagWidth: 29.w,
                                  textStyle: t.displayMedium,
                                  onChanged: (CountryCode countryCode) {
                                    controller.countryCode = countryCode.code!;
                                    controller.phoneCode = countryCode.dialCode!;
                                    controller.countryName = countryCode.name!;
                                    controller.update();
                                  },
                                  initialSelection: controller.countryCode,
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                ),
                              ),
                              HSpace(16.w),
                              Expanded(
                                child: CustomTextField(
                                  hintext:
                                      storedLanguage['Phone Number'] ??
                                      "Phone Number",
                                  isPrefixIcon: true,
                                  prefixIcon: 'call',
                                  keyboardType: TextInputType.phone,
                                  controller: controller.phoneController,
                                  onChanged: (v) {
                                    controller.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                          VSpace(24.h),
                          Row(
                            children: [
                              Transform.scale(
                                scale: .82,
                                child: Checkbox(
                                  checkColor: AppColors.whiteColor,
                                  activeColor: AppColors.mainColor,
                                  visualDensity: const VisualDensity(
                                    horizontal: -4.0,
                                    vertical: -4.0,
                                  ),
                                  side: BorderSide(
                                    color: AppThemes.getHintColor(),
                                  ),
                                  value: controller.isRemember,
                                  onChanged: (v) {
                                    controller.isRemember = v!;
                                    HiveHelp.write(Keys.isRemember, v);
                                    if (v) {
                                      HiveHelp.write(Keys.userName, controller.phoneController.text);
                                    } else {
                                      HiveHelp.remove(Keys.userName);
                                    }
                                    controller.update();
                                  },
                                ),
                              ),
                              HSpace(5.w),
                              Text(
                                storedLanguage['Remember me'] ?? "Remember me",
                                style: t.bodySmall?.copyWith(
                                  fontSize: 16.sp,
                                  color: Get.isDarkMode
                                      ? AppColors.whiteColor
                                      : AppColors.black30,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          VSpace(48.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: storedLanguage['Send OTP'] ?? "Send OTP",
                              isLoading: controller.isLoading ? true : false,
                              bgColor: controller.phoneController.text.isEmpty
                                  ? AppThemes.getInactiveColor()
                                  : AppColors.mainColor,
                              onTap: controller.phoneController.text.isEmpty
                                  ? null
                                  : controller.isLoading
                                  ? null
                                  : () async {
                                      Helpers.hideKeyboard();
                                      if (controller.isRemember) {
                                        HiveHelp.write(Keys.userName, controller.phoneController.text);
                                      }
                                      String fullPhone = "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                      await controller.sendOtp(fullPhone);
                                    },
                            ),
                          ),
                        ] else ...[
                          Text(
                            "${storedLanguage['Verification code sent to'] ?? 'Verification code sent to'} ${controller.phoneCode} ${controller.phoneController.text}",
                            style: t.displayMedium?.copyWith(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.sp,
                            ),
                          ),
                          VSpace(32.h),
                          CustomTextField(
                            hintext: storedLanguage['6-Digit OTP'] ?? "6-Digit OTP",
                            isPrefixIcon: true,
                            prefixIcon: 'lock',
                            keyboardType: TextInputType.number,
                            controller: controller.otpController,
                            onChanged: (v) {
                              controller.update();
                            },
                          ),
                          VSpace(48.h),
                          Material(
                            color: Colors.transparent,
                            child: AppButton(
                              text: storedLanguage['Verify & Login'] ?? "Verify & Login",
                              isLoading: controller.isLoading ? true : false,
                              bgColor: controller.otpController.text.length < 6
                                  ? AppThemes.getInactiveColor()
                                  : AppColors.mainColor,
                              onTap: controller.otpController.text.length < 6
                                  ? null
                                  : controller.isLoading
                                  ? null
                                  : () async {
                                      Helpers.hideKeyboard();
                                      String fullPhone = "${controller.phoneCode}${controller.phoneController.text.trim()}";
                                      await controller.verifyOtpAndLogin(
                                        controller.otpController.text.trim(),
                                        fullPhone,
                                      );
                                    },
                            ),
                          ),
                          VSpace(20.h),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                controller.isOtpSent = false;
                                controller.otpController.clear();
                                controller.update();
                              },
                              child: Text(
                                storedLanguage['Change Phone Number'] ??
                                    "Change Phone Number",
                                style: t.bodyMedium?.copyWith(
                                  color: AppThemes.getHintColor(),
                                ),
                              ),
                            ),
                          ),
                        ],
                        VSpace(118.h),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            storedLanguage['Don\'t have an account?'] ??
                                "Don’t have an account?",
                            style: t.displayMedium?.copyWith(
                              color: AppThemes.getHintColor(),
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Get.toNamed(RoutesName.signUpScreen);
                            },
                            child: Text(
                              storedLanguage['Create account'] ??
                                  "Create account",
                              style: t.bodyMedium?.copyWith(fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
