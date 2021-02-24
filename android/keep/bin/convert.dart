import 'dart:io';

import 'package:args/args.dart';

const kData = '''
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="##" />
''';

void main(List<String> arguments) {
  var parser = ArgParser();
  parser.addSeparator('Usage:');
  parser.addFlag('help',
      abbr: 'h', negatable: false, defaultsTo: false, help: 'show doc');
  parser.addOption('input',
      abbr: 'i', help: 'input file', defaultsTo: 'whiteList.txt');
  parser.addOption('output',
      abbr: 'o', help: 'output file', defaultsTo: 'pangle_flutter_keep.xml');

  final args = parser.parse(arguments);
  var help = args.wasParsed('help');
  if (help) {
    print(parser.usage);
    return;
  }

  final intputFileName = args['input'];
  final outputFileName = args['output'];

  print('Reading whiteList.txt...');
  var lines = File(intputFileName).readAsLinesSync();

  final resources = <String>[];
  for (var line in lines) {
    final data = line.replaceFirst('R.', '@').replaceFirst('.', '/');
    final result = data.replaceAll('"', '').trim();
    resources.add(result);
  }
  final xml = kData.replaceAll('##', resources.join(','));
  var file = File(outputFileName);
  if (file.existsSync()) {
    file.deleteSync();
  }

  file.writeAsStringSync(xml);

  print('Done');
}
