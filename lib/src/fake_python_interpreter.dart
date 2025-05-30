import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alpha_fake_python_simulation/src/terminal_controller.dart';

/// A simplified class to "interpret" Python-like commands.
/// It interacts with the TerminalController for scope and output.
class FakePythonInterpreter {
  final TerminalController _controller;
  final Random _random = Random();

  FakePythonInterpreter(this._controller);

  /// Attempts to process the given input as a Python-like command.
  /// Returns true if the command was recognized and handled, false otherwise.
  bool processPythonLikeInput(String input) {
    // Note: Order of checks matters here (e.g., assignment before expression evaluation)


    // 1. Variable Assignment (e.g., x = 10, name = "Alice", my_list = [1, 2, 3])
    RegExp assignRegex = RegExp(r'^(\w+)\s*=\s*(.+)$');
    if (assignRegex.hasMatch(input)) {
      Match match = assignRegex.firstMatch(input)!;
      String varName = match.group(1)!;
      String valueStr = match.group(2)!.trim();

      dynamic value;
      // Handle different literal types and variable assignment
      if (valueStr.startsWith('"') && valueStr.endsWith('"')) {
        value = valueStr.substring(1, valueStr.length - 1);
      } else if (valueStr.startsWith("'") && valueStr.endsWith("'")) {
        value = valueStr.substring(1, valueStr.length - 1);
      } else if (int.tryParse(valueStr) != null) {
        value = int.parse(valueStr);
      } else if (double.tryParse(valueStr) != null) {
        value = double.parse(valueStr);
      } else if (_controller.pythonScope.containsKey(valueStr)) {
        value = _controller.pythonScope[valueStr]; // Assigning value from another variable
      } else if (valueStr == 'True') {
        value = true;
      } else if (valueStr == 'False') {
        value = false;
      } else if (valueStr.startsWith('[') && valueStr.endsWith(']')) {
        // Basic list literal support
        String content = valueStr.substring(1, valueStr.length - 1).trim();
        value = content.split(',').map((e) => e.trim()).toList();
      } else {
        _controller.addOutput(
          'Error: Cannot assign "$valueStr" to variable "$varName". Unsupported type or syntax.',
          color: _controller.theme.errorColor,
        );
        return true; // Handled as an error
      }
      _controller.pythonScope[varName] = value;
      _controller.addOutput(
        'Variable "$varName" assigned to: ${value.toString()}',
        color: _controller.theme.resultColor,
      );
      return true;
    }

    // 2. print() statement (e.g., print("hello"), print(x), print(x + 5))
    RegExp printRegex = RegExp(r'^print\s*\((.*)\)$');
    if (printRegex.hasMatch(input)) {
      String content = printRegex.firstMatch(input)!.group(1)!.trim();
      List<String> itemsToPrint = content.split(',').map((s) => s.trim()).toList();
      String output = '';

      for (String item in itemsToPrint) {
        dynamic evaluatedValue = _evaluateExpression(item);
        if (evaluatedValue == null) {
          _controller.addOutput(
            "NameError: name '$item' is not defined",
            color: _controller.theme.errorColor,
          );
          return true; // Handled as an error
        } else if (evaluatedValue is String && evaluatedValue.startsWith("Error:")) {
          // Propagate explicit error messages from _evaluateExpression.
          _controller.addOutput(evaluatedValue.substring("Error: ".length), // Remove prefix for cleaner output
            color: _controller.theme.errorColor,
          );
          return true; // Handled as an error
        } else {
          output += evaluatedValue.toString() + ' ';
        }
      }
      _controller.addOutput(output.trim(), color: _controller.theme.defaultTextColor);
      return true;
    }

    // 3. len() function simulation (e.g., len("hello"), len(my_list))
    RegExp lenRegex = RegExp(r'^len\s*\((.*)\)$');
    if (lenRegex.hasMatch(input)) {
      String target = lenRegex.firstMatch(input)!.group(1)!.trim();
      dynamic evaluatedTarget = _evaluateExpression(target); // Evaluate argument if it's a variable or literal.
      
      if (evaluatedTarget is String) {
        _controller.addOutput(evaluatedTarget.length.toString(), color: _controller.theme.resultColor);
      } else if (evaluatedTarget is List) {
        _controller.addOutput(evaluatedTarget.length.toString(), color: _controller.theme.resultColor);
      } else if (evaluatedTarget == null) {
        _controller.addOutput(
          'NameError: name "$target" is not defined',
          color: _controller.theme.errorColor,
        );
      } else {
        _controller.addOutput(
          'TypeError: object of type "${_getPythonTypeName(evaluatedTarget)}" has no len()',
          color: _controller.theme.errorColor,
        );
      }
      return true;
    }

    // 4. random.randint(a, b) simulation
    RegExp randomIntRegex = RegExp(r'^random\.randint\s*\((\d+)\s*,\s*(\d+)\)$');
    if (randomIntRegex.hasMatch(input)) {
      Match? match = randomIntRegex.firstMatch(input);
      if (match != null && match.groupCount == 2) {
        int? min = int.tryParse(match.group(1)!);
        int? max = int.tryParse(match.group(2)!);
        if (min != null && max != null) {
          if (min > max) {
            _controller.addOutput(
              'ValueError: empty range for randint(${min}, ${max})',
              color: _controller.theme.errorColor,
            );
          } else {
            int randomNumber = min + _random.nextInt(max - min + 1);
            _controller.addOutput(randomNumber.toString(), color: _controller.theme.resultColor);
          }
          return true;
        }
      }
    }

    // 5. Direct expression evaluation (e.g., `2 + 3`, `x * 5`, `my_variable`)
    // Try to evaluate the entire input as an expression.
    dynamic result = _evaluateExpression(input);
    if (result != null) {
      if (result is String && result.startsWith("Error:")) {
        _controller.addOutput(result.substring("Error: ".length), // Remove prefix
          color: _controller.theme.errorColor,
        );
      } else if (result.toString().isNotEmpty) {
        _controller.addOutput(result.toString(), color: _controller.theme.resultColor);
      }
      return true; // Handled the expression
    }

    // If none of the above patterns matched, it's an unrecognized Python-like command.
    return false;
  }

  /// Evaluates a simple expression string (literal, variable, or single arithmetic op).
  /// Returns the evaluated value, or null if it cannot be evaluated.
  /// Returns an error string (starting with "Error:") for type errors/division by zero.
  dynamic _evaluateExpression(String expr) {
    expr = expr.trim();

    // 1. String literals
    if ((expr.startsWith('"') && expr.endsWith('"')) || (expr.startsWith("'") && expr.endsWith("'"))) {
      return expr.substring(1, expr.length - 1);
    }

    // 2. Numeric literals
    if (int.tryParse(expr) != null) {
      return int.parse(expr);
    }
    if (double.tryParse(expr) != null) {
      return double.parse(expr);
    }

    // 3. Boolean literals
    if (expr == 'True') return true;
    if (expr == 'False') return false;

    // 4. Variable lookup
    if (_controller.pythonScope.containsKey(expr)) {
      return _controller.pythonScope[expr];
    }

    // 5. Basic arithmetic (highly simplified: no order of operations, one op only)
    List<String> parts;
    String op = '';

    if (expr.contains('+')) {
      parts = expr.split('+');
      op = '+';
    } else if (expr.contains('-')) {
      parts = expr.split('-');
      op = '-';
    } else if (expr.contains('*')) {
      parts = expr.split('*');
      op = '*';
    } else if (expr.contains('/')) {
      parts = expr.split('/');
      op = '/';
    } else {
      return null; // Not a known literal, variable, or simple operation
    }

    if (parts.length == 2) {
      dynamic val1 = _evaluateOperand(parts[0].trim());
      dynamic val2 = _evaluateOperand(parts[1].trim());

      // Type checking and operation based on Python's behavior
      if (val1 is num && val2 is num) {
        switch (op) {
          case '+':
            return val1 + val2;
          case '-':
            return val1 - val2;
          case '*':
            return val1 * val2;
          case '/':
            if (val2 == 0) {
              return "Error: ZeroDivisionError: division by zero";
            }
            return val1 / val2; // Python's division is float division
        }
      } else if (val1 is String && op == '+') {
        // String concatenation with string or num (Python converts num to string)
        return val1 + (val2?.toString() ?? 'null'); // handle potential null from _evaluateOperand
      }
      return "Error: TypeError: unsupported operand type(s) for $op: '${_getPythonTypeName(val1)}' and '${_getPythonTypeName(val2)}'";
    }

    return null; // Fallback if expression couldn't be evaluated successfully
  }

  /// Helper to evaluate an individual operand within a larger expression.
  dynamic _evaluateOperand(String operand) {
    if ((operand.startsWith('"') && operand.endsWith('"')) || (operand.startsWith("'") && operand.endsWith("'"))) {
      return operand.substring(1, operand.length - 1);
    }
    if (int.tryParse(operand) != null) {
      return int.parse(operand);
    }
    if (double.tryParse(operand) != null) {
      return double.parse(operand);
    }
    if (operand == 'True') return true;
    if (operand == 'False') return false;

    if (_controller.pythonScope.containsKey(operand)) {
      return _controller.pythonScope[operand];
    }
    return null; // Not a simple literal or known variable
  }

  /// Returns a string representation of the "Python type" for a given Dart value.
  String _getPythonTypeName(dynamic value) {
    if (value == null) return 'NoneType';
    if (value is int) return 'int';
    if (value is double) return 'float';
    if (value is String) return 'str';
    if (value is List) return 'list';
    if (value is Map) return 'dict';
    if (value is bool) return 'bool';
    return value.runtimeType.toString().toLowerCase(); // Fallback for Dart types
  }
}
