; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; RUN:  llc -amdgpu-scalarize-global-loads=false  -mtriple=r600 -mcpu=redwood < %s | FileCheck -check-prefix=R600 %s

; Run with unsafe-fp-math to make sure nothing tries to turn this into 1 / rsqrt(x)

define amdgpu_kernel void @v_safe_fsqrt_f32(ptr addrspace(1) %out, ptr addrspace(1) %in) {
; R600-LABEL: v_safe_fsqrt_f32:
; R600:       ; %bb.0:
; R600-NEXT:    ALU 0, @8, KC0[CB0:0-32], KC1[]
; R600-NEXT:    TEX 0 @6
; R600-NEXT:    ALU 3, @9, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    Fetch clause starting at 6:
; R600-NEXT:     VTX_READ_32 T0.X, T0.X, 0, #1
; R600-NEXT:    ALU clause starting at 8:
; R600-NEXT:     MOV * T0.X, KC0[2].Z,
; R600-NEXT:    ALU clause starting at 9:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, T0.X,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
  %r0 = load float, ptr addrspace(1) %in
  %r1 = call float @llvm.sqrt.f32(float %r0)
  store float %r1, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @v_unsafe_fsqrt_f32(ptr addrspace(1) %out, ptr addrspace(1) %in) #1 {
; R600-LABEL: v_unsafe_fsqrt_f32:
; R600:       ; %bb.0:
; R600-NEXT:    ALU 0, @8, KC0[CB0:0-32], KC1[]
; R600-NEXT:    TEX 0 @6
; R600-NEXT:    ALU 3, @9, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    Fetch clause starting at 6:
; R600-NEXT:     VTX_READ_32 T0.X, T0.X, 0, #1
; R600-NEXT:    ALU clause starting at 8:
; R600-NEXT:     MOV * T0.X, KC0[2].Z,
; R600-NEXT:    ALU clause starting at 9:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, T0.X,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
  %r0 = load float, ptr addrspace(1) %in
  %r1 = call float @llvm.sqrt.f32(float %r0)
  store float %r1, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @s_sqrt_f32(ptr addrspace(1) %out, float %in) {
; R600-LABEL: s_sqrt_f32:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 3, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].Z,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %fdiv = call float @llvm.sqrt.f32(float %in)
  store float %fdiv, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @s_sqrt_v2f32(ptr addrspace(1) %out, <2 x float> %in) {
; R600-LABEL: s_sqrt_v2f32:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 5, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.XY, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].W,
; R600-NEXT:     RECIPSQRT_IEEE * T0.Y, KC0[3].X,
; R600-NEXT:     RECIP_IEEE * T0.Y, PS,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, T0.X,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %fdiv = call <2 x float> @llvm.sqrt.v2f32(<2 x float> %in)
  store <2 x float> %fdiv, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @s_sqrt_v4f32(ptr addrspace(1) %out, <4 x float> %in) {
; R600-LABEL: s_sqrt_v4f32:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 9, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.XYZW, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[3].Y,
; R600-NEXT:     RECIPSQRT_IEEE * T0.Y, KC0[3].Z,
; R600-NEXT:     RECIPSQRT_IEEE * T0.Z, KC0[3].W,
; R600-NEXT:     RECIPSQRT_IEEE * T0.W, KC0[4].X,
; R600-NEXT:     RECIP_IEEE * T0.W, PS,
; R600-NEXT:     RECIP_IEEE * T0.Z, T0.Z,
; R600-NEXT:     RECIP_IEEE * T0.Y, T0.Y,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, T0.X,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %fdiv = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %in)
  store <4 x float> %fdiv, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @elim_redun_check_neg0(ptr addrspace(1) %out, float %in) {
; R600-LABEL: elim_redun_check_neg0:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 3, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].Z,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %sqrt = call float @llvm.sqrt.f32(float %in)
  %cmp = fcmp olt float %in, -0.000000e+00
  %res = select i1 %cmp, float 0x7FF8000000000000, float %sqrt
  store float %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @elim_redun_check_pos0(ptr addrspace(1) %out, float %in) {
; R600-LABEL: elim_redun_check_pos0:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 3, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].Z,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %sqrt = call float @llvm.sqrt.f32(float %in)
  %cmp = fcmp olt float %in, 0.000000e+00
  %res = select i1 %cmp, float 0x7FF8000000000000, float %sqrt
  store float %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @elim_redun_check_ult(ptr addrspace(1) %out, float %in) {
; R600-LABEL: elim_redun_check_ult:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 3, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.X, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].Z,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, PS,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %sqrt = call float @llvm.sqrt.f32(float %in)
  %cmp = fcmp ult float %in, -0.000000e+00
  %res = select i1 %cmp, float 0x7FF8000000000000, float %sqrt
  store float %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @elim_redun_check_v2(ptr addrspace(1) %out, <2 x float> %in) {
; R600-LABEL: elim_redun_check_v2:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 5, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.XY, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].W,
; R600-NEXT:     RECIPSQRT_IEEE * T0.Y, KC0[3].X,
; R600-NEXT:     RECIP_IEEE * T0.Y, PS,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, T0.X,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %sqrt = call <2 x float> @llvm.sqrt.v2f32(<2 x float> %in)
  %cmp = fcmp olt <2 x float> %in, <float -0.000000e+00, float -0.000000e+00>
  %res = select <2 x i1> %cmp, <2 x float> <float 0x7FF8000000000000, float 0x7FF8000000000000>, <2 x float> %sqrt
  store <2 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @elim_redun_check_v2_ult(ptr addrspace(1) %out, <2 x float> %in) {
; R600-LABEL: elim_redun_check_v2_ult:
; R600:       ; %bb.0: ; %entry
; R600-NEXT:    ALU 5, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T0.XY, T1.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     RECIPSQRT_IEEE * T0.X, KC0[2].W,
; R600-NEXT:     RECIPSQRT_IEEE * T0.Y, KC0[3].X,
; R600-NEXT:     RECIP_IEEE * T0.Y, PS,
; R600-NEXT:     LSHR T1.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIP_IEEE * T0.X, T0.X,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
entry:
  %sqrt = call <2 x float> @llvm.sqrt.v2f32(<2 x float> %in)
  %cmp = fcmp ult <2 x float> %in, <float -0.000000e+00, float -0.000000e+00>
  %res = select <2 x i1> %cmp, <2 x float> <float 0x7FF8000000000000, float 0x7FF8000000000000>, <2 x float> %sqrt
  store <2 x float> %res, ptr addrspace(1) %out
  ret void
}

define amdgpu_kernel void @recip_sqrt(ptr addrspace(1) %out, float %src) nounwind {
; R600-LABEL: recip_sqrt:
; R600:       ; %bb.0:
; R600-NEXT:    ALU 2, @4, KC0[CB0:0-32], KC1[]
; R600-NEXT:    MEM_RAT_CACHELESS STORE_RAW T1.X, T0.X, 1
; R600-NEXT:    CF_END
; R600-NEXT:    PAD
; R600-NEXT:    ALU clause starting at 4:
; R600-NEXT:     LSHR T0.X, KC0[2].Y, literal.x,
; R600-NEXT:     RECIPSQRT_IEEE * T1.X, KC0[2].Z,
; R600-NEXT:    2(2.802597e-45), 0(0.000000e+00)
  %sqrt = call float @llvm.sqrt.f32(float %src)
  %recipsqrt = fdiv fast float 1.0, %sqrt
  store float %recipsqrt, ptr addrspace(1) %out, align 4
  ret void
}

declare float @llvm.sqrt.f32(float %in) #0
declare <2 x float> @llvm.sqrt.v2f32(<2 x float> %in) #0
declare <4 x float> @llvm.sqrt.v4f32(<4 x float> %in) #0

attributes #0 = { nounwind readnone }
attributes #1 = { nounwind "unsafe-fp-math"="true" }
