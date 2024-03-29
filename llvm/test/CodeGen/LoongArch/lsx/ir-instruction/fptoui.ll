; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 3
; RUN: llc --mtriple=loongarch64 --mattr=+lsx < %s | FileCheck %s

define void @fptoui_v4f32_v4i32(ptr %res, ptr %in){
; CHECK-LABEL: fptoui_v4f32_v4i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vld $vr0, $a1, 0
; CHECK-NEXT:    vftintrz.wu.s $vr0, $vr0
; CHECK-NEXT:    vst $vr0, $a0, 0
; CHECK-NEXT:    ret
  %v0 = load <4 x float>, ptr %in
  %v1 = fptoui <4 x float> %v0 to <4 x i32>
  store <4 x i32> %v1, ptr %res
  ret void
}

define void @fptoui_v2f64_v2i64(ptr %res, ptr %in){
; CHECK-LABEL: fptoui_v2f64_v2i64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vld $vr0, $a1, 0
; CHECK-NEXT:    vftintrz.lu.d $vr0, $vr0
; CHECK-NEXT:    vst $vr0, $a0, 0
; CHECK-NEXT:    ret
  %v0 = load <2 x double>, ptr %in
  %v1 = fptoui <2 x double> %v0 to <2 x i64>
  store <2 x i64> %v1, ptr %res
  ret void
}
