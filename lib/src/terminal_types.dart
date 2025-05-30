import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/src/terminal_controller.dart';

/// Represents a single line of output in the terminal, with styling.
class TerminalLine {
  final String text;
  final Color color;

  TerminalLine({required this.text, required this.color});

  @override
  String toString() => 'TerminalLine(text: "$text", color: $color)';
}


/// A flexible definition for a custom terminal command handler.
/// [command] is the full command string entered by the user.
/// [args] are the arguments following the command name (empty if none).
/// [controller] is the TerminalController instance, allowing the handler
///              to interact with the terminal (e.g., print output, manipulate scope).
typedef TerminalCommandHandler = Future<void> Function(
  String command,
  List<String> args,
  TerminalController controller,
);

/// Configuration for the terminal's visual appearance.
class TerminalTheme {
  final Color backgroundColor;
  final Color promptColor;
  final Color defaultTextColor;
  final Color resultColor; // For Python-like expression results
  final Color errorColor;
  final Color hintColor;
  final double defaultFontSize;
  final double promptFontSize;

  const TerminalTheme({
    this.backgroundColor = Colors.black,
    this.promptColor = Colors.lightGreenAccent,
    this.defaultTextColor = Colors.white,
    this.resultColor = Colors.blueAccent,
    this.errorColor = Colors.redAccent,
    this.hintColor = Colors.grey,
    this.defaultFontSize = 14.0,
    this.promptFontSize = 16.0,
  });

  /// Provides a default dark theme for convenience.
  static const TerminalTheme defaultDark = TerminalTheme();
}
