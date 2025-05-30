import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/alpha_fake_python_simulation.dart';
import 'package:google_fonts/google_fonts.dart';

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
        backgroundColor: Colors.transparent,
        promptColor: Color(0xFFBB86FC), // Purple accent
        defaultTextColor: Color(0xFFE0E0E0),
        resultColor: Color(0xFF03DAC6), // Teal accent
        errorColor: Color(0xFFFF6E6E), // Soft red
        hintColor: Color(0xFF4CAF50), // Green
        defaultFontSize: 14.0,
        promptFontSize: 16.0,
      ),
      customCommands: {
        'greet': _handleGreetCommand, // Register a custom 'greet' command
        'whoami': _handleWhoAmICommand, // Register a custom 'whoami' command
        'system_status': _handleSystemStatusCommand, // Programmatic check
        'add': _handleAddCommand, // Example of taking arguments
        'sleep': _handleSleepCommand, // Example of async command
      },
    );

    // Add initial output with styling
    Future.delayed(const Duration(milliseconds: 300), () {
      _terminalController.addOutput(
        '⚡ Welcome to Terminal Emulator v1.0.0',
        color: _terminalController.theme.resultColor,
      );
      _terminalController.addOutput(
        '🔍 Initializing system components...',
        color: _terminalController.theme.hintColor,
      );
      _terminalController.addOutput(
        '✅ System ready. Type \'help\' to see available commands.',
        color: _terminalController.theme.hintColor,
      );
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
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1E1E2E),
          background: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.firaCodeTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Terminal Emulator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _terminalController.addOutput(
                  'Terminal Emulator v1.0.0\nType \'help\' for available commands',
                  color: _terminalController.theme.hintColor,
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1E1E2E).withOpacity(0.8),
                const Color(0xFF121212),
              ],
            ),
          ),
          child: SafeArea(
            child: TerminalScreen(controller: _terminalController),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }
}
