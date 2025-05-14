// notification work here

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_assist/config/route/route.dart';
import 'package:smart_assist/config/route/route_name.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_assist/services/notifacation_srv.dart';
import 'package:smart_assist/utils/connection_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  await Hive.initFlutter(); // Initialize Hive after Firebase
  await NotificationService.instance.initialize(); // Initialize Notifications
  // Initialize connection service
  await ConnectionService().initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widget!,
            );
          },
          initialRoute: RoutesName.splashScreen,
          // home: ProfileScreen(), //remove this
          onGenerateRoute: Routes.generateRoute,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFFFFFFFF),
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFFFFFFF)),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
 