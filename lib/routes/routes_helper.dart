import '../views/screens/cashout/cash_out_preview_screen.dart';
import '../views/screens/cashout/cash_out_screen.dart';
import '../views/screens/makePayment/makePayment_preview_screen.dart';
import '../views/screens/makePayment/makePayment_screen.dart';
import '../views/screens/pin_setup/security_pin_setup_screen.dart';
import 'routes_name.dart';
import '../views/screens/request_money/request_money_history_screen.dart';
import '../views/screens/send_money/send_money_history_screen.dart';
import '../views/screens/exchange/exchange_money_history_screen.dart';
import '../views/screens/pay_bill/pay_bill_history_screen.dart';
import '../views/screens/redeem/redeem_history_screen.dart';
import '../views/screens/invoice/invoice_history_screen.dart';
import 'package:paysecure/routes/page_index.dart';

class RouteHelper {
  static List<GetPage> routes() => [
        GetPage(name: RoutesName.INITIAL, page: () => SplashScreen()),
        GetPage(
            name: RoutesName.onbordingScreen, page: () => OnbordingScreen()),
        GetPage(name: RoutesName.bottomNavBar, page: () => BottomNavBar()),
        GetPage(name: RoutesName.loginScreen, page: () => LoginScreen()),
        GetPage(name: RoutesName.signUpScreen, page: () => SignUpScreen()),
        GetPage(
            name: RoutesName.forgotPassScreen, page: () => ForgotPassScreen()),
        GetPage(name: RoutesName.otpScreen, page: () => OtpScreen()),
        GetPage(
            name: RoutesName.createNewPassScreen,
            page: () => CreateNewPassScreen()),
        GetPage(name: RoutesName.homeScreen, page: () => HomeScreen()),
        GetPage(
            name: RoutesName.sendMoneyHistoryScreen,
            page: () => SendMoneyHistoryScreen()),
        GetPage(
            name: RoutesName.sendMoneyScreen, page: () => SendMoneyScreen()),
        GetPage(
            name: RoutesName.sendMoneyPreviewScreen,
            page: () => SendMoneyPreviewScreen()),
        GetPage(
            name: RoutesName.requestMoneyScreen,
            page: () => RequestMoneyScreen()),
        GetPage(
            name: RoutesName.requestMoneyPreviewScreen,
            page: () => RequestMoneyPreviewScreen()),
        GetPage(
            name: RoutesName.requestMoneyPreviewConfirmScreen,
            page: () => RequestMoneyPreviewConfirmScreen()),
        GetPage(
            name: RoutesName.requestMoneyHistoryScreen,
            page: () => RequestMoneyHistoryScreen()),
        GetPage(
            name: RoutesName.exchangeMoneyHistoryScreen,
            page: () => ExchangeMoneyHistoryScreen()),
        GetPage(name: RoutesName.exchangeScreen, page: () => ExchangeScreen()),
        GetPage(
            name: RoutesName.exchangeMoneyPreviewScreen,
            page: () => ExchangeMoneyPreviewScreen()),
        GetPage(name: RoutesName.redeemScreen, page: () => RedeemScreen()),
        GetPage(
            name: RoutesName.redeemHistoryScreen,
            page: () => RedeemHistoryScreen()),
        GetPage(
            name: RoutesName.redeemPreviewScreen,
            page: () => RedeemPreviewScreen()),
        GetPage(
            name: RoutesName.insertRedeemCodeScreen,
            page: () => InsertRedeemCodeScreen()),
        GetPage(name: RoutesName.escrowScreen, page: () => EscrowScreen()),
        GetPage(
            name: RoutesName.escrowPreviewScreen,
            page: () => EscrowPreviewScreen()),
        GetPage(
          name: RoutesName.escrowHistoryScreen,
          page: () => EscrowHistoryScreen(),
        ),
        GetPage(
            name: RoutesName.disputeHistoryScreen,
            page: () => DisputeHistoryScreen()),
        GetPage(
            name: RoutesName.qrPaymentScreen, page: () => QrPaymentScreen()),
        GetPage(name: RoutesName.voucherScreen, page: () => VoucherScreen()),
        GetPage(
            name: RoutesName.voucherHistoryScreen,
            page: () => VoucherHistoryScreen()),
        GetPage(
            name: RoutesName.voucherPreviewScreen,
            page: () => VoucherPreviewScreen()),
        GetPage(name: RoutesName.billCategoryScreen, page: () => BillCategoryScreen()),
        GetPage(name: RoutesName.payBillScreen, page: () => PayBillScreen()),
        GetPage(
            name: RoutesName.payBillPreviewScreen,
            page: () => PayBillPreviewScreen()),
        GetPage(
            name: RoutesName.payBillHistoryScreen,
            page: () => PayBillHistoryScreen()),
        GetPage(name: RoutesName.invoiceScreen, page: () => InvoiceScreen()),
        GetPage(
          name: RoutesName.invoiceDownloadPreviewScreen,
          page: () => InvoiceDownloadPreviewScreen(),
        ),
        GetPage(
            name: RoutesName.invoiceHistoryScreen,
            page: () => InvoiceHistoryScreen()),
        GetPage(
            name: RoutesName.invoiceViewScreen,
            page: () => InvoiceViewScreen()),
        GetPage(
          name: RoutesName.transactionScreen,
          page: () => TransactionScreen(),
        ),
        GetPage(name: RoutesName.cardScreen, page: () => VirtualCardScreen()),
        GetPage(
            name: RoutesName.virtualCardFormScreen,
            page: () => VirtualCardFormScreen()),
        GetPage(
            name: RoutesName.cardTransactionScreen,
            page: () => CardTransactionScreen()),
        GetPage(name: RoutesName.depositScreen, page: () => DepositScreen()),
        GetPage(
            name: RoutesName.depositHistoryScreen,
            page: () => DepositHistoryScreen()),
        GetPage(
            name: RoutesName.depositPreviewScreen,
            page: () => DepositPreviewScreen()),
        GetPage(name: RoutesName.withdrawScreen, page: () => WithdrawScreen()),
        GetPage(
            name: RoutesName.withdrawPreviewScreen,
            page: () => WithdrawPreviewScreen()),
        GetPage(
            name: RoutesName.withdrawHistoryScreen,
            page: () => WithdrawHistoryScreen()),
        GetPage(
            name: RoutesName.flutterWaveWithdrawScreen,
            page: () => FlutterWaveWithdrawScreen()),
        GetPage(
            name: RoutesName.profileSettingScreen,
            page: () => ProfileSettingScreen()),
        GetPage(
            name: RoutesName.notificationPermissionScreen,
            page: () => NotificationPermissionScreen()),
        GetPage(
            name: RoutesName.editProfileScreen,
            page: () => EditProfileScreen()),
        GetPage(name: RoutesName.qrCodeScreen, page: () => QrCodeScreen()),
        GetPage(
            name: RoutesName.qrPaymentScreen, page: () => QrPaymentScreen()),
        GetPage(
            name: RoutesName.changePasswordScreen,
            page: () => ChangePasswordScreen()),
        GetPage(
            name: RoutesName.supportTicketListScreen,
            page: () => SupportTicketListScreen()),
        GetPage(
            name: RoutesName.supportTicketViewScreen,
            page: () => SupportTicketViewScreen()),
        GetPage(
            name: RoutesName.createSupportTicketScreen,
            page: () => CreateSupportTicketScreen()),
        GetPage(
            name: RoutesName.twoFaVerificationScreen,
            page: () => TwoFaVerificationScreen()),
        GetPage(
            name: RoutesName.identityVerificationScreen,
            page: () => IdentityVerificationScreen()),
        GetPage(
            name: RoutesName.verificationListScreen,
            page: () => VerificationListScreen()),
        GetPage(
            name: RoutesName.notificationScreen,
            page: () => NotificationScreen()),
        GetPage(
            name: RoutesName.manualPaymentScreen,
            page: () => ManualPaymentScreen(title: '')),
        GetPage(
            name: RoutesName.makePaymentScreen,
            page: () => MakePaymentScreen()),
        GetPage(
            name: RoutesName.makePaymentPreviewScreen,
            page: () => MakePaymentPreviewScreen()),
        GetPage(
            name: RoutesName.securityPinSetupScreen,
            page: () => SecurityPinSetupScreen()),
        GetPage(
            name: RoutesName.cashoutScreen,
            page: () => CashoutScreen()),
        GetPage(
            name: RoutesName.cashoutPreviewScreen,
            page: () => CashoutPreviewScreen()),
        GetPage(
            name: RoutesName.paymentSuccessScreen,
            page: () => PaymentSuccessScreen(
                  amount: '',
                  currencySymbol: '',
                  gateway: '',
                )),
        GetPage(
            name: RoutesName.deleteAccountScreen,
            page: () => DeleteAccountScreen()),
      ];
}
