; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor --attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,MODULE,OLD_MODULE
; RUN: opt -attributor-cgscc --attributor-disable=false -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC,OLD_CGSCC
; RUN: opt -passes=attributor --attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,MODULE,NEW_MODULE
; RUN: opt -passes='attributor-cgscc' --attributor-disable=false -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC,NEW_CGSCC
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

; CHECK: Function Attrs: inaccessiblememonly
declare noalias i8* @malloc(i64) inaccessiblememonly

define dso_local i8* @internal_only(i32 %arg) {
; CHECK: Function Attrs: inaccessiblememonly
; CHECK-LABEL: define {{[^@]+}}@internal_only
; CHECK-SAME: (i32 [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CONV:%.*]] = sext i32 [[ARG]] to i64
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @malloc(i64 [[CONV]])
; CHECK-NEXT:    ret i8* [[CALL]]
;
entry:
  %conv = sext i32 %arg to i64
  %call = call i8* @malloc(i64 %conv)
  ret i8* %call
}

define dso_local i8* @internal_only_rec(i32 %arg) {
; CHECK: Function Attrs: inaccessiblememonly
; CHECK-LABEL: define {{[^@]+}}@internal_only_rec
; CHECK-SAME: (i32 [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[REM:%.*]] = srem i32 [[ARG]], 2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[REM]], 1
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[DIV:%.*]] = sdiv i32 [[ARG]], 2
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_only_rec(i32 [[DIV]])
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[CONV:%.*]] = sext i32 [[ARG]] to i64
; CHECK-NEXT:    [[CALL1:%.*]] = call noalias i8* @malloc(i64 [[CONV]])
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i8* [ [[CALL]], [[IF_THEN]] ], [ [[CALL1]], [[IF_END]] ]
; CHECK-NEXT:    ret i8* [[RETVAL_0]]
;
entry:
  %rem = srem i32 %arg, 2
  %cmp = icmp eq i32 %rem, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %div = sdiv i32 %arg, 2
  %call = call i8* @internal_only_rec(i32 %div)
  br label %return

if.end:                                           ; preds = %entry
  %conv = sext i32 %arg to i64
  %call1 = call i8* @malloc(i64 %conv)
  br label %return

return:                                           ; preds = %if.end, %if.then
  %retval.0 = phi i8* [ %call, %if.then ], [ %call1, %if.end ]
  ret i8* %retval.0
}

define dso_local i8* @internal_only_rec_static_helper(i32 %arg) {
; CHECK: Function Attrs: inaccessiblememonly
; CHECK-LABEL: define {{[^@]+}}@internal_only_rec_static_helper
; CHECK-SAME: (i32 [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_only_rec_static(i32 [[ARG]])
; CHECK-NEXT:    ret i8* [[CALL]]
;
entry:
  %call = call i8* @internal_only_rec_static(i32 %arg)
  ret i8* %call
}

define internal i8* @internal_only_rec_static(i32 %arg) {
; CHECK: Function Attrs: inaccessiblememonly
; CHECK-LABEL: define {{[^@]+}}@internal_only_rec_static
; CHECK-SAME: (i32 [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[REM:%.*]] = srem i32 [[ARG]], 2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[REM]], 1
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[DIV:%.*]] = sdiv i32 [[ARG]], 2
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_only_rec(i32 [[DIV]])
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[CONV:%.*]] = sext i32 [[ARG]] to i64
; CHECK-NEXT:    [[CALL1:%.*]] = call noalias i8* @malloc(i64 [[CONV]])
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i8* [ [[CALL]], [[IF_THEN]] ], [ [[CALL1]], [[IF_END]] ]
; CHECK-NEXT:    ret i8* [[RETVAL_0]]
;
entry:
  %rem = srem i32 %arg, 2
  %cmp = icmp eq i32 %rem, 1
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %div = sdiv i32 %arg, 2
  %call = call i8* @internal_only_rec(i32 %div)
  br label %return

if.end:                                           ; preds = %entry
  %conv = sext i32 %arg to i64
  %call1 = call i8* @malloc(i64 %conv)
  br label %return

return:                                           ; preds = %if.end, %if.then
  %retval.0 = phi i8* [ %call, %if.then ], [ %call1, %if.end ]
  ret i8* %retval.0
}

define dso_local i8* @internal_argmem_only_read(i32* %arg) {
; CHECK: Function Attrs: inaccessiblemem_or_argmemonly
; CHECK-LABEL: define {{[^@]+}}@internal_argmem_only_read
; CHECK-SAME: (i32* nocapture nonnull readonly align 4 dereferenceable(4) [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = load i32, i32* [[ARG]], align 4
; CHECK-NEXT:    [[CONV:%.*]] = sext i32 [[TMP]] to i64
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @malloc(i64 [[CONV]])
; CHECK-NEXT:    ret i8* [[CALL]]
;
entry:
  %tmp = load i32, i32* %arg, align 4
  %conv = sext i32 %tmp to i64
  %call = call i8* @malloc(i64 %conv)
  ret i8* %call
}

define dso_local i8* @internal_argmem_only_write(i32* %arg) {
; CHECK: Function Attrs: inaccessiblemem_or_argmemonly
; CHECK-LABEL: define {{[^@]+}}@internal_argmem_only_write
; CHECK-SAME: (i32* nocapture nonnull writeonly align 4 dereferenceable(4) [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i32 10, i32* [[ARG]], align 4
; CHECK-NEXT:    [[CALL:%.*]] = call noalias dereferenceable_or_null(10) i8* @malloc(i64 10)
; CHECK-NEXT:    ret i8* [[CALL]]
;
entry:
  store i32 10, i32* %arg, align 4
  %call = call dereferenceable_or_null(10) i8* @malloc(i64 10)
  ret i8* %call
}

define dso_local i8* @internal_argmem_only_rec(i32* %arg) {
; CHECK: Function Attrs: inaccessiblemem_or_argmemonly
; MODULE-LABEL: define {{[^@]+}}@internal_argmem_only_rec
; MODULE-SAME: (i32* nocapture align 4 [[ARG:%.*]])
; MODULE-NEXT:  entry:
; MODULE-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_argmem_only_rec_1(i32* nocapture align 4 [[ARG]])
; MODULE-NEXT:    ret i8* [[CALL]]
;
; CGSCC-LABEL: define {{[^@]+}}@internal_argmem_only_rec
; CGSCC-SAME: (i32* nocapture nonnull align 4 dereferenceable(4) [[ARG:%.*]])
; CGSCC-NEXT:  entry:
; CGSCC-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_argmem_only_rec_1(i32* nocapture nonnull align 4 dereferenceable(4) [[ARG]])
; CGSCC-NEXT:    ret i8* [[CALL]]
;
entry:
  %call = call i8* @internal_argmem_only_rec_1(i32* %arg)
  ret i8* %call
}

define internal i8* @internal_argmem_only_rec_1(i32* %arg) {
; CHECK: Function Attrs: inaccessiblemem_or_argmemonly
; CHECK-LABEL: define {{[^@]+}}@internal_argmem_only_rec_1
; CHECK-SAME: (i32* nocapture nonnull align 4 dereferenceable(4) [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = load i32, i32* [[ARG]], align 4
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[TMP]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[ARG]], align 4
; CHECK-NEXT:    [[CMP1:%.*]] = icmp eq i32 [[TMP1]], 1
; CHECK-NEXT:    br i1 [[CMP1]], label [[IF_THEN2:%.*]], label [[IF_END3:%.*]]
; CHECK:       if.then2:
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARG]], i64 -1
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_argmem_only_rec_2(i32* nocapture nonnull align 4 dereferenceable(4) [[ADD_PTR]])
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       if.end3:
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARG]], align 4
; CHECK-NEXT:    [[CONV:%.*]] = sext i32 [[TMP2]] to i64
; CHECK-NEXT:    [[CALL4:%.*]] = call noalias i8* @malloc(i64 [[CONV]])
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i8* [ null, [[IF_THEN]] ], [ [[CALL]], [[IF_THEN2]] ], [ [[CALL4]], [[IF_END3]] ]
; CHECK-NEXT:    ret i8* [[RETVAL_0]]
;
entry:
  %tmp = load i32, i32* %arg, align 4
  %cmp = icmp eq i32 %tmp, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  br label %return

if.end:                                           ; preds = %entry
  %tmp1 = load i32, i32* %arg, align 4
  %cmp1 = icmp eq i32 %tmp1, 1
  br i1 %cmp1, label %if.then2, label %if.end3

if.then2:                                         ; preds = %if.end
  %add.ptr = getelementptr inbounds i32, i32* %arg, i64 -1
  %call = call i8* @internal_argmem_only_rec_2(i32* nonnull %add.ptr)
  br label %return

if.end3:                                          ; preds = %if.end
  %tmp2 = load i32, i32* %arg, align 4
  %conv = sext i32 %tmp2 to i64
  %call4 = call i8* @malloc(i64 %conv)
  br label %return

return:                                           ; preds = %if.end3, %if.then2, %if.then
  %retval.0 = phi i8* [ null, %if.then ], [ %call, %if.then2 ], [ %call4, %if.end3 ]
  ret i8* %retval.0
}

define internal i8* @internal_argmem_only_rec_2(i32* %arg) {
; CHECK: Function Attrs: inaccessiblemem_or_argmemonly
; CHECK-LABEL: define {{[^@]+}}@internal_argmem_only_rec_2
; CHECK-SAME: (i32* nocapture nonnull align 4 dereferenceable(4) [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i32 0, i32* [[ARG]], align 4
; CHECK-NEXT:    [[ADD_PTR:%.*]] = getelementptr inbounds i32, i32* [[ARG]], i64 -1
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @internal_argmem_only_rec_1(i32* nocapture nonnull align 4 dereferenceable(4) [[ADD_PTR]])
; CHECK-NEXT:    ret i8* [[CALL]]
;
entry:
  store i32 0, i32* %arg, align 4
  %add.ptr = getelementptr inbounds i32, i32* %arg, i64 -1
  %call = call i8* @internal_argmem_only_rec_1(i32* nonnull %add.ptr)
  ret i8* %call
}
