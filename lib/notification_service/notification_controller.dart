import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:paysecure/data/source/errors/check_api_status.dart';
import '../data/repositories/notification_repo.dart';
import '../routes/routes_name.dart';
import '../utils/services/localstorage/hive.dart';
import '../utils/services/localstorage/keys.dart';
import 'notification_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PushNotificationController extends GetxController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  dynamic data;
  RxBool isSeen = true.obs;
  Future<dynamic> getPushNotificationConfig() async {
    _isLoading = true;
    update();
    http.Response res = await NotificationRepo.getPusherConfig();

    if (res.statusCode == 200) {
      _isLoading = false;
      data = jsonDecode(res.body);
      update();
      if (data['status'] == "success") {
        HiveHelp.write(Keys.channelName, data['message']['channel']);
        PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
        try {
          await pusher.init(
            apiKey: data['message']['apiKey'],
            cluster: data['message']['cluster'],
            onConnectionStateChange: onConnectionStateChange,
            onSubscriptionSucceeded: onSubscriptionSucceeded,
            onEvent: onEvent,
            onSubscriptionError: onSubscriptionError,
            onMemberAdded: onMemberAdded,
            onMemberRemoved: onMemberRemoved,
          );
          await pusher.subscribe(channelName: data['message']['channel']);
          await pusher.connect();
        } catch (e) {
          print("ERROR====================================: $e");
        }

        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      _isLoading = false;
      update();
    }
  }

  FlutterTts flutterTts = FlutterTts();

  void _playHindiTTS(String text) async {
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void onEvent(PusherEvent event) async {
    if (kDebugMode) {
      print("onEvent: ${event.data}");
    }
    // Parse the JSON response
    Map<String, dynamic> eventData = json.decode(event.data);
    Map<String, dynamic> message = eventData['message'];
    String text =
        message['description']['text'].toString().replaceAll("\n", " ");
    String formattedDate = DateFormat.yMMMMd().add_jm().format(DateTime.now());

    // Extract amount and determine credit/debit for TTS
    String amount = "";
    bool isCredit = false;
    bool isDebit = false;
    
    String lowerText = text.toLowerCase();
    // Try to extract amount from JSON if available, otherwise fallback to regex
    if (message.containsKey('amount')) {
      amount = message['amount'].toString();
    } else {
      // Find the first occurrence of a number (including decimals)
      RegExp amountRegex = RegExp(r'\d+(\.\d+)?');
      var match = amountRegex.firstMatch(text);
      if (match != null) {
        amount = match.group(0) ?? "";
      }
    }

    if (message.containsKey('type')) {
      String type = message['type'].toString().toLowerCase();
      isCredit = type == 'credit' || type == 'deposit' || type == 'add_money' || type == 'receive';
      isDebit = type == 'debit' || type == 'withdraw' || type == 'send' || type == 'pay';
    } 
    
    // Fallback to text matching if type wasn't clear
    if (!isCredit && !isDebit) {
      if (lowerText.contains("received") || lowerText.contains("credited") || lowerText.contains("added") || lowerText.contains("deposit")) {
        isCredit = true;
      } else if (lowerText.contains("deducted") || lowerText.contains("sent") || lowerText.contains("paid") || lowerText.contains("debited") || lowerText.contains("withdraw")) {
        isDebit = true;
      }
    }

    if (amount.isNotEmpty) {
      if (isCredit) {
        _playHindiTTS("Aapko $amount rupaye prapt hue hain");
      } else if (isDebit) {
        _playHindiTTS("Aapke $amount rupaye udhar card se le liye gaye hain");
      }
    }

    // Show the response in the flutter_local_notification
    LocalNotificationService().showNotification(
      id: Random().nextInt(99),
      title: text,
      body: formattedDate,
    );

    var storedData = await HiveHelp.read(data['message']['channel']);
    List<Map<dynamic, dynamic>> notificationList =
        storedData != null ? List<Map<dynamic, dynamic>>.from(storedData) : [];
    notificationList.insert(0, {
      'text': text.trim(),
      'date': formattedDate,
    });

    HiveHelp.write(data['message']['channel'], notificationList);
    HiveHelp.write(Keys.isNotificationSeen, false);
    isSeen.value = HiveHelp.read(Keys.isNotificationSeen);

    update();
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    debugPrint("onSubscriptionSucceeded: $channelName data: ${data}");
  }

  void onSubscriptionError(String message, dynamic e) {
    debugPrint("onSubscriptionError: $message Exception: $e");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    debugPrint("onMemberAdded: $channelName member: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    debugPrint("onMemberRemoved: $channelName member: $member");
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint("Connection: $currentState");
  }

  clearList() {
    var channelName = HiveHelp.read(Keys.channelName);
    HiveHelp.remove(channelName);
    update();
  }

  isNotiSeen() {
    HiveHelp.write(Keys.isNotificationSeen, true);
    isSeen.value = HiveHelp.read(Keys.isNotificationSeen);
    Get.toNamed(RoutesName.notificationScreen);
    update();
  }
}
