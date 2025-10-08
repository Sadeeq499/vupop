import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlinkController extends GetxController {
  final List<Widget> children;
  final int interval;

  RxInt currentWidget = 0.obs;

  BlinkController({required this.children, this.interval = 500});

  @override
  void onInit() {
    super.onInit();
    startBlinking();
  }

  void startBlinking() {
    // Setup periodic timer that changes the current widget
    ever(currentWidget, (_) {}); // Setup reactive binding

    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: interval));
      if (currentWidget.value + 1 >= children.length) {
        currentWidget.value = 0;
      } else {
        currentWidget.value++;
      }
      return true; // Continue the loop indefinitely
    });
  }
}

class BlinkWidget extends StatelessWidget {
  final List<Widget> children;
  final int interval;

  const BlinkWidget({
    required this.children,
    this.interval = 500,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final BlinkController controller = Get.put(BlinkController(children: children, interval: interval));

    return Obx(() => Container(
          child: controller.children[controller.currentWidget.value],
        ));
  }
}
