import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appScope = await AppScope.create();

  runApp(
    AppScopeProvider(
      scope: appScope,
      child: const QuranHadithApp(),
    ),
  );
}
