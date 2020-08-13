extension CheckNotNull on String {
  bool get isNotBlank => this?.isNotEmpty ?? false;
}
