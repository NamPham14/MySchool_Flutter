import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vn/edu/myfschool/presentation/screens/splash_screen.dart';

// Import Providers
import 'vn/edu/myfschool/controller/auth_provider.dart';
import 'vn/edu/myfschool/controller/timetable_provider.dart';
import 'vn/edu/myfschool/controller/grade_provider.dart';
import 'vn/edu/myfschool/controller/leave_request_provider.dart';
import 'vn/edu/myfschool/controller/chat_provider.dart';
import 'vn/edu/myfschool/controller/misc_providers.dart';
import 'vn/edu/myfschool/controller/notification_provider.dart';
import 'vn/edu/myfschool/controller/club_provider.dart';
import 'vn/edu/myfschool/core/constants/globals.dart';

void main() {
  runApp(
    // Bọc toàn bộ App bằng MultiProvider để cung cấp "não bộ" cho tất cả các màn hình UI
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        ChangeNotifierProvider(create: (_) => GradeProvider()),
        ChangeNotifierProvider(create: (_) => LeaveRequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => FeeInvoiceProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'F-School App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Màu cam đặc trưng của hệ thống FPT
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF27024)), 
        useMaterial3: true,
      ),
      // Sử dụng SplashScreen để kiểm tra trạng thái đăng nhập
      home: const SplashScreen(), 
    );
  }
}
