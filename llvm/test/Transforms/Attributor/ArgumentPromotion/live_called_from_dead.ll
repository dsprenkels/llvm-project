; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -basicaa -attributor -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=4 < %s | FileCheck %s --check-prefixes=CHECK
; RUN: opt -S -basicaa -attributor-cgscc -attributor-disable=false < %s | FileCheck %s --check-prefixes=CHECK
; RUN: opt -S -passes='attributor' -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=4 < %s | FileCheck %s --check-prefixes=CHECK
; RUN: opt -S -passes='attributor-cgscc' -aa-pipeline='basic-aa' -attributor-disable=false < %s | FileCheck %s --check-prefixes=CHECK

; CHECK-NOT: @dead(
; CHECK-NOT: @test(
; CHECK-NOT: @caller(

define internal void @dead() {
  call i32 @test(i32* null, i32* null)
  ret void
}

define internal i32 @test(i32* %X, i32* %Y) {
  br i1 true, label %live, label %dead
live:
  store i32 0, i32* %X
  ret i32 0
dead:
  call i32 @caller(i32* null)
  call void @dead()
  ret i32 1
}

define internal i32 @caller(i32* %B) {
  %A = alloca i32
  store i32 1, i32* %A
  %C = call i32 @test(i32* %A, i32* %B)
  ret i32 %C
}

define i32 @callercaller() {
; CHECK-LABEL: define {{[^@]+}}@callercaller()
; CHECK-NEXT:    [[B:%.*]] = alloca i32
; CHECK-NEXT:    store i32 2, i32* [[B]], align 4
; CHECK-NEXT:    ret i32 0
;
  %B = alloca i32
  store i32 2, i32* %B
  %X = call i32 @caller(i32* %B)
  ret i32 %X
}

