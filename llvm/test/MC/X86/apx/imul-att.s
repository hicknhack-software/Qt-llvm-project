# RUN: llvm-mc -triple x86_64 -show-encoding %s | FileCheck %s
# RUN: not llvm-mc -triple i386 -show-encoding %s 2>&1 | FileCheck %s --check-prefix=ERROR

# ERROR-COUNT-64: error:
# ERROR-NOT: error:
# CHECK: {evex}	imulw	$123, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0x6b,0xd2,0x7b]
         {evex}	imulw	$123, %dx, %dx
# CHECK: {nf}	imulw	$123, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x0c,0x6b,0xd2,0x7b]
         {nf}	imulw	$123, %dx, %dx
# CHECK: {evex}	imull	$123, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0x6b,0xc9,0x7b]
         {evex}	imull	$123, %ecx, %ecx
# CHECK: {nf}	imull	$123, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x0c,0x6b,0xc9,0x7b]
         {nf}	imull	$123, %ecx, %ecx
# CHECK: {evex}	imulq	$123, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0x6b,0xc9,0x7b]
         {evex}	imulq	$123, %r9, %r9
# CHECK: {nf}	imulq	$123, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0x6b,0xc9,0x7b]
         {nf}	imulq	$123, %r9, %r9
# CHECK: {evex}	imulw	$123, 291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x08,0x6b,0x94,0x80,0x23,0x01,0x00,0x00,0x7b]
         {evex}	imulw	$123, 291(%r8,%rax,4), %dx
# CHECK: {nf}	imulw	$123, 291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x0c,0x6b,0x94,0x80,0x23,0x01,0x00,0x00,0x7b]
         {nf}	imulw	$123, 291(%r8,%rax,4), %dx
# CHECK: {evex}	imull	$123, 291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x08,0x6b,0x8c,0x80,0x23,0x01,0x00,0x00,0x7b]
         {evex}	imull	$123, 291(%r8,%rax,4), %ecx
# CHECK: {nf}	imull	$123, 291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x0c,0x6b,0x8c,0x80,0x23,0x01,0x00,0x00,0x7b]
         {nf}	imull	$123, 291(%r8,%rax,4), %ecx
# CHECK: {evex}	imulq	$123, 291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0x6b,0x8c,0x80,0x23,0x01,0x00,0x00,0x7b]
         {evex}	imulq	$123, 291(%r8,%rax,4), %r9
# CHECK: {nf}	imulq	$123, 291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0x6b,0x8c,0x80,0x23,0x01,0x00,0x00,0x7b]
         {nf}	imulq	$123, 291(%r8,%rax,4), %r9
# CHECK: {evex}	imulw	$1234, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0x69,0xd2,0xd2,0x04]
         {evex}	imulw	$1234, %dx, %dx
# CHECK: {nf}	imulw	$1234, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x0c,0x69,0xd2,0xd2,0x04]
         {nf}	imulw	$1234, %dx, %dx
# CHECK: {evex}	imulw	$1234, 291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x08,0x69,0x94,0x80,0x23,0x01,0x00,0x00,0xd2,0x04]
         {evex}	imulw	$1234, 291(%r8,%rax,4), %dx
# CHECK: {nf}	imulw	$1234, 291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x0c,0x69,0x94,0x80,0x23,0x01,0x00,0x00,0xd2,0x04]
         {nf}	imulw	$1234, 291(%r8,%rax,4), %dx
# CHECK: {evex}	imull	$123456, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0x69,0xc9,0x40,0xe2,0x01,0x00]
         {evex}	imull	$123456, %ecx, %ecx
# CHECK: {nf}	imull	$123456, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x0c,0x69,0xc9,0x40,0xe2,0x01,0x00]
         {nf}	imull	$123456, %ecx, %ecx
# CHECK: {evex}	imulq	$123456, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0x69,0xc9,0x40,0xe2,0x01,0x00]
         {evex}	imulq	$123456, %r9, %r9
# CHECK: {nf}	imulq	$123456, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0x69,0xc9,0x40,0xe2,0x01,0x00]
         {nf}	imulq	$123456, %r9, %r9
# CHECK: {evex}	imull	$123456, 291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x08,0x69,0x8c,0x80,0x23,0x01,0x00,0x00,0x40,0xe2,0x01,0x00]
         {evex}	imull	$123456, 291(%r8,%rax,4), %ecx
# CHECK: {nf}	imull	$123456, 291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x0c,0x69,0x8c,0x80,0x23,0x01,0x00,0x00,0x40,0xe2,0x01,0x00]
         {nf}	imull	$123456, 291(%r8,%rax,4), %ecx
# CHECK: {evex}	imulq	$123456, 291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0x69,0x8c,0x80,0x23,0x01,0x00,0x00,0x40,0xe2,0x01,0x00]
         {evex}	imulq	$123456, 291(%r8,%rax,4), %r9
# CHECK: {nf}	imulq	$123456, 291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0x69,0x8c,0x80,0x23,0x01,0x00,0x00,0x40,0xe2,0x01,0x00]
         {nf}	imulq	$123456, 291(%r8,%rax,4), %r9
# CHECK: {evex}	imulb	%bl
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xf6,0xeb]
         {evex}	imulb	%bl
# CHECK: {nf}	imulb	%bl
# CHECK: encoding: [0x62,0xf4,0x7c,0x0c,0xf6,0xeb]
         {nf}	imulb	%bl
# CHECK: {evex}	imulw	%dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0xf7,0xea]
         {evex}	imulw	%dx
# CHECK: {nf}	imulw	%dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x0c,0xf7,0xea]
         {nf}	imulw	%dx
# CHECK: {evex}	imulw	%dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0xaf,0xd2]
         {evex}	imulw	%dx, %dx
# CHECK: {nf}	imulw	%dx, %dx
# CHECK: encoding: [0x62,0xf4,0x7d,0x0c,0xaf,0xd2]
         {nf}	imulw	%dx, %dx
# CHECK: imulw	%dx, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x6d,0x18,0xaf,0xd2]
         imulw	%dx, %dx, %dx
# CHECK: {nf}	imulw	%dx, %dx, %dx
# CHECK: encoding: [0x62,0xf4,0x6d,0x1c,0xaf,0xd2]
         {nf}	imulw	%dx, %dx, %dx
# CHECK: {evex}	imull	%ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xf7,0xe9]
         {evex}	imull	%ecx
# CHECK: {nf}	imull	%ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x0c,0xf7,0xe9]
         {nf}	imull	%ecx
# CHECK: {evex}	imull	%ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xaf,0xc9]
         {evex}	imull	%ecx, %ecx
# CHECK: {nf}	imull	%ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x0c,0xaf,0xc9]
         {nf}	imull	%ecx, %ecx
# CHECK: imull	%ecx, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x74,0x18,0xaf,0xc9]
         imull	%ecx, %ecx, %ecx
# CHECK: {nf}	imull	%ecx, %ecx, %ecx
# CHECK: encoding: [0x62,0xf4,0x74,0x1c,0xaf,0xc9]
         {nf}	imull	%ecx, %ecx, %ecx
# CHECK: {evex}	imulq	%r9
# CHECK: encoding: [0x62,0xd4,0xfc,0x08,0xf7,0xe9]
         {evex}	imulq	%r9
# CHECK: {nf}	imulq	%r9
# CHECK: encoding: [0x62,0xd4,0xfc,0x0c,0xf7,0xe9]
         {nf}	imulq	%r9
# CHECK: {evex}	imulq	%r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0xaf,0xc9]
         {evex}	imulq	%r9, %r9
# CHECK: {nf}	imulq	%r9, %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0xaf,0xc9]
         {nf}	imulq	%r9, %r9
# CHECK: imulq	%r9, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xb4,0x18,0xaf,0xc9]
         imulq	%r9, %r9, %r9
# CHECK: {nf}	imulq	%r9, %r9, %r9
# CHECK: encoding: [0x62,0x54,0xb4,0x1c,0xaf,0xc9]
         {nf}	imulq	%r9, %r9, %r9
# CHECK: {evex}	imulb	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7c,0x08,0xf6,0xac,0x80,0x23,0x01,0x00,0x00]
         {evex}	imulb	291(%r8,%rax,4)
# CHECK: {nf}	imulb	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7c,0x0c,0xf6,0xac,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulb	291(%r8,%rax,4)
# CHECK: {evex}	imulw	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7d,0x08,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {evex}	imulw	291(%r8,%rax,4)
# CHECK: {nf}	imulw	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7d,0x0c,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulw	291(%r8,%rax,4)
# CHECK: {evex}	imulw	291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x08,0xaf,0x94,0x80,0x23,0x01,0x00,0x00]
         {evex}	imulw	291(%r8,%rax,4), %dx
# CHECK: {nf}	imulw	291(%r8,%rax,4), %dx
# CHECK: encoding: [0x62,0xd4,0x7d,0x0c,0xaf,0x94,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulw	291(%r8,%rax,4), %dx
# CHECK: imulw	291(%r8,%rax,4), %dx, %dx
# CHECK: encoding: [0x62,0xd4,0x6d,0x18,0xaf,0x94,0x80,0x23,0x01,0x00,0x00]
         imulw	291(%r8,%rax,4), %dx, %dx
# CHECK: {nf}	imulw	291(%r8,%rax,4), %dx, %dx
# CHECK: encoding: [0x62,0xd4,0x6d,0x1c,0xaf,0x94,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulw	291(%r8,%rax,4), %dx, %dx
# CHECK: {evex}	imull	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7c,0x08,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {evex}	imull	291(%r8,%rax,4)
# CHECK: {nf}	imull	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0x7c,0x0c,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {nf}	imull	291(%r8,%rax,4)
# CHECK: {evex}	imull	291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x08,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {evex}	imull	291(%r8,%rax,4), %ecx
# CHECK: {nf}	imull	291(%r8,%rax,4), %ecx
# CHECK: encoding: [0x62,0xd4,0x7c,0x0c,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {nf}	imull	291(%r8,%rax,4), %ecx
# CHECK: imull	291(%r8,%rax,4), %ecx, %ecx
# CHECK: encoding: [0x62,0xd4,0x74,0x18,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         imull	291(%r8,%rax,4), %ecx, %ecx
# CHECK: {nf}	imull	291(%r8,%rax,4), %ecx, %ecx
# CHECK: encoding: [0x62,0xd4,0x74,0x1c,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {nf}	imull	291(%r8,%rax,4), %ecx, %ecx
# CHECK: {evex}	imulq	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0xfc,0x08,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {evex}	imulq	291(%r8,%rax,4)
# CHECK: {nf}	imulq	291(%r8,%rax,4)
# CHECK: encoding: [0x62,0xd4,0xfc,0x0c,0xf7,0xac,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulq	291(%r8,%rax,4)
# CHECK: {evex}	imulq	291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x08,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {evex}	imulq	291(%r8,%rax,4), %r9
# CHECK: {nf}	imulq	291(%r8,%rax,4), %r9
# CHECK: encoding: [0x62,0x54,0xfc,0x0c,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulq	291(%r8,%rax,4), %r9
# CHECK: imulq	291(%r8,%rax,4), %r9, %r9
# CHECK: encoding: [0x62,0x54,0xb4,0x18,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         imulq	291(%r8,%rax,4), %r9, %r9
# CHECK: {nf}	imulq	291(%r8,%rax,4), %r9, %r9
# CHECK: encoding: [0x62,0x54,0xb4,0x1c,0xaf,0x8c,0x80,0x23,0x01,0x00,0x00]
         {nf}	imulq	291(%r8,%rax,4), %r9, %r9
