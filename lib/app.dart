import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'core/binding/controller_binder.dart';
import 'core/constants/app_color.dart';
import 'routes/app_routes.dart';

class WebRTCApp extends StatelessWidget {
  const WebRTCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WebRTC Call App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.background,
        primaryColor: AppColor.primary,
        useMaterial3: true,
      ),
      initialBinding: ControllerBinder(),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
      builder: EasyLoading.init(),
    );
  }
}
