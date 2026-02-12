import 'dart:io';

void main() {
  stdout.writeln("Python 3.10.7 (main, Dec 23 2025, 00:01:57) [GCC 11.2.0] on linux");
  stdout.writeln('Type "help", "copyright", "credits" or "license" for more information.');

  while (true) {
    stdout.write('>>> ');
    String? input = stdin.readLineSync();

    if (input == null) {
      break;
    }

    if (input.trim() == 'exit()' || input.trim() == 'quit()') {
      break;
    }

    // Fake execution: do nothing
  }
}
