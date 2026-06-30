// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paysecure/views/widgets/text_theme_extension.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/dimensions.dart';
import '../../../../controllers/deposit_controller.dart';
import '../../../../themes/themes.dart';
import '../../../../utils/services/helpers.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/custom_appbar.dart';
import 'components/app_card_month_formatter.dart';
import 'components/app_card_utils.dart';
import 'components/card_number_input_formatter.dart';

class CardPaymentScreen extends StatefulWidget {
  dynamic gatewayCode;
  CardPaymentScreen({super.key, this.gatewayCode});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardNameController = TextEditingController();
  TextEditingController cardCVVController = TextEditingController();
  TextEditingController cardMMYYController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CardType cardType = CardType.Invalid;

  void getCardTypeFrmNumber() {
    if (cardNumberController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(input);
      if (type != cardType) {
        setState(() {
          cardType = type;
        });
      }
    }
  }

  @override
  void initState() {
    cardNumberController.addListener(() {
      getCardTypeFrmNumber();
    });
    super.initState();
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DepositController>(
      builder: (addfundCtrl) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar(
            title:
                widget.gatewayCode == "securionpay"
                    ? "Pay with SecurionPay"
                    : "Pay with AuthorizeNet",
          ),
          body: Padding(
            padding: Dimensions.kDefaultPadding,
            child: Column(
              children: [
                widget.gatewayCode == "securionpay"
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/images/securionPay.webp"),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset("assets/images/authorizenet.webp"),
                    ),
                SizedBox(height: 30.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cardNumberController,
                          keyboardType: TextInputType.number,
                          validator: CardUtils.validateCardNum,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(19),
                            CardNumberInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                              left: 12,
                              top: 10,
                              bottom: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ), // Set the border radius here
                              borderSide:
                                  BorderSide.none, // Remove the default border
                            ),
                            fillColor: AppThemes.getFillColor(),
                            filled: true,
                            hintStyle: context.t.displayMedium?.copyWith(
                              color: AppThemes.getHintColor(),
                            ),
                            hintText: "Card number",
                            suffix: Padding(
                              padding: EdgeInsets.only(right: 7.w),
                              child: CardUtils.getCardIcon(cardType),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'This field is required';
                              }
                              return null; // Return null if the input is valid
                            },
                            controller: cardNameController,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                Icons.person,
                                size: 20.h,
                                color:
                                    Get.isDarkMode
                                        ? AppColors.whiteColor
                                        : AppColors.black50,
                              ),
                              contentPadding: EdgeInsets.only(
                                left: 12,
                                top: 10,
                                bottom: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8.0,
                                ), // Set the border radius here
                                borderSide:
                                    BorderSide
                                        .none, // Remove the default border
                              ),
                              fillColor: AppThemes.getFillColor(),
                              filled: true,
                              hintStyle: context.t.displayMedium?.copyWith(
                                color: AppThemes.getHintColor(),
                              ),
                              hintText: "Full name",
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Return null if the input is valid
                                },
                                controller: cardCVVController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  // Limit the input
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.lock,
                                    size: 20.h,
                                    color:
                                        Get.isDarkMode
                                            ? AppColors.whiteColor
                                            : AppColors.black50,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    left: 12,
                                    top: 10,
                                    bottom: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8.0,
                                    ), // Set the border radius here
                                    borderSide:
                                        BorderSide
                                            .none, // Remove the default border
                                  ),
                                  fillColor: AppThemes.getFillColor(),
                                  filled: true,
                                  hintStyle: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getHintColor(),
                                  ),
                                  hintText: "CVV",
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null; // Return null if the input is valid
                                },
                                controller: cardMMYYController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  CardMonthInputFormatter(),
                                ],
                                decoration: InputDecoration(
                                  suffixIcon: Icon(
                                    Icons.date_range,
                                    size: 20.h,
                                    color:
                                        Get.isDarkMode
                                            ? AppColors.whiteColor
                                            : AppColors.black50,
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                    left: 12,
                                    top: 10,
                                    bottom: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      8.0,
                                    ), // Set the border radius here
                                    borderSide:
                                        BorderSide
                                            .none, // Remove the default border
                                  ),
                                  fillColor: AppThemes.getFillColor(),
                                  filled: true,
                                  hintStyle: context.t.displayMedium?.copyWith(
                                    color: AppThemes.getHintColor(),
                                  ),
                                  hintText: "MM/YY",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppButton(
                    isLoading: addfundCtrl.isLoading ? true : false,
                    onTap:
                        addfundCtrl.isLoading
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                Helpers.hideKeyboard();

                                await addfundCtrl.cardPayment(
                                  fields: {
                                    "trx_id": "${addfundCtrl.trxId}",
                                    "card_number":
                                        cardNumberController.text.toString(),
                                    "card_name":
                                        cardNameController.text.toString(),
                                    "expiry_month": month,
                                    "expiry_year": year,
                                    "card_cvc":
                                        cardCVVController.text.toString(),
                                  },
                                );
                              }
                            },
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
