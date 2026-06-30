import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paysecure/config/dimensions.dart';
import 'package:paysecure/controllers/card_controller.dart';
import 'package:paysecure/views/widgets/app_button.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../config/app_colors.dart';
import '../../../themes/themes.dart';
import '../../../utils/services/helpers.dart';
import '../../../utils/services/localstorage/hive.dart';
import '../../../utils/services/localstorage/keys.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/spacing.dart';

class VirtualCardFormScreen extends StatelessWidget {
  final bool? isFromResubmit;
  const VirtualCardFormScreen({super.key, this.isFromResubmit = false});

  @override
  Widget build(BuildContext context) {
    var storedLanguage = HiveHelp.read(Keys.languageData) ?? {};
    return GetBuilder<CardController>(builder: (cardController) {
      return Scaffold(
        appBar: CustomAppBar(
          title: isFromResubmit == true ?storedLanguage['Card Re-Order']?? "Card Re-Order" : cardController.title,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (isFromResubmit == false) {
              await cardController.getCardOrder(isFromRefreshIndicator: true);
              await cardController.filterData();
            } else {
              cardController.dynamicFormList.clear();
              cardController.filterData(isFromResubmit: isFromResubmit);
              await cardController.getVirtualCards();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: cardController.isCardOrderLoad
                ? SizedBox(
                    height: Dimensions.screenHeight,
                    width: Dimensions.screenWidth,
                    child: Helpers.appLoader(),
                  )
                : Column(
                    children: [
                      if (isFromResubmit == true) VSpace(35.h),
                      if (isFromResubmit == false)
                        Padding(
                          padding: EdgeInsets.only(top: 35.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 4.w),
                            decoration: BoxDecoration(
                                color: AppColors.pendingColor
                                    .withValues(alpha: .1),
                                border: Border.all(
                                    color: AppColors.pendingColor, width: .4),
                                borderRadius: BorderRadius.circular(6.r)),
                            child: Wrap(
                              children: [
                                HSpace(10.w),
                                Icon(
                                  Icons.info,
                                  size: 22.h,
                                ),
                                HSpace(10.w),
                                Text(
                                  "${cardController.description}",
                                  style: context.t.bodySmall?.copyWith(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      VSpace(20.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: Dimensions.kDefaultPadding,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                  storedLanguage['Card Currency'] ??
                                      "Card Currency",
                                  style: context.t.displayMedium),
                              HSpace(10.w),
                              ...List.generate(
                                  cardController.cardOrderCurrencyList.length,
                                  (index) => Padding(
                                        padding: EdgeInsets.only(right: 10.w),
                                        child: InkWell(
                                          borderRadius:
                                              Dimensions.kBorderRadius,
                                          onTap: () {
                                            cardController.selectedCurr =
                                                cardController.cardOrderCurrencyList[index];
                                            cardController.update();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 7.h,
                                                horizontal: 10.w),
                                            decoration: BoxDecoration(
                                              color: cardController.selectedCurr ==
                                                      cardController.cardOrderCurrencyList[
                                                          index]
                                                  ? AppColors.mainColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  Dimensions.kBorderRadius,
                                              border: Border.all(
                                                  color: AppColors.mainColor),
                                            ),
                                            child: Text(
                                              cardController.cardOrderCurrencyList[index],
                                              style: context.t.displayMedium
                                                  ?.copyWith(
                                                color: cardController.selectedCurr ==
                                                        cardController.cardOrderCurrencyList[
                                                            index]
                                                    ? AppColors.whiteColor
                                                    : Get.isDarkMode
                                                        ? AppColors.whiteColor
                                                        : AppColors.blackColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 20.h),
                        child: Form(
                          key: cardController.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (cardController.dynamicFormList.isNotEmpty) ...[
                                VSpace(30.h),
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: cardController.dynamicFormList.length,
                                  itemBuilder: (context, index) {
                                    final dynamicField =
                                        cardController.dynamicFormList[index];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (dynamicField.type == "file")
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dynamicField.fieldLevel,
                                                    style: context.t.bodyLarge,
                                                  ),
                                                  dynamicField.validation ==
                                                          'required'
                                                      ? const SizedBox()
                                                      : Text(
                                                          " ${storedLanguage['(Optional)'] ?? "(Optional)"}",
                                                          style: context
                                                              .t.displayMedium,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              Container(
                                                height: 45.5,
                                                width: double.maxFinite,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 10.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppThemes.getFillColor(),
                                                  borderRadius:
                                                      Dimensions.kBorderRadius,
                                                  border: Border.all(
                                                      color:
                                                          cardController.fileColorOfDField,
                                                      width:
                                                          cardController.fileColorOfDField ==
                                                                  AppColors
                                                                      .redColor
                                                              ? 1
                                                              : .2),
                                                ),
                                                child: Row(
                                                  children: [
                                                    HSpace(12.w),
                                                    Text(
                                                      cardController.imagePickerResults[
                                                                  dynamicField
                                                                      .fieldName] !=
                                                              null
                                                          ? storedLanguage[
                                                                  '1 File selected'] ??
                                                              "1 File selected"
                                                          : storedLanguage[
                                                                  'No File selected'] ??
                                                              "No File selected",
                                                      style: context.t.bodySmall?.copyWith(
                                                          color: cardController.imagePickerResults[
                                                                      dynamicField
                                                                          .fieldName] !=
                                                                  null
                                                              ? AppColors
                                                                  .greenColor
                                                              : AppColors
                                                                  .black60),
                                                    ),
                                                    const Spacer(),
                                                    Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          Helpers
                                                              .hideKeyboard();

                                                          await cardController.pickFile(
                                                              dynamicField
                                                                  .fieldName);
                                                        },
                                                        borderRadius: Dimensions
                                                            .kBorderRadius,
                                                        child: Ink(
                                                          width: 113.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .mainColor,
                                                            borderRadius:
                                                                Dimensions
                                                                    .kBorderRadius,
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .mainColor,
                                                                width: .2),
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                                  storedLanguage[
                                                                          'Choose File'] ??
                                                                      'Choose File',
                                                                  style: context
                                                                      .t
                                                                      .bodySmall
                                                                      ?.copyWith(
                                                                          color:
                                                                              AppColors.whiteColor))),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16.h,
                                              ),
                                            ],
                                          ),
                                        if (dynamicField.type == "text" ||
                                            dynamicField.type == "email" ||
                                            dynamicField.type == "number")
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dynamicField.fieldLevel,
                                                    style:
                                                        context.t.displayMedium,
                                                  ),
                                                  dynamicField.validation ==
                                                          'required'
                                                      ? const SizedBox()
                                                      : Text(
                                                          " ${storedLanguage['(Optional)'] ?? "(Optional)"}",
                                                          style: context
                                                              .t.displayMedium,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  // Perform validation based on the 'validation' property
                                                  if (dynamicField.validation ==
                                                          "required" &&
                                                      value!.isEmpty) {
                                                    return storedLanguage[
                                                            'Field is required'] ??
                                                        "Field is required";
                                                  }
                                                  return null;
                                                },
                                                onChanged: (v) {
                                                  cardController
                                                      .textEditingControllerMap[
                                                          dynamicField
                                                              .fieldName]!
                                                      .text = v;
                                                },
                                                controller:
                                                    cardController.textEditingControllerMap[
                                                        dynamicField.fieldName],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      dynamicField.placeholder,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0,
                                                          horizontal: 16),
                                                  filled:
                                                      true, // Fill the background with color
                                                  hintStyle: TextStyle(
                                                    color: AppColors
                                                        .textFieldHintColor,
                                                  ),
                                                  fillColor: Colors
                                                      .transparent, // Background color
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppThemes
                                                          .getSliderInactiveColor(),
                                                      width: 1,
                                                    ),
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                  ),

                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .mainColor),
                                                  ),
                                                ),
                                                style: context.t.bodyMedium,
                                              ),
                                              SizedBox(
                                                height: 16.h,
                                              ),
                                            ],
                                          ),
                                        if (dynamicField.type == "number")
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dynamicField.fieldLevel,
                                                    style:
                                                        context.t.displayMedium,
                                                  ),
                                                  dynamicField.validation ==
                                                          'required'
                                                      ? const SizedBox()
                                                      : Text(
                                                          " ${storedLanguage['(Optional)'] ?? "(Optional)"}",
                                                          style: context
                                                              .t.displayMedium,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  // Perform validation based on the 'validation' property
                                                  if (dynamicField.validation ==
                                                          "required" &&
                                                      value!.isEmpty) {
                                                    return storedLanguage[
                                                            'Field is required'] ??
                                                        "Field is required";
                                                  }
                                                  return null;
                                                },
                                                onChanged: (v) {
                                                  cardController
                                                      .textEditingControllerMap[
                                                          dynamicField
                                                              .fieldName]!
                                                      .text = v;
                                                },
                                                controller:
                                                    cardController.textEditingControllerMap[
                                                        dynamicField.fieldName],
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      dynamicField.placeholder,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0,
                                                          horizontal: 16),
                                                  filled:
                                                      true, // Fill the background with color
                                                  hintStyle: TextStyle(
                                                    color: AppColors
                                                        .textFieldHintColor,
                                                  ),
                                                  fillColor: Colors
                                                      .transparent, // Background color
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppThemes
                                                          .getSliderInactiveColor(),
                                                      width: 1,
                                                    ),
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                  ),

                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .mainColor),
                                                  ),
                                                ),
                                                style: context.t.bodyMedium,
                                              ),
                                              SizedBox(
                                                height: 16.h,
                                              ),
                                            ],
                                          ),
                                        if (dynamicField.type == "date")
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dynamicField.fieldLevel,
                                                    style:
                                                        context.t.displayMedium,
                                                  ),
                                                  dynamicField.validation ==
                                                          'required'
                                                      ? const SizedBox()
                                                      : Text(
                                                          " ${storedLanguage['(Optional)'] ?? "(Optional)"}",
                                                          style: context
                                                              .t.displayMedium,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  /// SHOW DATE PICKER
                                                  await showDatePicker(
                                                    context: context,
                                                    builder: (context, child) {
                                                      return Theme(
                                                          data:
                                                              Theme.of(context)
                                                                  .copyWith(
                                                            colorScheme:
                                                                ColorScheme
                                                                    .dark(
                                                              surface: Get
                                                                      .isDarkMode
                                                                  ? AppColors
                                                                      .darkCardColor
                                                                  : AppColors
                                                                      .paragraphColor,
                                                              onPrimary: AppColors
                                                                  .whiteColor,
                                                            ),
                                                            textButtonTheme:
                                                                TextButtonThemeData(
                                                              style: TextButton
                                                                  .styleFrom(
                                                                foregroundColor:
                                                                    AppColors
                                                                        .mainColor, // button text color
                                                              ),
                                                            ),
                                                          ),
                                                          child: child!);
                                                    },
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(
                                                        DateTime.now()
                                                                .year
                                                                .toInt() +
                                                            1),
                                                  ).then((value) {
                                                    if (value != null) {
                                                      cardController
                                                          .textEditingControllerMap[
                                                              dynamicField
                                                                  .fieldName]!
                                                          .text = DateFormat(
                                                              'yyyy-MM-dd')
                                                          .format(value);
                                                    }
                                                  });
                                                },
                                                child: IgnorePointer(
                                                  ignoring: true,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      // Perform validation based on the 'validation' property
                                                      if (dynamicField
                                                                  .validation ==
                                                              "required" &&
                                                          value!.isEmpty) {
                                                        return storedLanguage[
                                                                'Field is required'] ??
                                                            "Field is required";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        cardController.textEditingControllerMap[
                                                            dynamicField
                                                                .fieldName],
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              vertical: 0,
                                                              horizontal: 16),
                                                      filled:
                                                          true, // Fill the background with color
                                                      hintStyle: TextStyle(
                                                        color: AppColors
                                                            .textFieldHintColor,
                                                      ),
                                                      fillColor: Colors
                                                          .transparent, // Background color
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: AppThemes
                                                              .getSliderInactiveColor(),
                                                          width: 1,
                                                        ),
                                                        borderRadius: Dimensions
                                                            .kBorderRadius,
                                                      ),
                                                      hintText: dynamicField
                                                          .placeholder,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius: Dimensions
                                                            .kBorderRadius,
                                                        borderSide: BorderSide(
                                                            color: AppColors
                                                                .mainColor),
                                                      ),
                                                    ),
                                                    style: context.t.bodyMedium,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 16.h,
                                              ),
                                            ],
                                          ),
                                        if (dynamicField.type == 'textarea')
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dynamicField.fieldLevel,
                                                    style:
                                                        context.t.displayMedium,
                                                  ),
                                                  dynamicField.validation ==
                                                          'required'
                                                      ? const SizedBox()
                                                      : Text(
                                                          " ${storedLanguage['(Optional)'] ?? "(Optional)"}",
                                                          style: context
                                                              .t.displayMedium,
                                                        ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 8.h,
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (dynamicField.validation ==
                                                          "required" &&
                                                      value!.isEmpty) {
                                                    return storedLanguage[
                                                            'Field is required'] ??
                                                        "Field is required";
                                                  }
                                                  return null;
                                                },
                                                controller:
                                                    cardController.textEditingControllerMap[
                                                        dynamicField.fieldName],
                                                maxLines: 7,
                                                minLines: 5,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      dynamicField.placeholder,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 16),
                                                  filled: true,
                                                  hintStyle: TextStyle(
                                                    color: AppColors
                                                        .textFieldHintColor,
                                                  ),
                                                  fillColor: Colors
                                                      .transparent, // Background color
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppThemes
                                                          .getSliderInactiveColor(),
                                                      width: 1,
                                                    ),
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius: Dimensions
                                                        .kBorderRadius,
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .mainColor),
                                                  ),
                                                ),
                                                style: context.t.bodyMedium,
                                              ),
                                              SizedBox(
                                                height: 16.h,
                                              ),
                                            ],
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                              if (cardController.enable_for == true)
                                Text(
                                  "Security Pin",
                                  style: context.t.displayMedium,
                                ),
                              if (cardController.enable_for == true)
                                SizedBox(
                                  height: 8.h,
                                ),
                              if (cardController.enable_for == true)
                                CustomTextField(
                                  isBorderColor: true,
                                  isSuffixIcon: false,
                                  contentPadding: EdgeInsets.only(left: 20.w),
                                  hintext: storedLanguage['Security Pin'] ??
                                      'Security Pin',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  controller: cardController.securityPinController,
                                  onChanged: (v) {},
                                ),
                              SizedBox(
                                height: 30.h,
                              ),
                              AppButton(
                                  isLoading: cardController.isFormSubmtting ? true : false,
                                  text: storedLanguage['Apply'] ?? 'Apply',
                                  onTap: cardController.isFormSubmtting ||
                                          cardController.dynamicFormList.isEmpty
                                      ? null
                                      : () async {
                                          Helpers.hideKeyboard();
                                          if (cardController.selectedCurr.isEmpty) {
                                            Helpers.showSnackBar(
                                                msg:
                                                    "Please select card currency.");
                                          } else if (cardController.formKey.currentState!
                                                  .validate() &&
                                              cardController.requiredFile.isEmpty) {
                                            cardController.fileColorOfDField =
                                                AppColors.mainColor;
                                            cardController.update();
                                            await cardController.renderDynamicFieldData();

                                            Map<String, String> stringMap = {};
                                            cardController.dynamicData.forEach((key, value) {
                                              if (value is String) {
                                                stringMap[key] = value;
                                              }
                                            });

                                            await Future.delayed(
                                                Duration(milliseconds: 300));

                                            Map<String, String> body = {
                                              if (cardController.enable_for == true)
                                                "security_pin":
                                                    "${cardController.securityPinController.text}",
                                              "currency": cardController.selectedCurr
                                            };
                                            body.addAll(stringMap);

                                            if (isFromResubmit == true) {
                                              await cardController.cardOrderReSubmit(
                                                context: context,
                                                fields: body,
                                                fileList: cardController.fileMap.entries
                                                    .map((e) => e.value)
                                                    .toList(),
                                              );
                                            } else {
                                              await cardController.cardOrderSubmit(
                                                context: context,
                                                fields: body,
                                                fileList: cardController.fileMap.entries
                                                    .map((e) => e.value)
                                                    .toList(),
                                              );
                                            }
                                          } else {
                                            cardController.fileColorOfDField =
                                                AppColors.redColor;
                                            cardController.update();
                                            print(
                                                "required type file list===========================: $cardController.requiredTypeFileList");
                                            Helpers.showSnackBar(
                                                msg:
                                                    "Please fill in all required fields.");
                                          }
                                        }),
                              SizedBox(
                                height: 10.h,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
