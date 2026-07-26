import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/call/controllers/call_controller.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../../features/users/controllers/users_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<UsersController>(() => UsersController(), fenix: true);
    Get.put<CallController>(CallController(), permanent: true);
  }
}
