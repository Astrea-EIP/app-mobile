import 'package:flutter/material.dart';

import 'core/design_tokens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Astrea',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AstreaColors.primary),
        fontFamily: AstreaTypography.body,
        useMaterial3: true,
      ),
      home: const Scaffold(body: Center(child: Text('Astrea App'))),
    );
  }
}
