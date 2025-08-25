import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Color? appBarColor;

  const AppLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
        actions: actions,
      ),
      body: SafeArea(
        // ✅ SafeArea für besseren Layout-Schutz
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: true, // ✅ Keyboard-Handling
    );
  }
}
