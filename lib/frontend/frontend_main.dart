import 'package:flutter/material.dart';
import 'app.dart';

/// Standalone entry point for previewing the frontend skeleton.
///
/// Run with:  flutter run -t lib/frontend/frontend_main.dart
///
/// This is intentionally separate from lib/main.dart so the UI can be
/// developed and viewed WITHOUT touching or running the backend.
void main() {
  runApp(const ScreenTimeApp());
}
