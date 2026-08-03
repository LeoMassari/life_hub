import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'config/cloud_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (CloudConfig.isConfigured) {
    await Supabase.initialize(
      url: CloudConfig.url,
      publishableKey: CloudConfig.publishableKey,
    );
  }
  runApp(const LifeHubApp());
}
