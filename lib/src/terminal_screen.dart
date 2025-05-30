import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alpha_fake_python_simulation/src/terminal_controller.dart';

/// A customizable Flutter widget that provides a fake terminal coding experience.
class TerminalScreen extends StatefulWidget {
  /// The controller for managing terminal state and logic.
  final TerminalController controller;

  /// Creates a [TerminalScreen] widget.
  ///
  /// A [TerminalController] must be provided to manage the terminal's state.
  const TerminalScreen({
    super.key,
    required this.controller,
  });

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.init(); // Initialize the controller when the screen mounts
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using ChangeNotifierProvider.value to use an externally provided controller
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Builder(
        builder: (context) {
          final terminalController = context.watch<TerminalController>();
          final theme = terminalController.theme;

          return Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              title: const Text('FakePyTerminal', style: TextStyle(color: Colors.white)),
              centerTitle: true,
              backgroundColor: theme.backgroundColor,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  // Terminal Output Area
                  Expanded(
                    child: ListView.builder(
                      controller: terminalController.scrollController,
                      itemCount: terminalController.history.length,
                      itemBuilder: (context, index) {
                        final line = terminalController.history[index];
                        return SelectableText(
                          line.text,
                          style: TextStyle(color: line.color, fontSize: theme.defaultFontSize),
                        );
                      },
                    ),
                  ),
                  // Separator line
                  const Divider(color: Colors.white10, height: 20, thickness: 1),
                  // Terminal Input Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '>>> ',
                        style: TextStyle(color: theme.promptColor, fontSize: theme.promptFontSize),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          onSubmitted: (value) async {
                            await terminalController.executeCommand(value);
                            _inputController.clear();
                          },
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          cursorColor: theme.promptColor,
                          style: TextStyle(color: theme.defaultTextColor, fontSize: theme.promptFontSize),
                          decoration: const InputDecoration(
                            border: InputBorder.none, // No border for the input field
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
