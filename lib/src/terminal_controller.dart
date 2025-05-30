import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/src/fake_python_interpreter.dart';

// Export the TerminalController class and related types
import 'terminal_types.dart';

/// Manages the state and logic for the fake terminal.
///
/// This class is responsible for:
/// - Maintaining terminal history and output
/// - Managing the simulated Python scope (variables and their values)
/// - Processing and executing commands
/// - Providing an interface for custom commands
/// - Managing the terminal's visual theme and appearance
///
/// This controller is a [ChangeNotifier] so that the [TerminalScreen] (and any
/// other UI parts interested in the terminal state) can listen for updates.
class TerminalController extends ChangeNotifier {
  final List<TerminalLine> _history = [];
  final Map<String, dynamic> _pythonScope = {};
  final Map<String, TerminalCommandHandler> _customCommands = {};

  late final FakePythonInterpreter _pythonInterpreter;
  late final ScrollController _scrollController;

  /// The theme currently applied to the terminal.
  final TerminalTheme theme;

  /// Creates a [TerminalController].
  ///
  /// [theme]: The visual theme to apply to the terminal.
  /// [customCommands]: A map of command names to [TerminalCommandHandler] functions
  ///   for extending the terminal's capabilities.
  TerminalController({
    this.theme = TerminalTheme.defaultDark,
    Map<String, TerminalCommandHandler>? customCommands,
  }) {
    _pythonInterpreter = FakePythonInterpreter(this);
    _scrollController = ScrollController();
    if (customCommands != null) {
      _customCommands.addAll(customCommands);
    }
  }

  /// Returns an unmodifiable list of the terminal's history.
  List<TerminalLine> get history => List.unmodifiable(_history);

  /// Returns an unmodifiable map of the simulated Python scope variables.
  Map<String, dynamic> get pythonScope => Map.unmodifiable(_pythonScope);

  /// Provides access to the internal ScrollController for programmatic scrolling.
  ScrollController get scrollController => _scrollController;

  /// Initializes the terminal, typically by printing a welcome message.
  void init() {
    addOutput("===================================", color: theme.promptColor);
    addOutput("||  Welcome to FakePyTerminal!   ||", color: theme.promptColor);
    addOutput("||  (A Dart simulation of Python)||", color: theme.promptColor);
    addOutput("===================================", color: theme.promptColor);
    addOutput("");
    addOutput("Type 'help' for commands, 'exit' to quit.", color: theme.defaultTextColor);
    addOutput("");
    notifyListeners(); // Notify listeners after initial setup
  }

  /// Adds a new line of text to the terminal history.
  /// [message]: The text content of the line.
  /// [color]: The color of the text. Defaults to the theme's [defaultTextColor].
  /// [scroll]: Whether to auto-scroll to the bottom after adding the line.
  void addOutput(String message, {Color? color, bool scroll = true}) {
    _history.add(TerminalLine(text: message, color: color ?? theme.defaultTextColor));
    // Keep history from growing indefinitely
    if (_history.length > 500) { // Limit to 500 lines
      _history.removeRange(0, _history.length - 500);
    }
    notifyListeners();
    if (scroll) {
      _scrollToBottom();
    }
  }

  /// Processes a command string entered by the user.
  ///
  /// This method checks for built-in commands, then custom commands, and
  /// finally attempts to interpret it as a Python-like command.
  Future<void> executeCommand(String input) async {
    final trimmedInput = input.trim();
    if (trimmedInput.isEmpty) return;

    addOutput('>>> $trimmedInput', color: theme.promptColor);

    final parts = trimmedInput.split(' ');
    final commandName = parts[0];
    final args = parts.skip(1).toList();

    switch (commandName.toLowerCase()) {
      case 'exit':
        addOutput("Goodbye!", color: theme.promptColor);
        // In a real app, this might trigger app closing or navigating away
        // For a package, we just output the message.
        break;
      case 'clear':
        _history.clear();
        addOutput('Terminal cleared.', color: theme.defaultTextColor);
        notifyListeners();
        break;
      case 'help':
        _printHelp();
        break;
      default:
        // Try custom commands first
        if (_customCommands.containsKey(commandName)) {
          try {
            await _customCommands[commandName]!(trimmedInput, args, this);
          } catch (e, st) {
            addOutput('Error executing custom command "$commandName": $e', color: theme.errorColor);
            addOutput('Stack trace: $st', color: theme.hintColor);
          }
        }
        // Then try Python-like commands
        else if (!_pythonInterpreter.processPythonLikeInput(trimmedInput)) {
          addOutput('SyntaxError: Invalid or unsupported command: "$trimmedInput"', color: theme.errorColor);
          addOutput('Note: This fake terminal has limited capabilities.', color: theme.hintColor);
        }
        break;
    }
    _scrollToBottom(); // Always scroll after execution
  }

  /// Prints the help message specific to this terminal.
  void _printHelp() {
    addOutput("--- FakePyTerminal Commands ---", color: theme.hintColor);
    addOutput("help  : Display this help message.");
    addOutput("clear : Clear the terminal screen.");
    addOutput("exit  : Exits the terminal (stops app if root).");
    addOutput("");
    addOutput("--- Python Simulation (Basic) ---", color: theme.hintColor);
    addOutput("Variables: `x = 10`, `name = \"Dart\"`");
    addOutput("Print    : `print(\"Hello\")`, `print(x + 5)`");
    addOutput("Operations: `x + y`, `a - b`, `p * q`, `s / t` (basic)");
    addOutput("Functions: `len(\"hello\")`, `len(my_list)`");
    addOutput("Functions: `random.randint(1, 10)`");
    addOutput("");
    if (_customCommands.isNotEmpty) {
      addOutput("--- Custom Commands ---", color: theme.hintColor);
      _customCommands.keys.forEach((cmd) {
        addOutput("- $cmd", color: theme.hintColor);
      });
      addOutput("");
    }
    addOutput("Note: This is a highly simplified simulation. Complex Python features (loops, functions, classes, imports) are not fully supported.", color: theme.hintColor);
  }

  /// Scrolls the [ListView] to the bottom.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
