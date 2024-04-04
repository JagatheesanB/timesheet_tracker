import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timesheet_management/tasks/presentation/widgets/splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'tasks/presentation/providers/language_provider.dart';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: ref.watch(selectedLocaleProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'TIMESHEET',
      theme: ThemeData(),
      home: const SplashScreen(),
    );
  }
}
