import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'app.dart';
import 'core/constants/app_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureEasyLoading();

  runApp(const WebRTCApp());
}

void _configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 12.0
    ..backgroundColor = AppColor.cardSurface
    ..indicatorColor = AppColor.primary
    ..textColor = AppColor.textMain
    ..userInteractions = false
    ..dismissOnTap = false;
}
