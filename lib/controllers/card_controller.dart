import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/app_colors.dart';
import '../data/models/virtual_card_model.dart' as v;
import '../data/repositories/card_repo.dart';
import '../data/source/errors/check_api_status.dart';

class CardController extends GetxController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TextEditingController reasonCtrl = TextEditingController();

  List<v.CardOrder> virtualCardList = [];
  List<v.CardOrder> virtualCardFormList = [];
  String orderLock = "";

  Future getVirtualCards({bool? isFromRefreshIndicator = false}) async {
    if (isFromRefreshIndicator == false) {
      _isLoading = true;
      update();
    }
    http.Response response = await CardRepo.getVirtualCards();
    if (isFromRefreshIndicator == false) {
      _isLoading = false;
      update();
    }
    virtualCardList = [];
    dynamicFormList = [];
    virtualCardFormList = [];
    update();
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        virtualCardList = [
          ...virtualCardList,
          ...v.VirtualCardModel.fromJson(data).message!.approveCards!
        ];
        if (data['message']['cardOrder'] != null)
          virtualCardFormList
              .add(v.VirtualCardModel.fromJson(data).message!.cardOrder!);
        orderLock = data['message']['orderLock'] == null
            ? "false"
            : data['message']['orderLock'].toString();

        if (data['message']['cardOrder'] != null &&
            data['message']['cardOrder'] is Map) {
          selectedCurr = data['message']['cardOrder']['currency'] ?? "";
          cardOrderCurrencyList = [];
          cardOrderCurrencyList.add(selectedCurr);
          if (data['message']['cardOrder']['form_input'] != null &&
              data['message']['cardOrder']['form_input'] is Map) {
            Map<String, dynamic> form =
                data['message']['cardOrder']['form_input'];
            await Future.forEach(form.entries,
                (MapEntry<String, dynamic> e) async {
              dynamicFormList.add(DynamicFormModel(
                fieldName: e.value['field_name'] ?? "",
                fieldLevel: e.value['field_level'] ?? "",
                placeholder: e.value['field_value'] ?? "",
                type: e.value['type'] ?? "",
                validation: e.value['validation'] ?? "",
              ));
            });
            await filterData(isFromResubmit: true);
          }
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      virtualCardList = [];
    }
  }

  bool isBlocking = false;
  Future blockCard(
      {required String id, required String reason, required context}) async {
    isBlocking = true;
    update();
    http.Response response = await CardRepo.blockCard(id: id, reason: reason);
    isBlocking = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == "success") {
        reasonCtrl.clear();
        Navigator.pop(context);
        getVirtualCards();
      }
    } else {
      ApiStatus.checkStatus("error", "Something went wrong!");
    }
  }

  var fileColorOfDField = AppColors.mainColor;
  List<dynamic> cardOrderCurrencyList = [];
  String selectedCurr = "";
  List<DynamicFormModel> dynamicFormList = [];
  String title = "";
  String description = "";
  bool isCardOrderLoad = false;
  bool enable_for = false;
  TextEditingController securityPinController = TextEditingController();
  Future getCardOrder({bool? isFromRefreshIndicator = false}) async {
    if (isFromRefreshIndicator == false) {
      isCardOrderLoad = true;
      update();
    }
    update();
    http.Response response = await CardRepo.cardOrder();
    if (isFromRefreshIndicator == false) {
      isCardOrderLoad = false;
      update();
    }
    cardOrderCurrencyList = [];
    dynamicFormList = [];
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        enable_for = data['message']['enable_for'];
        title = data['message']['virtualCardMethod']['name'] ?? "";
        description = data['message']['virtualCardMethod']['info_box'] ?? "";
        cardOrderCurrencyList =
            data['message']['virtualCardMethod']['currency'];
        if (cardOrderCurrencyList.contains("USD")) {
          selectedCurr = "USD";
        }
        if (data['message']['virtualCardMethod']['form_field'] != null &&
            data['message']['virtualCardMethod']['form_field'] is Map) {
          Map<String, dynamic> form =
              data['message']['virtualCardMethod']['form_field'];
          await Future.forEach(form.entries,
              (MapEntry<String, dynamic> e) async {
            dynamicFormList.add(DynamicFormModel(
              fieldName: e.value['field_name'] ?? "",
              fieldLevel: e.value['field_level'] ?? "",
              placeholder: e.value['field_place'] ?? "",
              type: e.value['type'] ?? "",
              validation: e.value['validation'] ?? "",
            ));
          });
          await filterData();
        }
        update();
      } else {
        ApiStatus.checkStatus(data['status'], data['message']);
      }
    } else {
      cardOrderCurrencyList = [];
    }
  }

  bool isFormSubmtting = false;
  Future cardOrderSubmit(
      {required Iterable<http.MultipartFile>? fileList,
      required Map<String, String> fields,
      required BuildContext context}) async {
    isFormSubmtting = true;
    update();
    http.Response response =
        await CardRepo.cardOrderSubmit(fields: fields, fileList: fileList);
    isFormSubmtting = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == "success") {
        await getVirtualCards();
        refreshData();
        Navigator.pop(context);
      }
    } else {
      ApiStatus.checkStatus("error", "Something went wrong!");
    }
  }

  Future cardOrderReSubmit(
      {required Iterable<http.MultipartFile>? fileList,
      required Map<String, String> fields,
      required BuildContext context}) async {
    isFormSubmtting = true;
    update();
    http.Response response =
        await CardRepo.cardOrderReSubmit(fields: fields, fileList: fileList);
    isFormSubmtting = false;
    update();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      ApiStatus.checkStatus(data['status'], data['message']);
      if (data['status'] == "success") {
        await getVirtualCards();
        refreshData();
        Navigator.pop(context);
      }
    } else {
      ApiStatus.checkStatus("error", "Something went wrong!");
    }
  }

  @override
  void onInit() {
    getVirtualCards();
    super.onInit();
  }

  //------------------let's manupulate the dynamic form data-----//
  Map<String, TextEditingController> textEditingControllerMap = {};
  List<DynamicFormModel> fileType = [];
  List<DynamicFormModel> requiredFile = [];

  Future filterData({bool? isFromResubmit = false}) async {
    // check if the field type is text, textarea, number or date
    var textType =
        await dynamicFormList.where((e) => e.type != 'file').toList();

    for (var field in textType) {
      if (isFromResubmit == true) {
        textEditingControllerMap[field.fieldName] =
            TextEditingController(text: field.placeholder);
      } else {
        textEditingControllerMap[field.fieldName] = TextEditingController();
      }
    }

    // check if the field type is file
    fileType = await dynamicFormList.where((e) => e.type == 'file').toList();
    // listing the all required file
    requiredFile =
        await fileType.where((e) => e.validation == 'required').toList();
  }

  Map<String, dynamic> dynamicData = {};
  List<String> imgPathList = [];

  Future renderDynamicFieldData() async {
    imgPathList.clear();
    textEditingControllerMap.forEach((key, controller) {
      dynamicData[key] = controller.text;
    });
    await Future.forEach(imagePickerResults.keys, (String key) async {
      String filePath = imagePickerResults[key]!.path;
      imgPathList.add(imagePickerResults[key]!.path);
      dynamicData[key] = await http.MultipartFile.fromPath("", filePath);
    });
  }

  final formKey = GlobalKey<FormState>();
  XFile? pickedImageFile;
  Map<String, http.MultipartFile> fileMap = {};
  Map<String, XFile?> imagePickerResults = {};
  Future<void> pickFile(String fieldName) async {


      try {
        final picker = ImagePicker();
        pickedImageFile = await picker.pickImage(source: ImageSource.camera);

        if (pickedImageFile != null) {
          imagePickerResults[fieldName] = pickedImageFile;
          final file = await http.MultipartFile.fromPath(
              fieldName, pickedImageFile!.path);
          fileMap[fieldName] = file;
          update();
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error while picking files: $e");
        }
      }
 
  }
  //--------------------------------------------------//

  refreshData() {
    dynamicFormList.clear();
    imagePickerResults.clear();
    dynamicData.clear();
    textEditingControllerMap.clear();
    fileType.clear();
    requiredFile.clear();
    pickedImageFile = null;
    fileMap.clear();
    selectedCurr = "";
  }
}

class DynamicFormModel {
  String fieldName;
  String fieldLevel;
  String placeholder;
  String type;
  String validation;
  DynamicFormModel({
    required this.fieldName,
    required this.fieldLevel,
    required this.placeholder,
    required this.type,
    required this.validation,
  });
}
