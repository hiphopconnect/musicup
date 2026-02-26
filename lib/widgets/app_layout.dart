import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/widgets/animated_widgets.dart';

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
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.screenLabel(title),
      child: Scaffold(
        appBar: AppBar(
          title: Semantics(
            label: l10n.titleLabel(title),
            header: true,
            child: Text(title),
          ),
          backgroundColor: appBarColor,
          actions: actions?.map((action) {
            if (action is IconButton) {
              return Semantics(
                button: true,
                child: action,
              );
            }
            return action;
          }).toList(),
        ),
        body: SafeArea(
          // SafeArea fuer besseren Layout-Schutz
          child: body,
        ),
        floatingActionButton: floatingActionButton != null
            ? ScaleInWidget(
                delay: const Duration(milliseconds: 500),
                child: Semantics(
                  button: true,
                  label: l10n.actionButton,
                  child: floatingActionButton!,
                ),
              )
            : null,
        resizeToAvoidBottomInset: true, // Keyboard-Handling
      ),
    );
  }
}
