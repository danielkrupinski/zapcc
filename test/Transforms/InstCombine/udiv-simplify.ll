; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i64 @test1(i32 %x) nounwind {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i64 0
;
  %y = lshr i32 %x, 1
  %r = udiv i32 %y, -1
  %z = sext i32 %r to i64
  ret i64 %z
}
define i64 @test2(i32 %x) nounwind {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret i64 0
;
  %y = lshr i32 %x, 31
  %r = udiv i32 %y, 3
  %z = sext i32 %r to i64
  ret i64 %z
}

; The udiv instructions shouldn't be optimized away, and the
; sext instructions should be optimized to zext.

define i64 @test1_PR2274(i32 %x, i32 %g) nounwind {
; CHECK-LABEL: @test1_PR2274(
; CHECK-NEXT:    [[Y:%.*]] = lshr i32 %x, 30
; CHECK-NEXT:    [[R:%.*]] = udiv i32 [[Y]], %g
; CHECK-NEXT:    [[Z1:%.*]] = zext i32 [[R]] to i64
; CHECK-NEXT:    ret i64 [[Z1]]
;
  %y = lshr i32 %x, 30
  %r = udiv i32 %y, %g
  %z = sext i32 %r to i64
  ret i64 %z
}
define i64 @test2_PR2274(i32 %x, i32 %v) nounwind {
; CHECK-LABEL: @test2_PR2274(
; CHECK-NEXT:    [[Y:%.*]] = lshr i32 %x, 31
; CHECK-NEXT:    [[R:%.*]] = udiv i32 [[Y]], %v
; CHECK-NEXT:    [[Z1:%.*]] = zext i32 [[R]] to i64
; CHECK-NEXT:    ret i64 [[Z1]]
;
  %y = lshr i32 %x, 31
  %r = udiv i32 %y, %v
  %z = sext i32 %r to i64
  ret i64 %z
}

; The udiv should be simplified according to the rule:
; X udiv (C1 << N), where C1 is `1<<C2` --> X >> (N+C2)
@b = external global [1 x i16]

define i32 @PR30366(i1 %a) {
; CHECK-LABEL: @PR30366(
; CHECK-NEXT:    [[Z:%.*]] = zext i1 %a to i32
; CHECK-NEXT:    [[D:%.*]] = lshr i32 [[Z]], zext (i16 ptrtoint ([1 x i16]* @b to i16) to i32)
; CHECK-NEXT:    ret i32 [[D]]
;
  %z = zext i1 %a to i32
  %d = udiv i32 %z, zext (i16 shl (i16 1, i16 ptrtoint ([1 x i16]* @b to i16)) to i32)
  ret i32 %d
}