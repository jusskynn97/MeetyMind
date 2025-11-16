import 'package:front_end/app/di/auth_injection.dart';
import 'package:front_end/app/di/core_injection.dart';
import 'package:front_end/app/di/dashboard_injection.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core modules
  await CoreInjection.register(sl);
  await AuthInjection.register(sl);
  DashboardInjection.register(sl);
}