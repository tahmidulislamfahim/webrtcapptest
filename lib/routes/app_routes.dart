import 'package:get/get.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/call/screens/active_call_screen.dart';
import '../features/call/screens/incoming_call_screen.dart';
import '../features/call/screens/outgoing_call_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/users/screens/users_screen.dart';

class AppRoutes {
  static const String splashScreen = '/splash';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String usersScreen = '/users';
  static const String outgoingCallScreen = '/outgoing_call';
  static const String incomingCallScreen = '/incoming_call';
  static const String activeCallScreen = '/active_call';

  static final List<GetPage> routes = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: loginScreen,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: registerScreen,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: usersScreen,
      page: () => const UsersScreen(),
    ),
    GetPage(
      name: outgoingCallScreen,
      page: () => const OutgoingCallScreen(),
    ),
    GetPage(
      name: incomingCallScreen,
      page: () => const IncomingCallScreen(),
    ),
    GetPage(
      name: activeCallScreen,
      page: () => const ActiveCallScreen(),
    ),
  ];
}
