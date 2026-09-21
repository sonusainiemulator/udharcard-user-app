import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paysecure/controllers/cashout_controller.dart';
import 'package:paysecure/controllers/makePayment_controller.dart';
import 'package:paysecure/views/screens/makePayment/makePayment_screen.dart';
import '../../../utils/qr_parser_helper.dart';
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
    final parsedIdentifier = QrParserHelper.extractMerchantIdentifier(code);
    if (parsedIdentifier.isEmpty) return;

    if (widget.isFromCashoutPage) {
      if (!Get.isRegistered<CashoutController>()) {
        Get.put(CashoutController());
      }
      CashoutController.to.agentEmailController.text = parsedIdentifier;
      CashoutController.to.checkAgent(agent: parsedIdentifier);
      Get.off(() => CashoutScreen(isFromScannerPage: true));
    } else {
      // Default / Make Payment flow
      if (!Get.isRegistered<MakePaymentController>()) {
        Get.put(MakePaymentController());
      }
      MakePaymentController.to.merchantEmailController.text = parsedIdentifier;
      MakePaymentController.to.checkMerchant(merchant: parsedIdentifier);
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
        title: const Text('Scan & Pay'),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, child) {
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: isOn ? Colors.amber : Colors.white,
                ),
                tooltip: isOn ? 'Turn Flash Off' : 'Turn Flash On',
                onPressed: () => controller.toggleTorch(),
              );
            },
          ),
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
              center: Offset(size.width / 2, size.height / 2 - 30),
              width: scanSize,
              height: scanSize,
            ),
            onDetect: _handleBarcode,
          ),
          // Custom scan frame overlay
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 60),
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Helper instructions above scan window
          Positioned(
            top: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Align merchant QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
          // Bottom Controls: Manual Amount Entry & Scanned Code preview
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_barcode?.displayValue != null) ...[
                      _barcodePreview(),
                      const SizedBox(height: 12),
                    ],
                    // Manual Amount / Merchant Entry Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (!Get.isRegistered<MakePaymentController>()) {
                          Get.put(MakePaymentController());
                        }
                        Get.to(() => MakePaymentScreen(isFromScannerPage: false));
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 22, color: Colors.black87),
                      label: const Text(
                        'Enter Merchant or Amount Manually',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
