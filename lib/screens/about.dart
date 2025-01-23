import 'package:flutter/material.dart';
import 'package:quick_tasks/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context)?.translate('AboutTaskTitle') ??
            "About QuickTasks",
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('AboutTaskDescription') ??
                  "QuickTasks is a task management app designed to help you organize your tasks efficiently.",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.translate('AboutTaskVersion') ??
                  "Version: 1.0.0",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.translate('AboutTaskDevName') ??
                  "Developed by: Louay zaidi",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
