<p align="center">
  <img src="https://raw.githubusercontent.com/Alpha-Kraft/alpha_fake_python_terminal/master/assets/icon.png" width="200" alt="Alpha Fake Python Simulation Logo">
</p>

# Alpha Fake Python Simulation

A Flutter package that provides a customizable, interactive terminal interface with Python-like syntax support.

![Version](https://img.shields.io/badge/Version-0.1.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Demo

### Built-in Help Command
![Help Command Demo](https://raw.githubusercontent.com/Alpha-Kraft/alpha_fake_python_terminal/master/assets/help-command.gif)

### Custom Commands
![Custom Command Demo](https://raw.githubusercontent.com/Alpha-Kraft/alpha_fake_python_terminal/master/assets/custom-command.gif)

### Clear Command
![Clear Command Demo](https://raw.githubusercontent.com/Alpha-Kraft/alpha_fake_python_terminal/master/assets/clear.gif)

This package allows you to create an interactive coding environment within your Flutter app where users can execute Python-like commands and see the results in real-time.

## Features

- Interactive terminal interface with syntax highlighting
- Support for basic Python-like syntax including:
  - Variable assignment and arithmetic operations
  - `print()` function
  - `len()` function for strings and lists
  - `random.randint()` function
- Custom command support
- Theming support
- Scrollable history
- Built-in help system

## Getting Started

### Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  alpha_fake_python_simulation: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/alpha_fake_python_simulation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Python Terminal',
      theme: ThemeData.dark(),
      home: TerminalScreen(
        controller: TerminalController(),
      ),
    );
  }
}
```

### Custom Commands

You can add custom commands to extend the terminal's functionality:

```dart
final controller = TerminalController(
  theme: TerminalTheme.defaultDark,
  customCommands: {
    'greet': (command, args, controller) async {
      final name = args.isNotEmpty ? args.join(' ') : 'World';
      controller.addOutput('Hello, $name!', color: controller.theme.promptColor);
    },
  },
);
```

### Custom Theme

Customize the appearance of the terminal:

```dart
final controller = TerminalController(
  theme: TerminalTheme(
    backgroundColor: Colors.black,
    promptColor: Colors.lightGreenAccent,
    defaultTextColor: Colors.white,
    resultColor: Colors.blueAccent,
    errorColor: Colors.redAccent,
    hintColor: Colors.grey,
    defaultFontSize: 14.0,
    promptFontSize: 16.0,
  ),
);
```

## Example

Check out the `example` directory for a complete example app that demonstrates the package's features.

## Features and Limitations

### Supported Python-like Features
- Variable assignment: `x = 10`, `name = "Alice"`
- Basic arithmetic: `2 + 3 * 4`, `(5 + 3) / 2`
- `print()` function: `print("Hello, World!")`, `print(x + 5)`
- `len()` function: `len("hello")`, `len(my_list)`
- `random.randint()`: `random.randint(1, 10)`
- Basic list support: `my_list = [1, 2, 3]`

### Limitations
- No support for loops, conditionals, or functions
- No support for imports or modules
- Limited error handling
- Basic type system


## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- **Owner**: [Alpha Kraft](https://github.com/Alpha-Kraft)
- **Developer**: Arunesh Kishore

## Support

If you find this package useful, consider giving it a ⭐ on [GitHub](https://github.com/Alpha-Kraft/alpha_fake_python_terminal).
