import '../cashout_controller.dart';
import '../escrow_controller.dart';
import '../exchange_controller.dart';
import '../makePayment_controller.dart';
import '../pin_reset_controller.dart';
import '../request_money_controller.dart';
import '../send_money_controller.dart';
import '../voucher_controller.dart';
import '../redeem_code_controller.dart';
import 'controller_index.dart';

class InitBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(ProfileController());
    Get.put(PushNotificationController());

    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<BottomNavController>(() => BottomNavController(), fenix: true);
    Get.lazyPut<SupportTicketController>(() => SupportTicketController(),
        fenix: true);
    Get.lazyPut<TransactionController>(() => TransactionController(),
        fenix: true);
    Get.lazyPut<WithdrawHistoryController>(() => WithdrawHistoryController(),
        fenix: true);
    Get.lazyPut<WithdrawController>(() => WithdrawController(), fenix: true);
    Get.lazyPut<WithdrawHistoryController>(() => WithdrawHistoryController(), fenix: true);
    Get.lazyPut<DepositController>(() => DepositController(), fenix: true);
    Get.lazyPut<NotificationSettingsController>(
        () => NotificationSettingsController(),
        fenix: true);
    Get.lazyPut<VerificationController>(() => VerificationController(),
        fenix: true);
    Get.lazyPut<CardController>(() => CardController(), fenix: true);
    Get.lazyPut<CardTransactionController>(() => CardTransactionController(),
        fenix: true);
    Get.lazyPut<RedeemCodeController>(() => RedeemCodeController(),
        fenix: true);
    Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);
    Get.lazyPut<InvoiceHistoryController>(() => InvoiceHistoryController(), fenix: true);
    Get.lazyPut<PayBillController>(() => PayBillController(), fenix: true);
    Get.lazyPut<PayBillHistoryController>(() => PayBillHistoryController(),
        fenix: true);
    Get.lazyPut<RedeemHistoryController>(() => RedeemHistoryController(),
        fenix: true);
    Get.lazyPut<QrPaymentController>(() => QrPaymentController(),
        fenix: true);
    Get.lazyPut<EscrowController>(() => EscrowController(),
        fenix: true);
    Get.lazyPut<EscrowHistoryController>(() => EscrowHistoryController(),
        fenix: true);
    Get.lazyPut<VoucherController>(() => VoucherController(),
        fenix: true);
    Get.lazyPut<VoucherController>(() => VoucherController(),
        fenix: true);
    Get.lazyPut<VoucherHistoryController>(() => VoucherHistoryController(),
        fenix: true);
    Get.lazyPut<DisputeHistoryController>(() => DisputeHistoryController(),
        fenix: true);
    Get.lazyPut<SendMoneyController>(() => SendMoneyController(),
        fenix: true);
    Get.lazyPut<SendMoneyHistoryController>(() => SendMoneyHistoryController(),
        fenix: true);
    Get.lazyPut<RequestMoneyController>(() => RequestMoneyController(),
        fenix: true);
    Get.lazyPut<RequestHistoryController>(() => RequestHistoryController(),
        fenix: true);
    Get.lazyPut<ExchangeController>(() => ExchangeController(),
        fenix: true);
    Get.lazyPut<ExchangeHistoryController>(() => ExchangeHistoryController(),
        fenix: true);
    Get.lazyPut<DepositHistoryController>(() => DepositHistoryController(),
        fenix: true);
    Get.lazyPut<MakePaymentController>(() => MakePaymentController(),
        fenix: true);
    Get.lazyPut<CashoutController>(() => CashoutController(),
        fenix: true);
    Get.lazyPut<PinResetController>(() => PinResetController(),
        fenix: true);
  }
}
