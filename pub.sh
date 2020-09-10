#!/usr/bin/env bash


if [ $# == 1 ]; then
  PARAM=$1
else
  PARAM='dev'
fi

case $PARAM in
dev|develop)
  dartfmt -w .
  # flutter packages pub publish --dry-run
  pub publish --dry-run
  ;;
rel|release)
  # flutter packages pub publish --server=https://pub.dartlang.org
  export PUB_HOSTED_URL=https://pub.dev FLUTTER_STORAGE_BASE_URL=https://storage.pub.dev
  pub publish
  ;;
esac
