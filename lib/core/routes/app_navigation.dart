import 'package:get/get.dart';
import 'package:simple_todo/features/home/screens/home_screen.dart';
import 'package:simple_todo/features/task/bindings/task_binding.dart';
import 'package:simple_todo/features/task/screens/task_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import 'app_routes.dart';

class AppNavigation {
  AppNavigation._();

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.initialRoute,
      page: () => const HomeScreen(),
      transition: Transition.zoom,
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.taskRoute,
      page: () => const TaskScreen(),
      transition: Transition.upToDown,
      binding: TaskBinding(),
    ),
  ];
}
