class AppConstants {
  static const String appName = 'Udharcard';

  //BASE_URL
  static const String baseUrl = 'https://pay.udharcard.shop' + '$prefix';

  //END_POINTS_URL
  static const String prefix = '/api';
  static const String registerUrl = '/register';
  static const String loginUrl = '/login';
  static const String forgotPassUrl = '/recovery-pass/get-email';
  static const String forgotPassGetCodeUrl = '/recovery-pass/get-code';
  static const String updatePassUrl = '/update-pass';
  static const String languageUrl = '/language';
  static const String profileUrl = '/profile';
  static const String profilePassUpdateUrl = '/change-password';
  static const String verificationUrl = '/kyc/list';
  static const String identityVerificationUrl = '/kyc/submit';
  static const String twoFaSecurityUrl = '/2FA-security';
  static const String twoFaSecurityEnableUrl = '/2FA-security/enable';
  static const String twoFaSecurityDisableUrl = '/2FA-security/disable';
  static const String twoFaVerifyUrl = '/twoFA-Verify';
  static const String mailUrl = '/mail-verify';
  static const String smsVerifyUrl = '/sms-verify';
  static const String resendCodeUrl = '/resend-code';
  static const String pusherConfigUrl = "/pusher/config";

  //----NOTIFICATION SETTINGS
  static const String notificationSettingsUrl = "/notification-settings";
  static const String notificationPermissionUrl = "/notification-permission";

  //----SUPPORT TICKET
  static const String supportTicketListUrl = '/support-ticket/list';
  static const String supportTicketCreateUrl = '/support-ticket/create';
  static const String supportTicketReplyUrl = '/support-ticket/reply';
  static const String supportTicketViewUrl = '/support-ticket/view';
  static const String supportTicketCloseUrl = '/close-ticket';

  static const String transactionUrl = '/transaction-history';
  static const String dashboardUrl = '/dashboard';

  //----VIRTUAL CARD
  static const String virtualCardsUrl = "/virtual-card/list";
  static const String cardBlockUrl = "/virtual-card/block";
  static const String cardOrderForm = "/virtual-card/order";
  static const String cardOrderFormSubmit = "/virtual-card/order/submit";
  static const String cardOrderFormReSubmit = "/virtual-card/re-submit/post";
  static const String cardTransaction = "/virtual-card/transaction";

  //----WITHDRAW
  static const String withdrawList = "/payout-list";
  static const String payoutUrl = "/payout";
  static const String payoutRequestUrl = "/payout-submit";
  static const String payoutConfirmSubmitUrl = "/payout/confirm/submit";
  static const String getBankFromBankUrl = "/payout/get-bank/from";
  static const String getBankFromCurrencyUrl = "/payout/get-bank/list";
  static const String flutterwaveSubmitUrl =
      "/payout/confirm/submit/flutterwave";
  static const String paystackSubmitUrl = "/payout/confirm/submit/paystack";
  static const String payoutConfirmPreviewUrl = "/payout/confirm/preview";

  //----ADD FUND
  static const String depositListUrl = "/fund/list";
  static const String gatewaysUrl = "/fund/gateway/currency";
  static const String manualPaymentUrl = "/manual-payment";
  static const String paymentRequest = "/fund-add";
  static const String onPaymentDone = "/payment-done";
  static const String webviewPayment = "/automation/payment";
  static const String cardPayment = "/card-payment";
  static const String getChargeAndLimit = "/get-charge-limit";

  //----REDEEM
  static const String getRedeemList = "/redeem/generate-code/list";
  static const String getGenerateCode = "/redeem/generate-code";
  static const String checkRedeemAmount = "/redeem/check-amount";
  static const String generateCodeSubmit = "/redeem/generate-code/submit";
  static const String generateCodePreview = "/redeem/generate-code/preview";
  static const String generateCodeConfirm =
      "/redeem/generate-code/preview/confirm";
  static const String insertRedeemCode = "/redeem/insert";

  //----ESCROW
  static const String getEscrowList = "/escrow/list";
  static const String getEscrow = "/escrow";
  static const String escrowSubmit = "/escrow/submit";
  static const String escrowPreview = "/escrow/preview";
  static const String escrowConfirm = "/escrow/preview/confirm";
  static const String escrowPaymentSubmit = "/escrow/payment/submit";

  //----VOUCHER
  static const String getVoucherList = "/voucher/list";
  static const String getVoucher = "/voucher";
  static const String voucherSubmit = "/voucher/submit";
  static const String voucherPreview = "/voucher/preview";
  static const String voucherPreviewSubmit = "/voucher/preview/submit";
  static const String voucherPaymentSubmit = "/voucher/payment/submit";

  //----INVOICE
  static const String invoiceCreate = "/invoice/create";
  static const String invoiceStore = "/invoice/store";
  static const String invoiceReminder = "/invoice/reminder";
  static const String invoiceList = "/invoice/list";
  static const String invoiceView = "/invoice/view";

  //----PAY BILL
  static const String payBillList = "/pay-bill/list";
  static const String payBill = "/pay-bill";
  static const String payBillPreview = "/pay-bill/preview";
  static const String payBillPreviewSubmit = "/pay-bill/preview/submit";
  static const String submitPayBill = "/pay-bill/submit";

  //----SEND MONEY
  static const String sendMoneyList = "/send/money/list";
  static const String sendMoney = "/send/money";
  static const String sendMoneyPreview = "/send/money/preview";
  static const String sendMoneyConfirm = "/send/money/confirm";
  static const String submitSendMoney = "/send/money/submit";

  //----MAKE PAYMENT
  static const String initMakePayment = "/make-payment/init";
  static const String makePaymentPreview = "/make-payment/preview";
  static const String makePaymentCheckAmount = "/make-payment/check-amount";
  static const String checkMerchant = "/make-payment/check-merchant";
  static const String makePaymentConfirm = "/make-payment/confirm";

  //----CASH OUT
  static const String initCashout = "/user/cash-out/init";
  static const String cashoutPreview = "/user/cash-out/preview";
  static const String cashoutCheckAmount = "/user/cash-out/check-amount";
  static const String checkAgent = "/user/cash-out/check-agent";
  static const String cashoutConfirm = "/user/cash-out/confirm";

  //----REQUEST MONEY
  static const String requestMoneyList = "/request/money/list";
  static const String requestMoney = "/request/money";
  static const String requestCancel = "/request/money/cancel";
  static const String requestMoneyPreview = "/request/money/preview";
  static const String requestMoneyConfirm = "/request/money/confirm";
  static const String requestMoneySubmit = "/request/money/submit";
  static const String requestMoneyCheckSubmit = "/request/money/check/submit";

  //----EXCHANGE MONEY
  static const String exchangeMoneyList = "/exchange/money/list";
  static const String exchangeMoney = "/exchange/money";
  static const String exchangeMoneyPreview = "/exchange/money/preview";
  static const String exchangeMoneyConfirm = "/exchange/money/preview/confirm";
  static const String submitExchangeMoney = "/exchange/money/submit";

  //----DISPUTE
  static const String disputeList = "/dispute/list";

  //----QR PAYMENT
  static const String qrPaymentList = "/get/qr-payment";

  //----pin reset
  static const String pinReset = "/security-pin/reset";

  //----SECURITY PIN MANAGE
  static const String pinManage = "/security-pin/manage";

  static const String checkRecipient = "/transfer/check-recipient";

  static const String baisicCtrl = "/basic";
  static const String deleteAccount = "/delete-account";
}

//----------IMAGE DIRECTORY---------//
String rootImageDir = "assets/images";
String rootIconDir = "assets/icons";
String rootJsonDir = "assets/json";
