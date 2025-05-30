import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/alpha_fake_python_simulation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize the TerminalController.
  // We can pass custom theme settings and custom commands here.
  late final TerminalController _terminalController;

  @override
  void initState() {
    super.initState();

    _terminalController = TerminalController(
      theme: const TerminalTheme(
        // Customizing the theme for this example
        backgroundColor: Color(0xFF1E1E2E), // A dark purple background
        promptColor: Colors.amberAccent,
        defaultTextColor: Colors.white70,
        resultColor: Colors.lightBlueAccent,
        errorColor: Colors.pinkAccent,
        hintColor: Colors.greenAccent,
        defaultFontSize: 15.0,
        promptFontSize: 17.0,
      ),
      customCommands: {
        'greet': _handleGreetCommand, // Register a custom 'greet' command
        'whoami': _handleWhoAmICommand, // Register a custom 'whoami' command
        'system_status': _handleSystemStatusCommand, // Programmatic check
        'add': _handleAddCommand, // Example of taking arguments
        'sleep': _handleSleepCommand, // Example of async command
      },
    );

    // You can also add initial output programmatically:
    Future.delayed(const Duration(milliseconds: 500), () {
      _terminalController.addOutput('System boot initiated...', color: Colors.lightBlueAccent);
      _terminalController.addOutput('Loading modules...', color: Colors.lightBlueAccent);
      _terminalController.addOutput('Access granted. Type \'help\' for available commands.', color: Colors.greenAccent);
    });
  }

  // --- Custom Command Handlers ---
  // These functions define the logic for user-defined commands.
  // They receive the full command, arguments, and the controller itself.

  Future<void> _handleGreetCommand(String command, List<String> args, TerminalController controller) async {
    if (args.isEmpty) {
      controller.addOutput("Usage: greet <name>", color: controller.theme.errorColor);
    } else {
      final name = args.join(' ');
      controller.addOutput("Hello, $name! Welcome to the alpha fake terminal.", color: controller.theme.hintColor);
    }
  }

  Future<void> _handleWhoAmICommand(String command, List<String> args, TerminalController controller) async {
    controller.addOutput("You are user: FlutterDev_99", color: controller.theme.hintColor);
    controller.addOutput("Session ID: ${DateTime.now().microsecondsSinceEpoch}", color: controller.theme.hintColor);
  }

  Future<void> _handleSystemStatusCommand(String command, List<String> args, TerminalController controller) async {
    controller.addOutput("Checking system status...", color: controller.theme.hintColor);
    await Future.delayed(const Duration(seconds: 1)); // Simulate a delay
    controller.addOutput("• CPU: 12%", color: controller.theme.hintColor);
    controller.addOutput("• Memory: 2.3GB / 8GB", color: controller.theme.hintColor);
    controller.addOutput("• Disk: 45% used", color: controller.theme.hintColor);
    controller.addOutput("• Network: 1.2MB/s ↓ 0.8MB/s ↑", color: controller.theme.hintColor);
  }

  Future<void> _handleAddCommand(String command, List<String> args, TerminalController controller) async {
    if (args.length < 2) {
      controller.addOutput("Usage: add <num1> <num2> [num3...]", color: controller.theme.errorColor);
      return;
    }

    try {
      final numbers = args.map((e) => double.tryParse(e)).toList();
      if (numbers.any((n) => n == null)) {
        controller.addOutput("Error: All arguments must be numbers", color: controller.theme.errorColor);
        return;
      }

      final sum = numbers.fold(0.0, (sum, num) => sum! + num!);
      controller.addOutput("Sum: $sum", color: controller.theme.resultColor);
    } catch (e) {
      controller.addOutput("Error: $e", color: controller.theme.errorColor);
    }
  }

  Future<void> _handleSleepCommand(String command, List<String> args, TerminalController controller) async {
    int seconds = 1;
    if (args.isNotEmpty) {
      seconds = int.tryParse(args[0]) ?? 1;
    }

    controller.addOutput("Sleeping for $seconds second(s)...", color: controller.theme.hintColor);
    await Future.delayed(Duration(seconds: seconds));
    controller.addOutput("Awake after $seconds second(s)!", color: controller.theme.hintColor);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FakePyTerminal Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TerminalScreen(controller: _terminalController),
    );
  }

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }
}
