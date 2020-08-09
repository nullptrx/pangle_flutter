#!/usr/bin/env bash

dartfmt -w .

flutter packages pub publish  --server=https://pub.dartlang.org --dry-run