import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/redeem_code_controller.dart';
import 'package:paysecure/utils/services/helpers.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/custom_appbar.dart';
import '../../../config/app_colors.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class InsertRedeemCodeScreen extends StatelessWidget {
  const InsertRedeemCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<RedeemCodeController>(builder: (redeemCodeController) {
      return Scaffold(
        backgroundColor:
            Get.isDarkMode ? AppColors.darkBgColor : AppColors.scaffoldColor,
        appBar: CustomAppBar(
            title:
                storedLanguage['Insert Redeem Code'] ?? "Insert Redeem Code"),
        body: SingleChildScrollView(
          child: Padding(
            padding: Dimensions.kDefaultPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VSpace(40.h),
                CustomTextField(
                  isBorderColor: true,
                  isSuffixIcon: false,
                  contentPadding: EdgeInsets.only(left: 20.w),
                  hintext: storedLanguage['Redeem Code'] ?? 'Redeem Code',
                  controller: redeemCodeController.insertRedeemCodeController,
                  onChanged: (v) {},
                ),
                VSpace(40.h),
                AppButton(
                  isLoading: redeemCodeController.isSubmit ? true : false,
                  onTap: redeemCodeController.isSubmit
                      ? null
                      : () async {
                          if (redeemCodeController.insertRedeemCodeController.text.isEmpty) {
                            Helpers.showSnackBar(
                                msg: "Redeem Code field is requred");
                          } else {
                            await redeemCodeController.insertRedeemCode(fields: {
                              "redeemCode": redeemCodeController.insertRedeemCodeController.text
                            });
                          }
                        },
                  text: storedLanguage['Submit Redeem Code'] ??
                      "Submit Redeem Code",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
