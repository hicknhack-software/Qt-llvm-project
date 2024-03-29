# RUN: llvm-mc -triple x86_64 --show-encoding %s | FileCheck %s
# RUN: not llvm-mc -triple i386 -show-encoding %s 2>&1 | FileCheck %s --check-prefix=ERROR

# ERROR-COUNT-22: error:
# ERROR-NOT: error:
# CHECK: {evex}	crc32b	%al, %ebx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xf0,0xd8]
         {evex}	crc32b	%al, %ebx

# CHECK: {evex}	crc32b	%al, %rbx
# CHECK: encoding: [0x62,0xf4,0xfc,0x08,0xf0,0xd8]
         {evex}	crc32b	%al, %rbx

# CHECK: {evex}	crc32w	%ax, %ebx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0xf1,0xd8]
         {evex}	crc32w	%ax, %ebx

# CHECK: {evex}	crc32l	%eax, %ebx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xf1,0xd8]
         {evex}	crc32l	%eax, %ebx

# CHECK: {evex}	crc32q	%rax, %rbx
# CHECK: encoding: [0x62,0xf4,0xfc,0x08,0xf1,0xd8]
         {evex}	crc32q	%rax, %rbx

# CHECK: {evex}	crc32w	291(%rax,%rbx,4), %ecx
# CHECK: encoding: [0x62,0xf4,0x7d,0x08,0xf1,0x8c,0x98,0x23,0x01,0x00,0x00]
         {evex}	crc32w	291(%rax,%rbx,4), %ecx

# CHECK: {evex}	crc32l	291(%rax,%rbx,4), %ecx
# CHECK: encoding: [0x62,0xf4,0x7c,0x08,0xf1,0x8c,0x98,0x23,0x01,0x00,0x00]
         {evex}	crc32l	291(%rax,%rbx,4), %ecx

# CHECK: {evex}	crc32b	291(%rax,%rbx,4), %rcx
# CHECK: encoding: [0x62,0xf4,0xfc,0x08,0xf0,0x8c,0x98,0x23,0x01,0x00,0x00]
         {evex}	crc32b	291(%rax,%rbx,4), %rcx

# CHECK: {evex}	crc32q	291(%rax,%rbx,4), %rcx
# CHECK: encoding: [0x62,0xf4,0xfc,0x08,0xf1,0x8c,0x98,0x23,0x01,0x00,0x00]
         {evex}	crc32q	291(%rax,%rbx,4), %rcx

# CHECK: crc32b	%r16b, %r22d
# CHECK: encoding: [0x62,0xec,0x7c,0x08,0xf0,0xf0]
         crc32b	%r16b, %r22d

# CHECK: crc32b	%r16b, %r23
# CHECK: encoding: [0x62,0xec,0xfc,0x08,0xf0,0xf8]
         crc32b	%r16b, %r23

# CHECK: crc32w	%r17w, %r22d
# CHECK: encoding: [0x62,0xec,0x7d,0x08,0xf1,0xf1]
         crc32w	%r17w, %r22d

# CHECK: crc32l	%r18d, %r22d
# CHECK: encoding: [0x62,0xec,0x7c,0x08,0xf1,0xf2]
         crc32l	%r18d, %r22d

# CHECK: crc32q	%r19, %r23
# CHECK: encoding: [0x62,0xec,0xfc,0x08,0xf1,0xfb]
         crc32q	%r19, %r23

# CHECK: crc32w	291(%r28,%r29,4), %r18d
# CHECK: encoding: [0x62,0x8c,0x79,0x08,0xf1,0x94,0xac,0x23,0x01,0x00,0x00]
         crc32w	291(%r28,%r29,4), %r18d

# CHECK: crc32l	291(%r28,%r29,4), %r18d
# CHECK: encoding: [0x62,0x8c,0x78,0x08,0xf1,0x94,0xac,0x23,0x01,0x00,0x00]
         crc32l	291(%r28,%r29,4), %r18d

# CHECK: crc32b	291(%r28,%r29,4), %r19
# CHECK: encoding: [0x62,0x8c,0xf8,0x08,0xf0,0x9c,0xac,0x23,0x01,0x00,0x00]
         crc32b	291(%r28,%r29,4), %r19

# CHECK: crc32q	291(%r28,%r29,4), %r19
# CHECK: encoding: [0x62,0x8c,0xf8,0x08,0xf1,0x9c,0xac,0x23,0x01,0x00,0x00]
         crc32q	291(%r28,%r29,4), %r19

# CHECK: crc32w	123(%r28,%r29,4), %r18d
# CHECK: encoding: [0x62,0x8c,0x79,0x08,0xf1,0x54,0xac,0x7b]
         crc32w	123(%r28,%r29,4), %r18d

# CHECK: crc32l	123(%r28,%r29,4), %r18d
# CHECK: encoding: [0x62,0x8c,0x78,0x08,0xf1,0x54,0xac,0x7b]
         crc32l	123(%r28,%r29,4), %r18d

# CHECK: crc32b	123(%r28,%r29,4), %r19
# CHECK: encoding: [0x62,0x8c,0xf8,0x08,0xf0,0x5c,0xac,0x7b]
         crc32b	123(%r28,%r29,4), %r19

# CHECK: crc32q	123(%r28,%r29,4), %r19
# CHECK: encoding: [0x62,0x8c,0xf8,0x08,0xf1,0x5c,0xac,0x7b]
         crc32q	123(%r28,%r29,4), %r19
