import 'package:args/command_runner.dart';

class HikariRunner extends CommandRunner {
  final void Function(String usage) printCallback;
  HikariRunner(
    String name,
    String description, {
    void Function(String usage)? printCallback,
  })  : printCallback = printCallback ?? print,
        super(name, description);

  @override
  void printUsage() => printCallback(usage);
}
