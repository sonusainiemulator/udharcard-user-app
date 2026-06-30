import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/app_colors.dart';
import '../../../config/dimensions.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/routes_name.dart';
import '../../../themes/themes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme t = Theme.of(context).textTheme;
    AuthController controller = Get.find<AuthController>();
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
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
                      children: [
                        VSpace(100.h),
                        Text(
                          storedLanguage['Create Account'] ?? "Create Account",
                          style: t.titleMedium?.copyWith(fontSize: 26.sp),
                        ),
                        VSpace(12.h),
                        Text(
                          storedLanguage['Hello there, Sign Up to continue!'] ??
                              "Hello there, Sign Up to continue!",
                          style: t.displayMedium?.copyWith(
                            color: AppThemes.getParagraphColor(),
                          ),
                        ),
                        VSpace(40.h),
                        CustomTextField(
                          hintext: storedLanguage['First Name'] ?? "First Name",
                          isPrefixIcon: true,
                          prefixIcon: 'edit',
                          controller: controller.signupFNameEditingController,
                          onChanged: (v) {
                            controller.signupFNameVal = v;
                            controller.update();
                          },
                        ),
                        VSpace(36.h),
                        CustomTextField(
                          hintext: storedLanguage['Last Name'] ?? "Last Name",
                          isPrefixIcon: true,
                          prefixIcon: 'edit',
                          controller: controller.signupLNameEditingController,
                          onChanged: (v) {
                            controller.signupLNameVal = v;
                            controller.update();
                          },
                        ),
                        VSpace(36.h),
                        CustomTextField(
                          hintext: storedLanguage['Username'] ?? "Username",
                          isPrefixIcon: true,
                          prefixIcon: 'person',
                          controller:
                              controller.signUpUserNameEditingController,
                          onChanged: (v) {
                            controller.signUpUserNameVal = v;
                            controller.update();
                          },
                        ),
                        VSpace(36.h),
                        CustomTextField(
                          hintext:
                              storedLanguage['Email Address'] ??
                              "Email Address",
                          isPrefixIcon: true,
                          prefixIcon: 'email',
                          controller: controller.emailEditingController,
                          onChanged: (v) {
                            controller.emailVal = v;
                            if (!v.contains('@')) {
                              controller.emailVal = "";
                            }
                            controller.update();
                          },
                        ),
                        VSpace(36.h),
                        Row(
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
                                enabled: false,
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
                                },
                                initialSelection: 'IN',
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
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller:
                                    controller.phoneNumberEditingController,
                                onChanged: (v) {
                                  controller.phoneNumberVal = v;
                                  controller.update();
                                },
                              ),
                            ),
                          ],
                        ),
                        VSpace(36.h),
                        CustomTextField(
                          hintext: storedLanguage['Password'] ?? "Password",
                          isPrefixIcon: true,
                          isSuffixIcon: true,
                          obsCureText: controller.isNewPassShow ? true : false,
                          prefixIcon: 'lock',
                          suffixIcon:
                              controller.isNewPassShow ? 'hide' : 'show',
                          controller: controller.signUpPassEditingController,
                          onChanged: (v) {
                            controller.signUpPassVal = v;
                            controller.update();
                          },
                          onSuffixPressed: () {
                            controller.isNewPassShow =
                                !controller.isNewPassShow;
                            controller.update();
                          },
                        ),
                        VSpace(36.h),
                        CustomTextField(
                          hintext:
                              storedLanguage['Confirm Password'] ??
                              "Confirm Password",
                          isPrefixIcon: true,
                          isSuffixIcon: true,
                          obsCureText:
                              controller.isConfirmPassShow ? true : false,
                          prefixIcon: 'lock',
                          suffixIcon:
                              controller.isConfirmPassShow ? 'hide' : 'show',
                          controller: controller.confirmPassEditingController,
                          onChanged: (v) {
                            controller.signUpConfirmPassVal = v;
                            controller.update();
                          },
                          onSuffixPressed: () {
                            controller.isConfirmPassShow =
                                !controller.isConfirmPassShow;
                            controller.update();
                          },
                        ),
                        VSpace(48.h),
                        Material(
                          color: Colors.transparent,
                          child: AppButton(
                            text: storedLanguage['Sign Up'] ?? "Sign Up",
                            isLoading: controller.isLoading ? true : false,
                            bgColor:
                                controller.signupFNameVal.isEmpty ||
                                        controller.emailVal.isEmpty ||
                                        controller.signUpUserNameVal.isEmpty ||
                                        controller.phoneNumberVal.isEmpty ||
                                        controller.signUpPassVal.isEmpty ||
                                        controller.signUpConfirmPassVal.isEmpty
                                    ? AppThemes.getInactiveColor()
                                    : Get.isDarkMode
                                    ? AppColors.mainColor
                                    : AppColors.blackColor,
                            onTap:
                                controller.signupFNameVal.isEmpty ||
                                        controller.emailVal.isEmpty ||
                                        controller.signUpUserNameVal.isEmpty ||
                                        controller.phoneNumberVal.isEmpty ||
                                        controller.signUpPassVal.isEmpty ||
                                        controller.signUpConfirmPassVal.isEmpty
                                    ? null
                                    : controller.isLoading
                                    ? null
                                    : () async {
                                      if (controller
                                              .signUpPassEditingController
                                              .text !=
                                          controller
                                              .confirmPassEditingController
                                              .text) {
                                        Helpers.showSnackBar(
                                          msg:
                                              "Your Password and Confirm Password didn't match!",
                                        );
                                      } else {
                                        Helpers.hideKeyboard();
                                        await controller.register();
                                      }
                                    },
                          ),
                        ),
                        VSpace(10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              storedLanguage['Already have an account?'] ??
                                  "Already have an account?",
                              style: t.displayMedium?.copyWith(
                                fontSize: 18.sp,
                                color: AppThemes.getHintColor(),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(RoutesName.loginScreen);
                              },
                              child: Text(
                                storedLanguage['Login'] ?? "Login",
                                style: t.displayMedium?.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        VSpace(60.h),
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
