#!/usr/bin/env bash

coverage_dir=".coverage"

rm -fr $coverage_dir/
dart test --coverage=$coverage_dir/
dart run coverage:format_coverage --lcov --in=$coverage_dir --out=$coverage_dir/lcov.info --report-on=lib
genhtml $coverage_dir/lcov.info -o $coverage_dir/html
open $coverage_dir/html/index.html
