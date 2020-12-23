#module_parameters (IMPORT_DEBUG_SYMBOLS := true);

#import "Linalg";

#if OS == .WINDOWS  #load "windows.jai";

IM3D_VERSION          :: "1.16";
IM3D_VERTEX_ALIGNMENT :: 4;

Im3d_Id :: u32;

// @Todo (stefan): Move Color to its own module.
Im3d_Color :: struct
{
	r, g, b, a : u8;
	#place r;
	value : u32;
	#place r;
	n : [4]u8;
}

Im3d_MakeColor :: (r : u8, g : u8, b : u8, a : u8) -> Im3d_Color
{
	result : Im3d_Color = ---;
	result.r = r;
	result.g = g;
	result.b = b;
	result.a = a;

	return result;
}

Im3d_MakeColor :: (r : float, g : float, b : float, a : float = 1.0) -> Im3d_Color
{
	result : Im3d_Color = ---;
	result.r = xx (r * 255);
	result.g = xx (g * 255);
	result.b = xx (b * 255);
	result.a = xx (a * 255);

	return result;
}

Im3d_MakeColor :: (vec : Vec4) -> Im3d_Color
{
	result : Im3d_Color = ---;
	result.r = xx (vec.r * 255);
	result.g = xx (vec.g * 255);
	result.b = xx (vec.b * 255);
	result.a = xx (vec.a * 255);

	return result;
}

IM3D_COLOR_BLACK   :: Im3d_Color.{   0,   0,   0, 255 };
IM3D_COLOR_WHITE   :: Im3d_Color.{ 255, 255, 255, 255 };
IM3D_COLOR_RED     :: Im3d_Color.{ 255,   0,   0, 255 };
IM3D_COLOR_GREEN   :: Im3d_Color.{   0, 255,   0, 255 };
IM3D_COLOR_BLUE    :: Im3d_Color.{   0,   0, 255, 255 };
IM3D_COLOR_CYAN    :: Im3d_Color.{   0, 255, 255, 255 };
IM3D_COLOR_MAGENTA :: Im3d_Color.{ 255, 255,   0, 255 };
IM3D_COLOR_YELLOW  :: Im3d_Color.{ 255,   0, 255, 255 };

Im3d_VertexData :: struct /* alignas (IM3D_VERTEX_ALIGNMENT) @Note (stefan): Is there a way to do that in Jai ? Do we even care ? */
{
	positionSize : Vec4;
	color        : Im3d_Color;
}

Im3d_DrawPrimitiveType :: enum s32
{
	Triangles;
	Lines;
	Points;
	Count;
}

Im3d_DrawList :: struct
{
	layerId     : Im3d_Id;
	primType    : Im3d_DrawPrimitiveType;
	vertexData  : *Im3d_VertexData;
	vertexCount : u32;
}

Im3d_DrawPrimitivesCallback :: #type (draw_list : *Im3d_DrawList) -> void;

Im3d_TextFlags :: enum_flags u32
{
	Default     :: 0x00;
	AlignLeft   :: 0x01;
	AlignRight  :: 0x02;
	// What is 0x04 ?? Probably deprecated I guess...
	AlignTop    :: 0x08;
	AlignBottom :: 0x10;
}

Im3d_TextData :: struct /* alignas (IM3D_VERTEX_ALIGNMENT) */
{
	positionSize     : Vec4;
	color            : Im3d_Color;
	flags            : u32;
	textLength       : u32;
	textBufferOffset : u32;
}

Im3d_TextDrawList :: struct
{
	layerId       : Im3d_Id;
	textData      : *Im3d_TextData;
	textDataCount : u32;
	textBuffer    : *u8;
}

Im3d_Key :: enum s32
{
	MouseLeft;
	L;
	R;
	S;
	T;
	Count;

	Select           :: MouseLeft;
	GizmoLocal       :: L;
	GizmoRotation    :: R;
	GizmoScale       :: S;
	GizmoTranslation :: T;
}

Im3d_FrustumPlane :: enum s32
{
	Near;
	Far;
	Top;
	Right;
	Bottom;
	Left;
	Count;
}

Im3d_AppData :: struct
{
	keyDown             : [Im3d_Key.Count]bool;
	cullFrustum         : [Im3d_FrustumPlane.Count]Vec4;
	cursorRayOrigin     : Vec3;
	cursorRayDirection  : Vec3;
	worldUp             : Vec3 = .{ 0, 1, 0 };
	viewOrigin          : Vec3;
	viewDirection       : Vec3;
	viewportSize        : Vec2;
	projScaleY          : float = 1.0;
	projOrtho           : bool;
	deltaTime           : float;
	snapTranslation     : float;
	snapRotation        : float;
	snapScale           : float;
	flipGizmoWhenBehind := true;
	appData             : *void;
	drawCallback        : *Im3d_DrawPrimitivesCallback;	// Why is this a pointer to a function pointer instead of just a function pointer ??
}

Im3d_Vector :: struct (T : Type)
{
	data     : *T;
	size     : u32;
	capacity : u32;
}

Im3d_PrimitiveMode :: enum s32
{
	None;
	Points;
	Lines;
	LineStrip;
	LineLoop;
	Triangles;
	TriangleStrip;
}

Im3d_GizmoMode :: enum s32
{
	Translation;
	Rotation;
	Scale;
}

Im3d_Context :: struct
{
// Gizmo state
	gizmoLocal        : bool;	// Global mode selection for gizmos.
	gizmoMode         : Im3d_GizmoMode;	// See above.
	activeId          : Im3d_Id;		// Currently active gizmo. If set, this is the same as hotId;
	hotId             : Im3d_Id;		// Id of the current 'hot' gizmo (nearest intersecting gizmo along the cursor ray). NB this is the id of the *sub* gizmo, not the app-specified Id.
	hotDepth          : float;	// Depth of the current hot gizmo along the cursor ray, for handling occlusion.
	appId             : Im3d_Id;		// Current Id *without* hashing the Id stack (=id arg to GizmoXXX functions).
	appActiveId       : Im3d_Id;		// Copied from appId for the current active gizmo.
	appHotId          : Im3d_Id;		// Copied from appId for the current 'hot' gizmo.
	gizmoStateVec3    : Vec3;	// Stored state for the active gizmos.
	gizmoStateMat3    : Mat3;	// See above.
	gizmoStateFloat   : float;	// See above.
	gizmoHeightPixels : float;	// Height/radius of gizmos.
	gizmoSizePixels   : float;	// Thickness of gizmo lines.

//private:
	colorStack         : Im3d_Vector (Im3d_Color);
	alphaStack         : Im3d_Vector (float);
	sizeStack          : Im3d_Vector (float);
	enableSortingStack : Im3d_Vector (bool);
	matrixStack        : Im3d_Vector (Mat4);
	idStack            : Im3d_Vector (Im3d_Id);
	layerIdStack       : Im3d_Vector (Im3d_Id);

	VertexList :: Im3d_Vector (Im3d_VertexData);

	vertexData      : [2]Im3d_Vector (*VertexList);	// @Note (stefan): May be incorrect if fixed arrays in Jai store their element count.
	vertexDataIndex : s32;
	layerIdMap      : Im3d_Vector (Im3d_Id);
	layerIndex      : s32;
	drawLists       : Im3d_Vector (Im3d_DrawList);
	sortCalled      : bool;
	endFrameCalled  : bool;

	TextList :: Im3d_Vector (Im3d_TextData);

	textData      : Im3d_Vector (*TextList);
	textBuffer    : Im3d_Vector (u8);
	textDrawLists : Im3d_Vector (Im3d_TextDrawList);

	primMode          : Im3d_PrimitiveMode;
	primType          : Im3d_DrawPrimitiveType;
	firstVertThisPrim : u32;
	vertCountThisPrim : u32;
	minVertThisPrim   : Vec3;
	maxVertThisPrim   : Vec3;

	appData          : Im3d_AppData;
	keyDownCurr      : [Im3d_Key.Count]bool;
	keyDownPrev      : [Im3d_Key.Count]bool;
	cullFrustum      : [Im3d_FrustumPlane.Count]Vec4;
	cullFrustumCount : s32;
}

