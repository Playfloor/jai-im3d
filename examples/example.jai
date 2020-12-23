#scope_file

// Unified gizmo operates directly on a 4x4 matrix using the context-global gizmo modes.
unified_gizmo_transform := MAT4_IDENTITY;

// Translation/rotation/scale can be modified separately - useful in cases where only certain transformations are valid.
separate_gizmos_translation : Vec3;
separate_gizmos_rotation    : Mat3;
separate_gizmos_scale       := VEC3_ONE;

// It is often useful to modify a single node in a transformation hierarchy directly, which can be done as follows.
// Note that scaling the parent is probably undesirable in these cases.
hierarchical_gizmos_parent := MAT4_IDENTITY;
hierarchical_gizmos_child  := MAT4_IDENTITY;

// The size/radius of gizmos can be modified globally.
gizmo_appearance_alpha  := 1.0;
gizmo_appearance_size   : float;
gizmo_appearance_height : float;
gizmo_appearance_transform := MAT4_IDENTITY;

// Im3d provides functions to easily draw high order shapes - these don't strictly require a matrix to be pushed on
// the stack (although this is supported, as below).
high_order_shapes_transform := MAT4_IDENTITY;
high_order_shapes_current_shape := Shape.Capsule;
high_order_shapes_color : Vec4;
high_order_shapes_thickness := 4.0;
high_order_shapes_detail : s32 = -1;
high_order_shapes_quad_size : Vec2;

text_color := VEC4_ONE;
text_size  := 1.0;
text_theta := 0.0;
text_flags := Im3d_TextFlags.Default;

grid_size : s32 = 20;

Shape :: enum
{
	Quad;
	QuadFilled;
	Circle;
	CircleFilled;
	Sphere;
	SphereFilled;
	AlignedBox;
	AlignedBoxFilled;
	Cylinder;
	Capsule;
	Prism;
	Arrow;
}

#scope_export

update_example :: (delta_time : float)
{
	window_pos, window_pivot : Vec2;

	//Im3d_RandSeed(0);

	ctx      := Im3d_GetContext();
	app_data := Im3d_GetAppData();

	ImGui.Begin("Im3d Demo", null, flags = .AlwaysAutoResize);

	ImGui.SetNextTreeNodeOpen(true, .Once);
	if (ImGui.TreeNode("About"))
	{
		ImGui.Text("Welcome to the Im3d demo!");
		ImGui.Spacing();
		ImGui.Text("WASD   = forward/left/backward/right");
		ImGui.Text("QE     = down/up");
		ImGui.Text("R      = look at origin");
		ImGui.Text("RMouse = camera orientation");
		ImGui.Text("LShift = move faster");
		ImGui.Spacing();

		ImGui.TreePop();
	}
	ImGui.Spacing();

	ImGui.SetNextTreeNodeOpen(true, .Once);
	if (ImGui.TreeNode("Unified Gizmo"))
	{
		// Context-global gizmo modes are set via actions in the AppData::keyDown but could also be modified via a GUI as follows:
		gizmoMode := cast (s32) Im3d_GetContext().gizmoMode;
		ImGui.Checkbox("Local (Ctrl+L)", *Im3d_GetContext().gizmoLocal);
		ImGui.SameLine();
		ImGui.RadioButton("Translate (Ctrl+T)", *gizmoMode, xx Im3d_GizmoMode.Translation); 
		ImGui.SameLine();
		ImGui.RadioButton("Rotate (Ctrl+R)", *gizmoMode, xx Im3d_GizmoMode.Rotation);
		ImGui.SameLine();
		ImGui.RadioButton("Scale (Ctrl+S)", *gizmoMode, xx Im3d_GizmoMode.Scale);
		Im3d_GetContext().gizmoMode = xx gizmoMode;

		// The ID passed to Gizmo() should be unique during a frame - to create gizmos in a loop use PushId()/PopId().
		if (Im3d_Gizmo(Im3d_MakeId ("GizmoUnified"), *unified_gizmo_transform))
		{
			// if Gizmo() returns true, the transform was modified
			if Im3d_GetContext().gizmoMode ==
			{
			case .Translation;
				pos := get_translation (unified_gizmo_transform);
				ImGui.Text("Position: %, %, %", pos.x, pos.y, pos.z);
				
			case .Rotation;
				euler := quat_to_euler_angles (get_rotation_quaternion (unified_gizmo_transform));
				ImGui.Text("Rotation: %, %, %", to_degrees (euler.x), to_degrees (euler.y), to_degrees (euler.z));
				
			case .Scale;
				scale := get_scale (unified_gizmo_transform);
				ImGui.Text("Scale: %, %, %", scale.x, scale.y, scale.z);
			};
			
		}

		// Using the transform for drawing *after* the call to Gizmo() causes a 1 frame lag between the gizmo position and the output
		// matrix - this can only be avoided if it's possible to issue the draw call *before* calling Gizmo().
		draw_teapot (unified_gizmo_transform, camera.view_projection_matrix);

		ImGui.TreePop();
	}


	if (ImGui.TreeNode("Separate Gizmos"))
	{
		// The separate Gizmo*() functions require the transformation to be pushed on the matrix stack to correctly handle local gizmos.
		Im3d_PushMatrix(make_transform_matrix (separate_gizmos_translation, get_rotation_quaternion (separate_gizmos_rotation), separate_gizmos_scale));

		gizmoMode := cast (s32) Im3d_GetContext().gizmoMode;
		ImGui.Checkbox("Local (Ctrl+L)", *Im3d_GetContext().gizmoLocal);
		ImGui.SameLine();
		ImGui.RadioButton("Translate (Ctrl+T)", *gizmoMode, xx Im3d_GizmoMode.Translation); 
		ImGui.SameLine();
		ImGui.RadioButton("Rotate (Ctrl+R)", *gizmoMode, xx Im3d_GizmoMode.Rotation);
		ImGui.SameLine();
		ImGui.RadioButton("Scale (Ctrl+S)", *gizmoMode, xx Im3d_GizmoMode.Scale);
		Im3d_GetContext().gizmoMode = cast (Im3d_GizmoMode) gizmoMode;

		if Im3d_GetContext().gizmoMode ==
		{
		case .Translation;
			if (Im3d_GizmoTranslation(Im3d_MakeId ("GizmoTranslation"), *separate_gizmos_translation, Im3d_GetContext().gizmoLocal))
			{
				ImGui.Text("Position: %, %, %", separate_gizmos_translation.x, separate_gizmos_translation.y, separate_gizmos_translation.z);
			}

		case .Rotation;
			if (Im3d_GizmoRotation(Im3d_MakeId ("GizmoRotation"), *separate_gizmos_rotation, Im3d_GetContext().gizmoLocal))
			{
				euler := quat_to_euler_angles (get_rotation_quaternion (separate_gizmos_rotation));
				ImGui.Text("Rotation: %, %, %", to_degrees (euler.x), to_degrees (euler.y), to_degrees (euler.z));
			}

		case .Scale;
			if (Im3d_GizmoScale(Im3d_MakeId ("GizmoScale"), *separate_gizmos_scale))
			{
				ImGui.Text("Scale: %, %, %", separate_gizmos_scale.x, separate_gizmos_scale.y, separate_gizmos_scale.z);
			}
		};

		draw_teapot (make_transform_matrix (separate_gizmos_translation, get_rotation_quaternion (separate_gizmos_rotation), separate_gizmos_scale), camera.view_projection_matrix);

		Im3d_PopMatrix();

		ImGui.TreePop();
	}

	
	if (ImGui.TreeNode("Hierarchical Gizmos"))
	{
		Im3d_Gizmo(Im3d_MakeId ("GizmoParent"), *hierarchical_gizmos_parent); // modify parent directly
		
		parentChild := hierarchical_gizmos_parent * hierarchical_gizmos_child; // modify the final world space transform
		if (Im3d_Gizmo(Im3d_MakeId ("GizmoChild"), *parentChild))
		{
			hierarchical_gizmos_child = get_inversed (hierarchical_gizmos_parent) * parentChild; // extract the child transform if modified
		}
		
		draw_teapot (hierarchical_gizmos_parent, camera.view_projection_matrix);
		draw_teapot (hierarchical_gizmos_parent * hierarchical_gizmos_child, camera.view_projection_matrix);

		ImGui.TreePop();
	}

	if (ImGui.TreeNode("Gizmo Appearance"))
	{
		ImGui.SliderFloat("Alpha", *gizmo_appearance_alpha, 0.0, 1.0, display_format = "%.3f");
		ImGui.SliderFloat("Height/Radius", *gizmo_appearance_height, 0.0, 128.0, display_format = "%.3f");
		ImGui.SliderFloat("Thickness", *gizmo_appearance_size, 0.0, 16.0, display_format = "%.3f");

		Im3d_PushAlpha(gizmo_appearance_alpha);
		storedSize := Im3d_GetContext().gizmoSizePixels;
		Im3d_GetContext().gizmoSizePixels = gizmo_appearance_size;
		storedHeight := Im3d_GetContext().gizmoHeightPixels;
		Im3d_GetContext().gizmoHeightPixels = gizmo_appearance_height;

		Im3d_Gizmo(Im3d_MakeId ("GizmoAppearance"), *gizmo_appearance_transform);
		draw_teapot (gizmo_appearance_transform, camera.view_projection_matrix);

		Im3d_GetContext().gizmoHeightPixels = storedHeight;
		Im3d_GetContext().gizmoSizePixels = storedSize;
		Im3d_PopAlpha();

		ImGui.TreePop();
	}

	if (ImGui.TreeNode("Cursor Ray Intersection"))
	{
		// Context exposes the 'hot depth' along the cursor ray which intersects with the current hot gizmo - this is useful
		// when drawing the cursor ray.
		depth := min (Math.FLOAT32_MAX, Im3d_GetContext().hotDepth);
		size  := clamp (32.0 / depth, 4.0, 32.0);
		
		if (depth != Math.FLOAT32_MAX)
		{
			ImGui.Text("Depth: %", depth);
			Im3d_PushEnableSorting(true);
			Im3d_BeginPoints();
				Im3d_Vertex(app_data.cursorRayOrigin + app_data.cursorRayDirection * depth * 0.99, size, IM3D_COLOR_MAGENTA);
			Im3d_End();
			Im3d_PopEnableSorting();
		}
		else
		{
			ImGui.Text("Depth: FLT_MAX");
		}
	
		ImGui.TreePop();
	}

/*
	//ImGui.SetNextTreeNodeOpen(true, ImGuiCond_Once);
	if (ImGui.TreeNode("High Order Shapes"))
	{
		Im3d_Gizmo("ShapeGizmo", high_order_shapes_transform);

		shapeList :: *u8.[
			"Quad\0"
			"Quad Filled\0"
			"Circle\0"
			"Circle Filled\0"
			"Sphere\0"
			"Sphere Filled\0"
			"AlignedBox\0"
			"AlignedBoxFilled\0"
			"Cylinder\0"
			"Capsule\0"
			"Prism\0",
			"Arrow\0" ];
		ImGui.Combo("Shape", *high_order_shapes_current_shape, shapeList);
		ImGui.ColorEdit4("Color", high_order_shapes_color);
		ImGui.SliderFloat("Thickness", *high_order_shapes_thickness, 0.0, 16.0);

		Im3d_PushMatrix(high_order_shapes_transform);
		Im3d_PushDrawState();
		Im3d_SetSize(high_order_shapes_thickness);
		Im3d_SetColor(color (high_order_shapes_color.x, high_order_shapes_color.y, high_order_shapes_color.z, high_order_shapes_color.w));

		if high_order_shapes_current_shape ==
		{
			case .Quad; 
			case .QuadFilled;
			{
				ImGui.SliderFloat2("Size", quadSize, 0.0, 10.0);
				if (currentShape == Shape_Quad)
				{
					Im3d_DrawQuad(vec3(0.0), vec3(0.0, 0.0, 1.0), high_order_shapes_quad_size);
				}
				else
				{
					Im3d_DrawQuadFilled(vec3(0.0), vec3(0.0, 0.0, 1.0), high_order_shapes_quad_size);
				}
			}
			case .Circle; 
			case .CircleFilled;
			{
				static float circleRadius = 1.0;
				ImGui.SliderFloat("Radius", *circleRadius, 0.0, 10.0);
				ImGui.SliderInt("Detail", *detail, -1, 128);
				if (currentShape == .Circle)
				{
					Im3d_DrawCircle(vec3(0.0), vec3(0.0, 0.0, 1.0), circleRadius, detail);
				}
				else if (currentShape = .CircleFilled)
				{
					Im3d_DrawCircleFilled(vec3(0.0), vec3(0.0, 0.0, 1.0), circleRadius, detail);
				}
			}
			case .Sphere;
			case .SphereFilled;
			{
				static float sphereRadius = 1.0;
				ImGui.SliderFloat("Radius", *sphereRadius, 0.0, 10.0);
				ImGui.SliderInt("Detail", *detail, -1, 128);
				if (currentShape == .Sphere)
				{
					Im3d_DrawSphere(vec3(0.0), sphereRadius, detail);
				}
				else
				{ 
					Im3d_DrawSphereFilled(vec3(0.0), sphereRadius, detail);
				}
			}
			case .AlignedBox; 
			case .AlignedBoxFilled;
			{
				static Vec3 boxSize(1.0);
				ImGui.SliderFloat3("Size", boxSize, 0.0, 10.0);
				if (currentShape == Shape_AlignedBox)
				{
					Im3d_DrawAlignedBox(-boxSize, boxSize);
				}
				else
				{
					Im3d_DrawAlignedBoxFilled(-boxSize, boxSize);
				}
			}
			case .Cylinder;
			{
				static float cylinderRadius = 1.0;
				static float cylinderLength = 1.0;
				ImGui.SliderFloat("Radius", *cylinderRadius, 0.0, 10.0);
				ImGui.SliderFloat("Length", *cylinderLength, 0.0, 10.0);
				ImGui.SliderInt("Detail", *detail, -1, 128);
				Im3d_DrawCylinder(vec3(0.0, -cylinderLength, 0.0), vec3(0.0, cylinderLength, 0.0), cylinderRadius, detail);
			}
			case .Capsule;
			{
				static float capsuleRadius = 0.5;
				static float capsuleLength = 1.0;
				ImGui.SliderFloat("Radius", *capsuleRadius, 0.0, 10.0);
				ImGui.SliderFloat("Length", *capsuleLength, 0.0, 10.0);
				ImGui.SliderInt("Detail", *detail, -1, 128);
				Im3d_DrawCapsule(vec3(0.0, -capsuleLength, 0.0), vec3(0.0, capsuleLength, 0.0), capsuleRadius, detail);
			}
			case .Prism;
			{
				static float prismRadius = 1.0;
				static float prismLength = 1.0;
				static int   prismSides  = 3;
				ImGui.SliderFloat("Radius", *prismRadius, 0.0, 10.0);
				ImGui.SliderFloat("Length", *prismLength, 0.0, 10.0);
				ImGui.SliderInt("Sides", *prismSides, 3, 16);
				Im3d_DrawPrism(vec3(0.0, -prismLength, 0.0), vec3(0.0, prismLength, 0.0), prismRadius, prismSides);
			}
			case .Arrow;
			{
				static float arrowLength   = 1.0;
				static float headLength    = -1.0;
				static float headThickness = -1.0;
				ImGui.SliderFloat("Length",          *arrowLength,   0.0, 10.0);
				ImGui.SliderFloat("Head Length",     *headLength,    0.0, 1.0);
				ImGui.SliderFloat("Head Thickness",  *headThickness, 0.0, 1.0);
				Im3d_DrawArrow(vec3(0.0), vec3(0.0, arrowLength, 0.0), headLength, headThickness);
			}
		};

		Im3d_PopDrawState();
		Im3d_PopMatrix();

		ImGui.TreePop();
	}

	
	if (ImGui.TreeNode("Basic Perf"))
	{
		// Simple perf test: draw a large number of points, enable/disable sorting and the use of the matrix stack.
		static bool enableSorting = false;
		static bool useMatrix = false; // if the matrix stack size == 1 Im3d assumes it's the identity matrix and skips the matrix mul as an optimisation
		static int  primCount = 50000;
		ImGui.Checkbox("Enable sorting", *enableSorting);
		ImGui.Checkbox("Use matrix stack", *useMatrix);
		ImGui.SliderInt("Prim Count", *primCount, 2, 100000);
		
		Im3d_PushEnableSorting(enableSorting);
		Im3d_BeginPoints();
		if (useMatrix)
		{
			Im3d_PushMatrix();
			for (int i = 0; i < primCount; i += 1)
			{
				Mat4 wm(1.0);
				wm.setTranslation(Im3d_Randvec3(-10.0, 10.0));
				Im3d_SetMatrix(wm);
				Im3d_Vertex(vec3(0.0), Im3d_RandFloat(2.0, 16.0), Im3d_RandColor(0.0, 1.0));
			}
			Im3d_PopMatrix();
		}
		else
		{
			for (int i = 0; i < primCount; i += 1)
			{
				Vec3 t = Im3d_Randvec3(-10.0, 10.0);
				Im3d_Vertex(t, Im3d_RandFloat(2.0, 16.0), Im3d_RandColor(0.0, 1.0));
			}
		}
		Im3d_End();
		Im3d_PopEnableSorting();

		ImGui.TreePop();
	}


	if (ImGui.TreeNode("Sorting"))
	{
		// If sorting is enabled, primitives are sorted back-to-front for rendering. Lines/triangles use the primitive midpoint, so very long
		// lines or large triangles may not sort correctly.
		static bool enableSorting = true;
		static int  primCount = 1000;
		ImGui.Checkbox("Enable sorting", *enableSorting);
		ImGui.SliderInt("Prim Count", *primCount, 2, 10000);

		Im3d_PushDrawState();
			Im3d_EnableSorting(enableSorting);
			Im3d_SetAlpha(0.9);
			for (int i = 0; i < primCount / 3; i += 1)
			{
				Im3d_PushMatrix();
					Mat4 wm(1.0);
					wm.setRotation(Im3d_Rotation(Im3d_Normalize(Im3d_Randvec3(-1.0, 1.0)), Im3d_RandFloat(0.0, 6.0)));
					wm.setTranslation(Im3d_Randvec3(-10.0, 10.0));
					Im3d_MulMatrix(wm);
					Im3d_BeginTriangles();
						Im3d_Vertex(-1.0,  0.0, -1.0, Im3d_COLOR_RED);
						Im3d_Vertex( 0.0,  2.0, -1.0, Im3d_COLOR_GREEN);
						Im3d_Vertex( 1.0,  0.0, -1.0, Im3d_COLOR_BLUE);
					Im3d_End();
				Im3d_PopMatrix();
			}

			Im3d_SetAlpha(0.9);
			Im3d_SetSize(2.5);
			for (int i = 0; i < primCount / 3 / 3; i += 1)
			{
				Im3d_PushMatrix();
					Mat4 wm(1.0);
					wm.setRotation(Im3d_Rotation(Im3d_Normalize(Im3d_Randvec3(-1.0, 1.0)), Im3d_RandFloat(0.0, 6.0)));
					wm.setTranslation(Im3d_Randvec3(-10.0, 10.0));
					Im3d_MulMatrix(wm);
					Im3d_BeginLineLoop();
						Im3d_Vertex(-1.0,  0.0, -1.0, Im3d_COLOR_MAGENTA);
						Im3d_Vertex( 0.0,  2.0, -1.0, Im3d_COLOR_YELLOW);
						Im3d_Vertex( 1.0,  0.0, -1.0, Im3d_COLOR_CYAN);
					Im3d_End();
				Im3d_PopMatrix();
			}

			Im3d_SetAlpha(0.9);
			Im3d_SetSize(16.0);
			for (int i = 0; i < primCount / 3; i += 1)
			{
				Im3d_PushMatrix();
					Mat4 wm(1.0);
					wm.setTranslation(Im3d_Randvec3(-10.0, 10.0));
					Im3d_MulMatrix(wm);
					Im3d_BeginPoints();
						Im3d_Vertex(-1.0,  0.0, -1.0, Im3d_RandColor(0.0, 1.0));
					Im3d_End();
				Im3d_PopMatrix();
			}
		Im3d_PopDrawState();

		ImGui.TreePop();
	}

	if (ImGui.TreeNode("Layers"))
	{
		// Layers allow primitives to be grouped by the application. Each layer results in a separate call to the draw callback, which gives the 
		// application opportunity to modify the rendering on a per-layer basis (e.g. to enable depth testing). Layers can also be used to 
		// achieve some coarse-grained sorting, as below:

		// Layers are drawn in the order which the application declares them.
		Im3d_PushLayerId("DrawFirst"); Im3d_PopLayerId();
		Im3d_PushLayerId("DrawSecond"); Im3d_PopLayerId();

		Im3d_PushLayerId("DrawSecond");
			Im3d_BeginTriangles();
				Im3d_Vertex(-0.4, 0.0, 0.0, 16.0, Im3d_COLOR_RED);
				Im3d_Vertex( 0.1, 1.0, 0.0, 16.0, Im3d_COLOR_RED);
				Im3d_Vertex( 0.6, 0.0, 0.0, 16.0, Im3d_COLOR_RED);
			Im3d_End();
		Im3d_PopLayerId();
		Im3d_PushLayerId("DrawFirst");
			Im3d_BeginTriangles();
				Im3d_Vertex(-0.6, 0.0, 0.0, 16.0, Im3d_COLOR_MAGENTA);
				Im3d_Vertex(-0.1, 1.0, 0.0, 16.0, Im3d_COLOR_MAGENTA);
				Im3d_Vertex( 0.4, 0.0, 0.0, 16.0, Im3d_COLOR_MAGENTA);
			Im3d_End();
		Im3d_PopLayerId();

		ImGui.TreePop();
	}
	*/


	ImGui.SetNextTreeNodeOpen(true, .Once);
	if (ImGui.TreeNode("Grid"))
	{
		ImGui.SliderInt("Grid Size", *grid_size, 1, 50);
		grid_half := grid_size * 0.5;
		Im3d_SetAlpha(1.0);
		Im3d_SetSize(1.0);
		Im3d_BeginLines();
			for x : 0..grid_size
			{
				Im3d_Vertex(-grid_half, 0.0, cast (float) x - grid_half, Im3d_MakeColor(1.0, 1.0, 1.0));
				Im3d_Vertex( grid_half, 0.0, cast (float) x - grid_half, Im3d_MakeColor(1.0, 1.0, 1.0));
			}
			for z : 0..grid_size
			{
				Im3d_Vertex(cast (float) z - grid_half, 0.0, -grid_half,  Im3d_MakeColor(1.0, 1.0, 1.0));
				Im3d_Vertex(cast (float) z - grid_half, 0.0,  grid_half,  Im3d_MakeColor(1.0, 1.0, 1.0));
			}
		Im3d_End();

		ImGui.TreePop();
	}

	if (ImGui.TreeNode("Camera"))
	{
		ImGui.Checkbox("Ortho", *camera.use_orthographic_projection);
		ImGui.Text("Position: %, %, %", camera.position.x, camera.position.y, camera.position.z);
		ImGui.Text("Direction: %, %, %", camera.direction.x, camera.direction.y, camera.direction.z);

		ImGui.TreePop();
	}

	if (ImGui.TreeNode("Text"))
	{
		ImGui.ColorEdit4("Text Color", text_color.n);

		ImGui.SliderFloat("Text Size", *text_size, 0.0, 4.0, display_format = "%.3f");

		if (ImGui.RadioButton("Align Center (H)", (text_flags & (Im3d_TextFlags.AlignRight | .AlignLeft)) == 0))
		{
			text_flags = (text_flags & ~.AlignRight);
			text_flags = (text_flags & ~.AlignLeft);
		}
		ImGui.SameLine();
		if (ImGui.RadioButton("Align Left", (text_flags & .AlignLeft) != 0))
		{
			text_flags = (text_flags ^ .AlignLeft);
			text_flags = (text_flags & ~.AlignRight);
		}
		ImGui.SameLine();
		if (ImGui.RadioButton("Align Right", (text_flags & .AlignRight) != 0))
		{
			text_flags = (text_flags ^ .AlignRight);
			text_flags = (text_flags & ~.AlignLeft);
		}

		if (ImGui.RadioButton("Align Center (V)", (text_flags & (Im3d_TextFlags.AlignBottom | .AlignTop)) == 0))
		{
			text_flags = (text_flags & ~.AlignBottom);
			text_flags = (text_flags & ~.AlignTop);
		}
		ImGui.SameLine();			
		if (ImGui.RadioButton("Align Top", (text_flags & .AlignTop) != 0))
		{
			text_flags = (text_flags ^ .AlignTop);
			text_flags = (text_flags & ~.AlignBottom);
		}
		ImGui.SameLine();
		if (ImGui.RadioButton("Align Bottom", (text_flags & .AlignBottom) != 0))
		{
			text_flags = (text_flags ^ .AlignBottom);
			text_flags = (text_flags & ~.AlignTop);
		}
		
		text_theta += delta_time * 0.5;
		position := vec3 (Math.cos (text_theta) * 2.0, 0.0, Math.sin (text_theta) * 2.0); 

		Im3d_Text(position, text_size, Im3d_MakeColor (text_color), xx text_flags, "Moving: (%+1.2, %+1.2, %+1.2)", position.x, position.y, position.z);
		Im3d_Text(vec3(0.0, 0.0, 0.0), text_size, Im3d_MakeColor (text_color), xx text_flags, "Hello, text!");

		ImGui.TreePop();
	}

	ImGui.End();

	ImGui.SetNextWindowPos (*window_pos, pivot = *window_pivot);
	ImGui.Begin ("Frame Info", null, ImGui.WindowFlags.NoTitleBar | .NoResize | .NoMove | .NoSavedSettings | .AlwaysAutoResize);
		ImGui.Text ("% fps", 1.0 / delta_time);
		ImGui.Text (cast (string) "Layers:    %", Im3d_GetLayerCount ());
		ImGui.Text (cast (string) "Triangles: %", Im3d_GetPrimitiveCount (.Triangles));
		ImGui.Text (cast (string) "Lines:     %", Im3d_GetPrimitiveCount (.Lines));
		ImGui.Text (cast (string) "Points:    %", Im3d_GetPrimitiveCount (.Points));
		ImGui.Text (cast (string) "Texts:     %", Im3d_GetTextCount ());
	ImGui.End();
}
