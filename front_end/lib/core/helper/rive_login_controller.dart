import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveLoginController {
  final String animationPath;
  late final StateMachineController? _controller;
  late final Artboard? artboard;

  SMITrigger? failTrigger, successTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? lookNum;

  RiveLoginController({required this.animationPath});

  /// Khởi tạo Rive, load file và lấy controller
  Future<void> init() async {
    final data = await rootBundle.load(animationPath);
    final file = RiveFile.import(data);
    final art = file.mainArtboard;
    _controller = StateMachineController.fromArtboard(art, "Login Machine");

    if (_controller != null) {
      art.addController(_controller!);

      for (var input in _controller!.inputs) {
        switch (input.name) {
          case "isFocus":
            isChecking = input as SMIBool;
            break;
          case "isPrivateField":
            isHandsUp = input as SMIBool;
            break;
          case "successTrigger":
            successTrigger = input as SMITrigger;
            break;
          case "failTrigger":
            failTrigger = input as SMITrigger;
            break;
          case "numLook":
            lookNum = input as SMINumber;
            break;
        }
      }
    }

    artboard = art;
  }

  // Các hàm điều khiển animation:
  void lookAround() {
    isChecking?.change(true);
    isHandsUp?.change(false);
    lookNum?.change(0);
  }

  void moveEyes(String value) {
    lookNum?.change(value.length.toDouble());
  }

  void handsUpOnEyes() {
    isHandsUp?.change(true);
    isChecking?.change(false);
  }

  void login(bool isValid) {
    isChecking?.change(false);
    isHandsUp?.change(false);
    if (isValid) {
      successTrigger?.fire();
    } else {
      failTrigger?.fire();
    }
  }
}
