// RUN: env CINDEXTEST_EDITING=1 c-index-test -test-annotate-tokens=%s:5:1:10:1 %s 2>&1 | FileCheck %s
// CHECK-NOT: error: unterminated conditional directive
// CHECK-NOT: Skipping: [4:1 - 8:7]
// CHECK: error: main file cannot be included recursively when building a preamble
#ifndef A_H
#define A_H
#  include "preamble-cyclic-include.cpp"
int bar();
#endif
