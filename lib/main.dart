import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Screens
import 'vn/edu/myfschool/presentation/screens/login_screen.dart';

// Import Providers
import 'vn/edu/myfschool/controller/auth_provider.dart';
import 'vn/edu/myfschool/controller/timetable_provider.dart';
import 'vn/edu/myfschool/controller/grade_provider.dart';
import 'vn/edu/myfschool/controller/leave_request_provider.dart';
import 'vn/edu/myfschool/controller/chat_provider.dart';
import 'vn/edu/myfschool/controller/misc_providers.dart';

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
      title: 'F-School App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Màu cam đặc trưng của hệ thống FPT
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF27024)), 
        useMaterial3: true,
      ),
      // Tạm thời luôn mở trang Đăng nhập đầu tiên. 
      // (Sau này ta sẽ thêm logic kiểm tra token, nếu có token thì ném thẳng vào HomeScreen)
      home: const LoginScreen(), 
    );
  }
}
