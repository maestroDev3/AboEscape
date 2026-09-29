import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/shared_preferences_subscription_repository.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    AboEscapeApp(
      repository: SharedPreferencesSubscriptionRepository(preferences),
    ),
  );
}
