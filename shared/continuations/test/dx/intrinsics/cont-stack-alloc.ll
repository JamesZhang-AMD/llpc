; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function main --version 2
; RUN: opt --verify-each -passes='lower-raytracing-pipeline,lint,inline,lint,dxil-cont-pre-coroutine,lint,sroa,lint,lower-await,lint,coro-early,dxil-coro-split,coro-cleanup,lint,legacy-cleanup-continuations,lint,register-buffer,lint,save-continuation-state,lint,dxil-cont-post-process,lint,remove-types-metadata' -S %s 2>%t.stderr | FileCheck %s
; RUN: count 0 < %t.stderr

declare i32 @_AmdContStackAlloc(ptr %csp, i32 %size)
declare i32 @_AmdContPayloadRegistersI32Count()

%struct.DispatchSystemData = type { i32 }
%struct.HitData = type { float, i32 }
%struct.BuiltInTriangleIntersectionAttributes = type { <2 x float> }
declare %struct.DispatchSystemData @_cont_SetupRayGen()
declare !types !15 i32 @_cont_GetLocalRootIndex(%struct.DispatchSystemData*)
declare !types !16 %struct.BuiltInTriangleIntersectionAttributes @_cont_GetTriangleHitAttributes(%struct.DispatchSystemData*)
declare !types !12 i32 @_cont_HitKind(%struct.DispatchSystemData*, %struct.HitData*)

%struct.Payload = type { [8 x i32] }

@debug_global = external global i32

define void @main() {
; CHECK-LABEL: define void @main() !continuation.entry !11 !continuation.registercount !5 !continuation !12 !continuation.state !5 !continuation.stacksize !13 {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SYSTEM_DATA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA:%.*]], align 8
; CHECK-NEXT:    [[SYSTEM_DATA_ALLOCA:%.*]] = alloca [[STRUCT_DISPATCHSYSTEMDATA]], align 8
; CHECK-NEXT:    [[CONT_STATE:%.*]] = alloca [0 x i32], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = call [[STRUCT_DISPATCHSYSTEMDATA]] @_cont_SetupRayGen()
; CHECK-NEXT:    store [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP0]], ptr [[SYSTEM_DATA]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = load [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA]], align 4
; CHECK-NEXT:    [[DOTFCA_0_EXTRACT:%.*]] = extractvalue [[STRUCT_DISPATCHSYSTEMDATA]] [[TMP1]], 0
; CHECK-NEXT:    [[DOTFCA_0_GEP:%.*]] = getelementptr inbounds [[STRUCT_DISPATCHSYSTEMDATA]], ptr [[SYSTEM_DATA_ALLOCA]], i32 0, i32 0
; CHECK-NEXT:    store i32 [[DOTFCA_0_EXTRACT]], ptr [[DOTFCA_0_GEP]], align 4
; CHECK-NEXT:    [[LOCAL_ROOT_INDEX:%.*]] = call i32 @_cont_GetLocalRootIndex(ptr [[SYSTEM_DATA_ALLOCA]])
; CHECK-NEXT:    call void @amd.dx.setLocalRootIndex(i32 [[LOCAL_ROOT_INDEX]])
; CHECK-NEXT:    [[PL_BYTES:%.*]] = mul i32 30, 4
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr @debug_global, align 4
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[TMP2]], 120
; CHECK-NEXT:    store i32 [[TMP3]], ptr @debug_global, align 4
; CHECK-NEXT:    store i32 [[TMP2]], ptr @debug_global, align 4
; CHECK-NEXT:    call void @continuation.complete()
; CHECK-NEXT:    unreachable
;
entry:
  %pl_size = call i32 @_AmdContPayloadRegistersI32Count()
  %pl_bytes = mul i32 %pl_size, 4
  %val = call i32 @_AmdContStackAlloc(ptr @debug_global, i32 %pl_bytes)
  store i32 %val, ptr @debug_global
  ret void
}

; Check for correct stack size
; CHECK: !13 = !{i32 120}

; Define hit shader to increase payload size
define void @chit(%struct.Payload* %pl, %struct.Payload* %attrs) !types !10 {
  ret void
}

!dx.entryPoints = !{!1, !5, !8}

!1 = !{null, !"", null, !3, !2}
!2 = !{i32 0, i64 65536}
!3 = !{!4, null, null, null}
!4 = !{!5}
!5 = !{void ()* @main, !"main", null, null, !6}
!6 = !{i32 8, i32 7, i32 6, i32 16, i32 7, i32 8, i32 5, !7}
!7 = !{i32 0}
!8 = !{void (%struct.Payload*, %struct.Payload*)* @chit, !"chit", null, null, !9}
!9 = !{i32 8, i32 10, i32 6, i32 16, i32 7, i32 8, i32 5, !7}
!10 = !{!"function", !"void", !11, !11}
!11 = !{i32 0, %struct.Payload poison}
!12 = !{!"function", i32 poison, !13, !14}
!13 = !{i32 0, %struct.DispatchSystemData poison}
!14 = !{i32 0, %struct.HitData poison}
!15 = !{!"function", !"void", !13}
!16 = !{!"function", %struct.BuiltInTriangleIntersectionAttributes poison, !13}
