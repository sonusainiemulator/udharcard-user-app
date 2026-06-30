import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paysecure/controllers/cashout_controller.dart';
import 'package:paysecure/controllers/makePayment_controller.dart';
import 'package:paysecure/views/screens/makePayment/makePayment_screen.dart';
import '../../../utils/services/helpers.dart';
import 'package:image_picker/image_picker.dart';
import '../cashout/cash_out_screen.dart';

class MobileScannerScreen extends StatefulWidget {
  final bool isFromCashoutPage;
  final bool isFromMakePaymentPage;
  final BuildContext? context;

  const MobileScannerScreen({
    super.key,
    this.isFromCashoutPage = false,
    this.isFromMakePaymentPage = false,
    this.context,
  });

  @override
  State<MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<MobileScannerScreen> {
  final controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  Barcode? _barcode;

  void _handleBarcode(BarcodeCapture barcodes) {
    final code = barcodes.barcodes.firstOrNull?.displayValue;
    if (code != null && mounted) {
      _barcode = barcodes.barcodes.first;
      _processScannedCode(code);
    }
  }

  void _processScannedCode(String code) {
    if (widget.isFromCashoutPage) {
      CashoutController.to.agentEmailController.text = code;
      CashoutController.to.checkAgent(agent: code);
      Get.off(() => CashoutScreen(isFromScannerPage: true));
    } else if (widget.isFromMakePaymentPage) {
      MakePaymentController.to.merchantEmailController.text = code;
      MakePaymentController.to.checkMerchant(merchant: code);
      Get.off(() => MakePaymentScreen(isFromScannerPage: true));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final BarcodeCapture? barcodes = await controller.analyzeImage(image.path);
        if (barcodes != null && barcodes.barcodes.isNotEmpty) {
          final code = barcodes.barcodes.first.displayValue;
          if (code != null && mounted) {
            _processScannedCode(code);
          }
        } else {
          Helpers.showSnackBar(
            msg: "No QR Code found in the selected image",
            title: "Error",
            bgColor: Colors.red,
          );
        }
      }
    } catch (e) {
      Helpers.showSnackBar(
        msg: "Failed to pick or scan image: $e",
        title: "Error",
        bgColor: Colors.red,
      );
    }
  }

  Widget _barcodePreview() {
    return Text(
      _barcode?.displayValue ?? 'QR Code not found',
      style: const TextStyle(color: Colors.white),
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: 'Upload QR Code from Gallery',
            onPressed: _pickImageFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            scanWindow: Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: scanSize,
              height: scanSize,
            ),
            onDetect: _handleBarcode,
          ),
          // Custom scan frame overlay
          Center(
            child: Container(
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black45,
              padding: const EdgeInsets.all(16),
              child: Center(child: _barcodePreview()),
            ),
          ),
        ],
      ),
    );
  }
}
