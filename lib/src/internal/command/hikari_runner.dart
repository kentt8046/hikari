import 'package:args/command_runner.dart';

class HikariRunner extends CommandRunner {
  final void Function(String usage) printCallback;
  HikariRunner(
    super.name,
    super.description, {
    void Function(String usage)? printCallback,
  }) : printCallback = printCallback ?? print;

  @override
  void printUsage() => printCallback(usage);
}
