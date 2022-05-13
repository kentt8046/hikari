import 'dart:io';

import 'package:yaml/yaml.dart' as yaml;

class AppInfo {
  static AppInfo? _instance;

  final bool compiled;
  final String name;
  final String description;
  final String version;
  final DateTime buildDate;
  final String commitHash;
  final Directory? projectDir;

  List<String> get defines {
    return [
      "-Dhikari.appinfo.compiled=true",
      "-Dhikari.appinfo.name=$name",
      "-Dhikari.appinfo.description=$description",
      "-Dhikari.appinfo.version=$version",
      "-Dhikari.appinfo.buildDate=${buildDate.toUtc().toIso8601String()}",
      "-Dhikari.appinfo.commitHash=$commitHash",
    ];
  }

  factory AppInfo() => _instance ??= AppInfo.init();

  factory AppInfo.init() {
    final compiled = const bool.fromEnvironment("hikari.appinfo.compiled");
    var name = const String.fromEnvironment("hikari.appinfo.name");
    var description =
        const String.fromEnvironment("hikari.appinfo.description");
    var version = const String.fromEnvironment("hikari.appinfo.version");
    final buildDateString =
        const String.fromEnvironment("hikari.appinfo.buildDate");
    var commitHash = const String.fromEnvironment("hikari.appinfo.commitHash");
    var buildDate = DateTime.tryParse(buildDateString)?.toLocal();
    Directory? projectDir;

    if (!compiled) {
      projectDir ??= Directory.fromUri(Platform.script);
      final file = findPubSpec(projectDir.uri);
      if (file != null) {
        projectDir = Directory.fromUri(file.uri.resolve("."));
        final yaml.YamlMap pub = yaml.loadYaml(file.readAsStringSync());

        name = pub["name"];
        description = pub["description"];
        version = "${pub["version"]}";
      }

      buildDate = DateTime.now();
      try {
        commitHash = Process.runSync("git", ["rev-parse", "--short", "HEAD"])
            .stdout
            .trim();
      } catch (_) {}
    }

    return AppInfo._(
      compiled,
      name,
      description,
      version,
      buildDate!,
      commitHash,
      projectDir,
    );
  }

  AppInfo._(
    this.compiled,
    this.name,
    this.description,
    this.version,
    this.buildDate,
    this.commitHash,
    this.projectDir,
  );

  static File? findPubSpec(Uri uri) {
    final file = File.fromUri(Directory.current.uri.resolve("pubspec.yaml"));
    if (file.existsSync()) return file;
    return null;
  }
}
