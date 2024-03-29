; RUN: opt -S -passes='require<profile-summary>,function(codegenprepare)' -mtriple=aarch64-linux %s | FileCheck -enable-var-scope %s

; Test for CodeGenPrepare::optimizeLoadExt(): simple case: two loads
; feeding a phi that zext's each loaded value.
define i32 @test_free_zext(ptr %ptr, ptr %ptr2, i32 %c) {
; CHECK-LABEL: @test_free_zext(
bb1:
; CHECK: bb1:
; CHECK: %[[T1:.*]] = load
; CHECK: %[[A1:.*]] = and i32 %[[T1]], 65535
  %load1 = load i32, ptr %ptr, align 4
  %cmp = icmp ne i32 %c, 0
  br i1 %cmp, label %bb2, label %bb3
bb2:
; CHECK: bb2:
; CHECK: %[[T2:.*]] = load
; CHECK: %[[A2:.*]] = and i32 %[[T2]], 65535
  %load2 = load i32, ptr %ptr2, align 4
  br label %bb3
bb3:
; CHECK: bb3:
; CHECK: phi i32 [ %[[A1]], %bb1 ], [ %[[A2]], %bb2 ]
  %phi = phi i32 [ %load1, %bb1 ], [ %load2, %bb2 ]
  %and = and i32 %phi, 65535
  ret i32 %and
}

; Test for CodeGenPrepare::optimizeLoadExt(): exercise all opcode
; cases of active bit calculation.
define i32 @test_free_zext2(ptr %ptr, ptr %dst16, ptr %dst32, i32 %c) {
; CHECK-LABEL: @test_free_zext2(
bb1:
; CHECK: bb1:
; CHECK: %[[T1:.*]] = load
; CHECK: %[[A1:.*]] = and i32 %[[T1]], 65535
  %load1 = load i32, ptr %ptr, align 4
  %cmp = icmp ne i32 %c, 0
  br i1 %cmp, label %bb2, label %bb4
bb2:
; CHECK: bb2:
  %trunc = trunc i32 %load1 to i16
  store i16 %trunc, ptr %dst16, align 2
  br i1 %cmp, label %bb3, label %bb4
bb3:
; CHECK: bb3:
  %shl = shl i32 %load1, 16
  store i32 %shl, ptr %dst32, align 4
  br label %bb4
bb4:
; CHECK: bb4:
; CHECK-NOT: and
; CHECK: ret i32 %[[A1]]
  %and = and i32 %load1, 65535
  ret i32 %and
}

; Test for CodeGenPrepare::optimizeLoadExt(): check case of zext-able
; load feeding a phi in the same block.
define void @test_free_zext3(ptr %ptr, ptr %ptr2, ptr %dst, ptr %c) {
; CHECK-LABEL: @test_free_zext3(
bb1:
; CHECK: bb1:
; CHECK: %[[T1:.*]] = load
; CHECK: %[[A1:.*]] = and i32 %[[T1]], 65535
  %load1 = load i32, ptr %ptr, align 4
  br label %loop
loop:
; CHECK: loop:
; CHECK: phi i32 [ %[[A1]], %bb1 ], [ %[[A2:.*]], %loop ]
  %phi = phi i32 [ %load1, %bb1 ], [ %load2, %loop ]
  %and = and i32 %phi, 65535
  store i32 %and, ptr %dst, align 4
  %idx = load volatile i64, ptr %c, align 4
  %addr = getelementptr inbounds i32, ptr %ptr2, i64 %idx
; CHECK: %[[T2:.*]] = load i32
; CHECK: %[[A2]] = and i32 %[[T2]], 65535
  %load2 = load i32, ptr %addr, align 4
  %cmp = icmp ne i64 %idx, 0
  br i1 %cmp, label %loop, label %end
end:
  ret void
}
