import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(),
);
final loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);
