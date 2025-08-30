import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/design/app_theme.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: AppTheme.defaultThemeData,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.firstSplashScreen,
      getPages: AppNavigation.routes,

      initialBinding: ControllerBinder(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ControllerBinder extends Bindings {
  /// GLOBAL controller ====>
  @override
  void dependencies() {}
}
