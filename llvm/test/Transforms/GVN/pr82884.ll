; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt -S -passes=gvn < %s | FileCheck %s

; Make sure nsw/nuw flags are dropped.

define i32 @pr82884(i32 %x) {
; CHECK-LABEL: define i32 @pr82884(
; CHECK-SAME: i32 [[X:%.*]]) {
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[X]], [[X]]
; CHECK-NEXT:    call void @use(i32 [[MUL]])
; CHECK-NEXT:    [[MUL2:%.*]] = call { i32, i1 } @llvm.smul.with.overflow.i32(i32 [[X]], i32 [[X]])
; CHECK-NEXT:    ret i32 [[MUL]]
;
  %mul = mul nsw nuw i32 %x, %x
  call void @use(i32 %mul)
  %mul2 = call { i32, i1 } @llvm.smul.with.overflow.i32(i32 %x, i32 %x)
  %ret = extractvalue { i32, i1 } %mul2, 0
  ret i32 %ret
}

declare void @use(i32)
