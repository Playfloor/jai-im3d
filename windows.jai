#assert OS == .WINDOWS "This file should only be loaded on Windows";

Im3d_GetAppData :: () -> *Im3d_AppData #foreign im3d "?GetAppData@Im3d@@YAAEAUAppData@1@XZ";

Im3d_NewFrame :: () #foreign im3d "?NewFrame@Im3d@@YAXXZ";
Im3d_EndFrame :: () #foreign im3d "?EndFrame@Im3d@@YAXXZ";

Im3d_GetDrawLists :: inline () -> []Im3d_DrawList
{
	_Im3d_GetDrawLists     :: () -> *Im3d_DrawList #foreign im3d "?GetDrawLists@Im3d@@YAPEBUDrawList@1@XZ";
	_Im3d_GetDrawListCount :: () -> u32       #foreign im3d "?GetDrawListCount@Im3d@@YAIXZ";
	
	result : []Im3d_DrawList;
	result.data  = _Im3d_GetDrawLists ();
	result.count = _Im3d_GetDrawListCount ();

	return result; 
}


Im3d_GetTextDrawLists :: inline () -> []Im3d_TextDrawList
{
	_Im3d_GetTextDrawLists     :: () -> *Im3d_TextDrawList #foreign im3d "?GetTextDrawLists@Im3d@@YAPEBUTextDrawList@1@XZ";
	_Im3d_GetTextDrawListCount :: () -> u32           #foreign im3d "?GetTextDrawListCount@Im3d@@YAIXZ";
	
	result : []Im3d_TextDrawList;
	result.data  = _Im3d_GetTextDrawLists ();
	result.count = _Im3d_GetTextDrawListCount ();

	return result; 
}


Im3d_Draw :: () #foreign im3d "?Draw@Im3d@@YAXXZ";

Im3d_BeginPoints        :: () #foreign im3d "?BeginPoints@Im3d@@YAXXZ";
Im3d_BeginLines         :: () #foreign im3d "?BeginLines@Im3d@@YAXXZ";
Im3d_BeginLineLoop      :: () #foreign im3d "?BeginLineLoop@Im3d@@YAXXZ";
Im3d_BeginLineStrip     :: () #foreign im3d "?BeginLineStrip@Im3d@@YAXXZ";
Im3d_BeginTriangles     :: () #foreign im3d "?BeginTriangles@Im3d@@YAXXZ";
Im3d_BeginTriangleStrip :: () #foreign im3d "?BeginTriangleStrip@Im3d@@YAXXZ";
Im3d_End                :: () #foreign im3d "?End@Im3d@@YAXXZ";

Im3d__Vertex :: (const_ref_position : *Vec3)                                        #foreign im3d "?Vertex@Im3d@@YAXAEBUVec3@1@@Z";
Im3d__Vertex :: (const_ref_position : *Vec3, color : Im3d_Color)                    #foreign im3d "?Vertex@Im3d@@YAXAEBUVec3@1@UColor@1@@Z";
Im3d__Vertex :: (const_ref_position : *Vec3, size : float, color : Im3d_Color)      #foreign im3d "?Vertex@Im3d@@YAXAEBUVec3@1@MUColor@1@@Z";
 Im3d_Vertex :: (x : float, y : float, z : float)                                   #foreign im3d "?Vertex@Im3d@@YAXMMM@Z";
 Im3d_Vertex :: (x : float, y : float, z : float, color : Im3d_Color)               #foreign im3d "?Vertex@Im3d@@YAXMMMUColor@1@@Z";
 Im3d_Vertex :: (x : float, y : float, z : float, size : float, color : Im3d_Color) #foreign im3d "?Vertex@Im3d@@YAXMMMMUColor@1@@Z";
 Im3d_Vertex :: inline (position : Vec3) { Im3d__Vertex (*position); }
 Im3d_Vertex :: inline (position : Vec3, color : Im3d_Color) { Im3d__Vertex (*position, color); }
 Im3d_Vertex :: inline (position : Vec3, size : float, color : Im3d_Color) { Im3d__Vertex (*position, size, color); }

Im3d_PushColor :: ()                                               #foreign im3d "?PushColor@Im3d@@YAXXZ";
Im3d_PushColor :: (color : Im3d_Color)                             #foreign im3d "?PushColor@Im3d@@YAXUColor@1@@Z";
Im3d_PopColor  :: ()                                               #foreign im3d "?PopColor@Im3d@@YAXXZ";
Im3d_SetColor  :: (color : Im3d_Color)                             #foreign im3d "?SetColor@Im3d@@YAXUColor@1@@Z";
Im3d_SetColor  :: (r : float, g : float, b : float, a : float = 1) #foreign im3d "?SetColor@Im3d@@YAXMMMM@Z";
Im3d_GetColor  :: () -> Im3d_Color                                 #foreign im3d "?GetColor@Im3d@@YA?AUColor@1@XZ";

Im3d_PushAlpha :: ()              #foreign im3d "?PushAlpha@Im3d@@YAXXZ";
Im3d_PushAlpha :: (alpha : float) #foreign im3d "?PushAlpha@Im3d@@YAXM@Z";
Im3d_PopAlpha  :: ()              #foreign im3d "?PopAlpha@Im3d@@YAXXZ";
Im3d_SetAlpha  :: (alpha : float) #foreign im3d "?SetAlpha@Im3d@@YAXM@Z";
Im3d_GetAlpha  :: () -> float     #foreign im3d "?GetAlpha@Im3d@@YAMXZ";

Im3d_PushSize :: ()             #foreign im3d "?PushSize@Im3d@@YAXXZ";
Im3d_PushSize :: (size : float) #foreign im3d "?PushSize@Im3d@@YAXM@Z";
Im3d_PopSize  :: ()             #foreign im3d "?PopSize@Im3d@@YAXXZ";
Im3d_SetSize  :: (size : float) #foreign im3d "?SetSize@Im3d@@YAXM@Z";
Im3d_GetSize  :: () -> float    #foreign im3d "?GetSize@Im3d@@YAMXZ";

Im3d_PushEnableSorting :: ()              #foreign im3d "?PushEnableSorting@Im3d@@YAXXZ";
Im3d_PushEnableSorting :: (enable : bool) #foreign im3d "?PushEnableSorting@Im3d@@YAX_N@Z";
Im3d_PopEnableSorting  :: ()              #foreign im3d "?PopEnableSorting@Im3d@@YAXXZ";
Im3d_EnableSorting     :: (enable : bool) #foreign im3d "?EnableSorting@Im3d@@YAX_N@Z";

Im3d_PushDrawState :: () #foreign im3d "?PushDrawState@Im3d@@YAXXZ";
Im3d_PopDrawState  :: () #foreign im3d "?PopDrawState@Im3d@@YAXXZ";

 Im3d_PushMatrix  :: ()                                      #foreign im3d "?PushMatrix@Im3d@@YAXXZ";
Im3d__PushMatrix  :: (const_ref_matrix : *Mat4)              #foreign im3d "?PushMatrix@Im3d@@YAXAEBUMat4@1@@Z";
 Im3d_PopMatrix   :: ()                                      #foreign im3d "?PopMatrix@Im3d@@YAXXZ";
Im3d__SetMatrix   :: (const_ref_matrix : *Mat4)              #foreign im3d "?SetMatrix@Im3d@@YAXAEBUMat4@1@@Z";
 Im3d_SetIdentity :: ()                                      #foreign im3d "?SetIdentity@Im3d@@YAXXZ";
Im3d__MulMatrix   :: (const_ref_matrix : *Mat4)              #foreign im3d "?MulMatrix@Im3d@@YAXAEBUMat4@1@@Z";
 Im3d_Translate   :: (x : float, y : float, z : float)       #foreign im3d "?Translate@Im3d@@YAXMMM@Z";
Im3d__Translate   :: (const_ref_vector : *Vec3)              #foreign im3d "?Translate@Im3d@@YAXAEBUVec3@1@@Z";
Im3d__Rotate      :: (const_ref_axis : *Vec3, angle : float) #foreign im3d "?Rotate@Im3d@@YAXAEBUVec3@1@M@Z";
Im3d__Rotate      :: (const_ref_rotation : *Mat3)            #foreign im3d "?Rotate@Im3d@@YAXAEBUMat3@1@@Z";
 Im3d_Scale       :: (x : float, y : float, z : float)       #foreign im3d "?Scale@Im3d@@YAXMMM@Z";

Im3d_PushMatrix  :: inline (matrix : Mat4) { Im3d__PushMatrix (*matrix); }
Im3d_SetMatrix   :: inline (matrix : Mat4) { Im3d__SetMatrix (*matrix); }
Im3d_MulMatrix   :: inline (matrix : Mat4) { Im3d__SetMatrix (*matrix); }
Im3d_Translate   :: inline (vector : Vec3) { Im3d__Translate (*vector); }
Im3d_Rotate      :: inline (axis : Vec3, angle : float) { Im3d__Rotate (*axis, angle); }
Im3d_Rotate      :: inline (rotation : Mat3) { Im3d__Rotate (*rotation); }

 Im3d_DrawXyzAxes          :: ()                                                                                          #foreign im3d "?DrawXyzAxes@Im3d@@YAXXZ";
Im3d__DrawPoint            :: (const_ref_position : *Vec3, size : float, color : Im3d_Color)                              #foreign im3d "?DrawPoint@Im3d@@YAXAEBUVec3@1@MUColor@1@@Z";
Im3d__DrawLine             :: (const_ref_start : *Vec3, const_ref_end : *Vec3, size : float, color : Im3d_Color)          #foreign im3d "?DrawLine@Im3d@@YAXAEBUVec3@1@0MUColor@1@@Z";
Im3d__DrawQuad             :: (const_ref_origin : *Vec3, const_ref_normal : *Vec3, const_ref_size : *Vec2)                #foreign im3d "?DrawQuad@Im3d@@YAXAEBUVec3@1@0AEBUVec2@1@@Z";
Im3d__DrawQuadFilled       :: (const_ref_origin : *Vec3, const_ref_normal : *Vec3, const_ref_size : *Vec2)                #foreign im3d "?DrawQuadFilled@Im3d@@YAXAEBUVec3@1@0AEBUVec2@1@@Z";
Im3d__DrawCircle           :: (const_ref_origin : *Vec3, const_ref_normal : *Vec3, radius : float, detail : int)          #foreign im3d "?DrawCircle@Im3d@@YAXAEBUVec3@1@0MH@Z";
Im3d__DrawCircleFilled     :: (const_ref_origin : *Vec3, const_ref_normal : *Vec3, radius : float, detail : int)          #foreign im3d "?DrawCircleFilled@Im3d@@YAXAEBUVec3@1@0MH@Z";
Im3d__DrawSphere           :: (const_ref_origin : *Vec3, radius : float, detail : int)                                    #foreign im3d "?DrawSphere@Im3d@@YAXAEBUVec3@1@MH@Z";
Im3d__DrawSphereFilled     :: (const_ref_origin : *Vec3, radius : float, detail : int)                                    #foreign im3d "?DrawSphereFilled@Im3d@@YAXAEBUVec3@1@MH@Z";
Im3d__DrawAlignedBox       :: (const_ref_min : *Vec3, const_ref_max : *Vec3)                                              #foreign im3d "?DrawAlignedBox@Im3d@@YAXAEBUVec3@1@0@Z";
Im3d__DrawAlignedBoxFilled :: (const_ref_min : *Vec3, const_ref_max : *Vec3)                                              #foreign im3d "?DrawAlignedBoxFilled@Im3d@@YAXAEBUVec3@1@0@Z";
Im3d__DrawCylinder         :: (const_ref_start : *Vec3, const_ref_end : *Vec3, radius : float, detail : int)              #foreign im3d "?DrawCylinder@Im3d@@YAXAEBUVec3@1@0MH@Z";
Im3d__DrawCapsule          :: (const_ref_start : *Vec3, const_ref_end : *Vec3, radius : float, detail : int)              #foreign im3d "?DrawCapsule@Im3d@@YAXAEBUVec3@1@0MH@Z";
Im3d__DrawPrism            :: (const_ref_start : *Vec3, const_ref_end : *Vec3, radius : float, sides : int)               #foreign im3d "?DrawPrism@Im3d@@YAXAEBUVec3@1@0MH@Z";
Im3d__DrawArrow            :: (const_ref_start : *Vec3, const_ref_end : *Vec3, headLength : float, headThickness : float) #foreign im3d "?DrawArrow@Im3d@@YAXAEBUVec3@1@0MM@Z";

Im3d_DrawPoint            :: inline (position : Vec3, size : float, color : Im3d_Color) { Im3d__DrawPoint (*position, size, color); }
Im3d_DrawLine             :: inline (start : Vec3, end : Vec3, size : float, color : Im3d_Color) { Im3d__DrawLine (*start, *end, size, color); }
Im3d_DrawQuad             :: inline (origin : Vec3, normal : Vec3, size : Vec2) { Im3d__DrawQuad (*origin, *normal, *size); }
Im3d_DrawQuadFilled       :: inline (origin : Vec3, normal : Vec3, size : Vec2) { Im3d__DrawQuadFilled (*origin, *normal, *size); }
Im3d_DrawCircle           :: inline (origin : Vec3, normal : Vec3, radius : float, detail : int = -1) { Im3d__DrawCircle (*origin, *normal, radius, detail); }
Im3d_DrawCircleFilled     :: inline (origin : Vec3, normal : Vec3, radius : float, detail : int = -1) { Im3d__DrawCircleFilled (*origin, *normal, radius, detail); }
Im3d_DrawSphere           :: inline (origin : Vec3, radius : float, detail : int = -1) { Im3d__DrawSphere (*origin, radius, detail); }
Im3d_DrawSphereFilled     :: inline (origin : Vec3, radius : float, detail : int = -1) { Im3d__DrawSphereFilled (*origin, radius, detail); }
Im3d_DrawAlignedBox       :: inline (min : Vec3, max : Vec3) { Im3d__DrawAlignedBox (*min, *max); }
Im3d_DrawAlignedBoxFilled :: inline (min : Vec3, max : Vec3) { Im3d__DrawAlignedBoxFilled (*min, *max); }
Im3d_DrawCylinder         :: inline (start : Vec3, end : Vec3, radius : float, detail : int = -1) { Im3d__DrawCylinder (*start, *end, radius, detail); }
Im3d_DrawCapsule          :: inline (start : Vec3, end : Vec3, radius : float, detail : int = -1) { Im3d__DrawCapsule (*start, *end, radius, detail); }
Im3d_DrawPrism            :: inline (start : Vec3, end : Vec3, radius : float, sides : int) { Im3d__DrawPrism (*start, *end, radius, sides); }
Im3d_DrawArrow            :: inline (start : Vec3, end : Vec3, head_length : float = -1.0, head_thickness : float = -1.0) { Im3d__DrawArrow (*start, *end, head_length, head_thickness); }

// @Todo (stefan): formatting
Im3d__Text :: (const_ref_position : *Vec3, text_flags : u32, text : *u8, args : ..Any)                                   #foreign im3d "?Text@Im3d@@YAXAEBUVec3@1@IPEBDZZ";
Im3d__Text :: (const_ref_position : *Vec3, size : float, color : Im3d_Color, text_flags : u32, text : *u8, args : ..Any) #foreign im3d "?Text@Im3d@@YAXAEBUVec3@1@MUColor@1@IPEBDZZ";

Im3d_Text :: inline (position : Vec3, text_flags : u32, text : string, args : ..Any)
{
	formatted_text := tprint (text, ..args);
	Im3d__Text (*position, text_flags, temp_c_string (formatted_text));
}

Im3d_Text :: inline (position : Vec3, size : float, color : Im3d_Color, text_flags : u32, text : string, args : ..Any)
{
	formatted_text := tprint (text, ..args);
	Im3d__Text (*position, size, color, text_flags, temp_c_string (formatted_text));
}

Im3d_MakeId :: (str : *u8) -> Im3d_Id   #foreign im3d "?MakeId@Im3d@@YAIPEBD@Z";
Im3d_MakeId :: (ptr : *void) -> Im3d_Id #foreign im3d "?MakeId@Im3d@@YAIPEBX@Z";
Im3d_MakeId :: (i : s32) -> Im3d_Id     #foreign im3d "?MakeId@Im3d@@YAIH@Z";
Im3d_MakeId :: inline (str : string) -> Im3d_Id { return Im3d_MakeId (temp_c_string (str)); }

Im3d_PushId :: ()                 #foreign im3d "?PushId@Im3d@@YAXXZ";
Im3d_PushId :: (id : Im3d_Id)     #foreign im3d "?PushId@Im3d@@YAXI@Z";
Im3d_PushId :: (str : *u8)        #foreign im3d "?PushId@Im3d@@YAXPEBD@Z";
Im3d_PushId :: (ptr : *void)      #foreign im3d "?PushId@Im3d@@YAXH@Z";
Im3d_PushId :: (i : s32)          #foreign im3d "?PushId@Im3d@@YAXH@Z";
Im3d_PopId  :: ()                 #foreign im3d "?PopId@Im3d@@YAXXZ";
Im3d_GetId  :: () -> Im3d_Id      #foreign im3d "?GetId@Im3d@@YAIXZ";
Im3d_PushId :: inline (str : string) { Im3d_PushId (temp_c_string (str)); }

Im3d_PushLayerId :: (id : Im3d_Id)   #foreign im3d "?PushLayerId@Im3d@@YAXI@Z";
Im3d_PushLayerId :: (str : *u8)      #foreign im3d "?PushLayerId@Im3d@@YAXPEBD@Z";
Im3d_PopLayerId  :: ()               #foreign im3d "?PopLayerId@Im3d@@YAXXZ";
Im3d_GetLayerId  :: () -> Im3d_Id    #foreign im3d "?GetLayerId@Im3d@@YAIXZ";
Im3d_PushLayerId :: inline (str : string) { Im3d_PushLayerId (temp_c_string (str)); }

Im3d__GizmoTranslation :: (id : Im3d_Id, translation : *float, local : bool) -> bool                      #foreign im3d "?GizmoTranslation@Im3d@@YA_NIQEAM_N@Z";
Im3d__GizmoRotation    :: (id : Im3d_Id, rotation : *float, local : bool) -> bool                         #foreign im3d "?GizmoRotation@Im3d@@YA_NIQEAM_N@Z";
Im3d__GizmoScale       :: (id : Im3d_Id, scale : *float, local : bool) -> bool                            #foreign im3d "?GizmoScale@Im3d@@YA_NIQEAM@Z";
Im3d__Gizmo            :: (id : Im3d_Id, translation : *float, rotation : *float, scale : *float) -> bool #foreign im3d "?Gizmo@Im3d@@YA_NIQEAM00@Z"; 
Im3d__Gizmo            :: (id : Im3d_Id, transform : *float) -> bool                                      #foreign im3d "?Gizmo@Im3d@@YA_NIQEAM@Z";
 
Im3d_GizmoTranslation :: inline (id : Im3d_Id, translation : *Vec3, local : bool = false) -> bool { return Im3d__GizmoTranslation (id, *translation.x, local); }
Im3d_GizmoRotation    :: inline (id : Im3d_Id, rotation : *Mat3, local : bool = false) -> bool { return Im3d__GizmoRotation (id, *rotation.n11, local); }
Im3d_GizmoScale       :: inline (id : Im3d_Id, scale : *Vec3, local : bool = false) -> bool  { return Im3d__GizmoScale (id, *scale.x, local); }
Im3d_Gizmo            :: inline (id : Im3d_Id, translation : *Vec3, rotation : *Mat3, scale : *Vec3) -> bool { return Im3d__Gizmo (id, *translation.x, *rotation.n11, *scale.x); }
Im3d_Gizmo            :: inline (id : Im3d_Id, transform : *Mat4) -> bool { return Im3d__Gizmo (id, *transform.n11); } 

Im3d_GetActiveId :: () -> Im3d_Id #foreign im3d "?GetActiveId@Im3d@@YAIXZ";
Im3d_GetHotId    :: () -> Im3d_Id #foreign im3d "?GetHotId@Im3d@@YAIXZ";

Im3d__IsVisible :: (const_ref_origin : *Vec3, radius : float) -> bool     #foreign im3d "?IsVisible@Im3d@@YA_NAEBUVec3@1@M@Z";
Im3d__IsVisible :: (const_ref_min : *Vec3, const_ref_max : *Vec3) -> bool #foreign im3d "?IsVisible@Im3d@@YA_NAEBUVec3@1@0@Z";
 
Im3d_IsVisible :: inline (origin : Vec3, radius : float) -> bool { return Im3d__IsVisible (*origin, radius); }
Im3d_IsVisible :: inline (min : Vec3, max : Vec3) -> bool { return Im3d__IsVisible (*min, *max); }

Im3d_GetContext :: () -> *Im3d_Context   #foreign im3d "?GetContext@Im3d@@YAAEAUContext@1@XZ";
Im3d_SetContext :: (ctx : *Im3d_Context) #foreign im3d "?SetContext@Im3d@@YAXAEAUContext@1@@Z";

Im3d_MergeContexts :: (source : *Im3d_Context, dest : *Im3d_Context) #foreign im3d "?MergeContexts@Im3d@@YAXAEAUContext@1@AEBU21@@Z";

Im3d_Context_GetPrimitiveCount :: (ctx : *Im3d_Context, type : Im3d_DrawPrimitiveType) -> u32 #foreign im3d "?getPrimitiveCount@Context@Im3d@@QEBAIW4DrawPrimitiveType@2@@Z";
Im3d_Context_GetTextCount :: (ctx : *Im3d_Context) -> u32 #foreign im3d "?getTextCount@Context@Im3d@@QEBAIXZ";
Im3d_Context_GetLayerCount :: (ctx : *Im3d_Context) -> u32 #foreign im3d "?getLayerCount@Context@Im3d@@QEBAIXZ";

Im3d_AppData_SetCullFrustum :: inline (data : *Im3d_AppData, frustum : Mat4, ndcZNegativeOneToOne : bool)
{
	AppData_setCullFrustum :: (data : *Im3d_AppData, frustum : *Mat4, ndcZNegativeOneToOne : bool) #foreign im3d "?setCullFrustum@AppData@Im3d@@QEAAXAEBUMat4@2@_N@Z";
	AppData_setCullFrustum (data, *frustum, ndcZNegativeOneToOne);
}

#scope_file

#import "Basic";

#if STATIC_LINKING
{
	#if IMPORT_DEBUG_SYMBOLS  im3d :: #foreign_library, no_dll "win_debug/Im3d";
	else                      im3d :: #foreign_library, no_dll "win/Im3d";
}
else
{
	#if IMPORT_DEBUG_SYMBOLS  im3d :: #foreign_library "win_debug/Im3d";
	else                      im3d :: #foreign_library "win/Im3d";
}
