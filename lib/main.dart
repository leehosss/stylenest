import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'models/auth_model.dart';
import 'models/products_model.dart';
import 'models/cart_model.dart';
import 'models/user_model.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 무신사 느낌의 컬러 팔레트
    const primary = Color(0xFF222222);
    const accent = Color(0xFFFFC107);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => ProductsModel()),
        ChangeNotifierProvider(create: (_) => CartModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: MaterialApp(
        title: 'StyleNest',
        theme: ThemeData(
          primaryColor: primary,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
              .copyWith(secondary: accent),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme: GoogleFonts.notoSansTextTheme().copyWith(
            titleLarge: GoogleFonts.notoSans(
                fontSize: 20, fontWeight: FontWeight.w700, color: primary),
            bodyMedium: GoogleFonts.notoSans(
                fontSize: 14, color: Colors.black87),
            labelLarge:
            GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}