#import "Windowing";
#import "Im3d";
#import "Utf8";
#import "Linalg";
#import "Basic";
#import "String";
Math :: #import "Math";

#load "example_opengl.jai";
#load "teapot.jai";

  RIGHT_VECTOR :: Vec3.{ 1, 0,  0 };
     UP_VECTOR :: Vec3.{ 0, 1,  0 };
FORWARD_VECTOR :: Vec3.{ 0, 0, -1 };

running : bool;
window  : Window;
camera  : Camera;
previous_cursor_position : Vec2;
current_cursor_position  : Vec2;

Camera :: struct
{
	use_orthographic_projection : bool;
	position                    : Vec3;
	direction                   := FORWARD_VECTOR;
	viewport_w, viewport_h      : int;
	fov_in_degrees              : float;
	transform                   : Mat4;
	projection_matrix           : Mat4;
	view_projection_matrix      : Mat4;
}

calculate_camera_matrices :: (using camera : *Camera)
{
	transform = make_look_at_matrix (position, position - direction);
	view := transform;
	inverse (*view);

	aspect_ratio := viewport_w / cast (float) viewport_h;

	if use_orthographic_projection
	{
		projection_matrix = make_orthographic_projection_matrix (-5 * aspect_ratio, 5 * aspect_ratio, -5, 5, 0.1, 500.0);
	}
	else
	{
		projection_matrix = make_perspective_projection_matrix (fov_in_degrees, aspect_ratio, 0.1, 500.0);
	}

	view_projection_matrix = projection_matrix * view;
}

update_camera :: (using camera : *Camera, delta_time : float)
{
	viewport_w, viewport_h = get_window_framebuffer_size (*window);
	move_speed := 2.0;
	rotation_speed := 100.0;

	if is_window_focused (*window)
	{
		if is_key_down (.LEFT_SHIFT) then move_speed *= 10.0;
		if ! is_key_down (.CONTROL)
		{
			if is_key_down (.W) then position -= get_forward_vector (transform) * (delta_time * move_speed);
			if is_key_down (.S) then position += get_forward_vector (transform) * (delta_time * move_speed);
			if is_key_down (.D) then position += get_right_vector   (transform) * (delta_time * move_speed);
			if is_key_down (.A) then position -= get_right_vector   (transform) * (delta_time * move_speed);
			if is_key_down (.E) then position += get_up_vector      (transform) * (delta_time * move_speed);
			if is_key_down (.Q) then position -= get_up_vector      (transform) * (delta_time * move_speed);
		}
	}

	if is_window_focused (*window)
	{
		if is_mouse_button_down (.RIGHT)
		{
			cursor_delta := vec2 ((current_cursor_position.x - previous_cursor_position.x) / cast (float) viewport_w,
				                  (current_cursor_position.y - previous_cursor_position.y) / cast (float) viewport_h) * rotation_speed;
			direction = make_rotation_matrix3 (UP_VECTOR, to_radians (-cursor_delta.x)) * direction;
			direction = make_rotation_matrix3 (get_right_vector (transform), to_radians (-cursor_delta.y)) * direction;
		}
	}
 
	if is_key_pressed (.R) && !is_key_down (.CONTROL) then direction = -position;
	if is_key_pressed (.O) && !is_key_down (.CONTROL) then use_orthographic_projection = !use_orthographic_projection;

	calculate_camera_matrices (camera);
}

handle_event :: (using event : Event)
{
	if type ==
	{
	case .WINDOW_CLOSE; running = false;
	}
}

main :: ()
{
	init_window (*window, "Im3d OpenGL Example", 100, 100, 1280, 720, null, handle_event);
	make_window_context_current (*window);
	running = im3d_init ();
	if !running then println ("Failed to initialize Im3d.");
	show_window (*window);

	glClearColor (.2, .2, .2, 1);
	
	camera.position       = vec3 (0, 2, 3);
	camera.direction      = get_normalized (vec3 (0, -.5, -1));
	camera.fov_in_degrees = 50;
	calculate_camera_matrices (*camera);
	current_time := cast (float) get_time ();

	struct
	{
		transforms  : [9]Mat4;
		#place transforms;
		quad_transform     : Mat4;
		circle_transform   : Mat4;
		sphere_transform   : Mat4;
		aabb_transform     : Mat4;
		teapot_transform   : Mat4;
		cylinder_transform : Mat4;
		capsule_transform  : Mat4;
		prism_transform    : Mat4;
		arrow_transform    : Mat4;
	};

	for i : 0..transforms.count - 1
	{
		x := i - (transforms.count - 1) / 2.0;
		transforms[i] = make_translation_matrix (vec3 (x * 3 , 0, 0));
	}

	while running
	{
		poll_window_events (*window);
		
		previous_cursor_position = current_cursor_position;
		cursor_x, cursor_y := get_cursor_position (*window);
		current_cursor_position = vec2 (xx cursor_x, xx cursor_y);

		previous_time := current_time;
		current_time = cast (float) get_time ();
		delta_time := current_time - previous_time;

		viewport_width, viewport_height := get_window_framebuffer_size (*window);

		update_camera (*camera, delta_time);

		glViewport (0, 0, xx viewport_width, xx viewport_height);
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		im3d_new_frame (delta_time);

		GRID_SIZE :: 50;
		grid_half := GRID_SIZE * 0.5;
		Im3d_PushAlpha (1.0);
		Im3d_PushSize (1.0);
		Im3d_BeginLines ();
			for x : 0..GRID_SIZE
			{
				Im3d_Vertex (-grid_half, 0.0, cast (float) x - grid_half, Im3d_MakeColor (1.0, 1.0, 1.0));
				Im3d_Vertex ( grid_half, 0.0, cast (float) x - grid_half, Im3d_MakeColor (1.0, 1.0, 1.0));
			}
			for z : 0..GRID_SIZE
			{
				Im3d_Vertex (cast (float) z - grid_half, 0.0, -grid_half,  Im3d_MakeColor (1.0, 1.0, 1.0));
				Im3d_Vertex (cast (float) z - grid_half, 0.0,  grid_half,  Im3d_MakeColor (1.0, 1.0, 1.0));
			}
		Im3d_End ();
		Im3d_PopSize ();
		Im3d_PopAlpha ();
		
		SHAPE_THICKNESS :: 3;

		Im3d_PushColor (IM3D_COLOR_YELLOW);
			Im3d_Gizmo (Im3d_MakeId ("QuadGizmo"), *quad_transform);
			Im3d_PushMatrix (quad_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawQuad (vec3 (0.0), vec3 (0.0, 0.0, 1.0), VEC2_ONE);
			Im3d_PopMatrix (); Im3d_PopSize ();

			Im3d_Gizmo (Im3d_MakeId ("CircleGizmo"), *circle_transform);
			Im3d_PushMatrix (circle_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawCircle (vec3 (0.0), vec3 (0.0, 0.0, 1.0), 1, detail = 25);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("SphereGizmo"), *sphere_transform);
			Im3d_PushMatrix (sphere_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawSphere (vec3 (0.0), 1, detail = 25);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("AABBGizmo"), *aabb_transform);
			Im3d_PushMatrix (aabb_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawAlignedBox (-VEC3_ONE, VEC3_ONE);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("CylinderGizmo"), *cylinder_transform);
			Im3d_PushMatrix (cylinder_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawCylinder (vec3 (0.0, -1, 0.0), vec3 (0.0, 1, 0.0), 1, detail = 25);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("CapsuleGizmo"), *capsule_transform);
			Im3d_PushMatrix (capsule_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawCapsule (vec3 (0.0, -1, 0.0), vec3 (0.0, 1, 0.0), 1, detail = 25);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("PrismGizmo"), *prism_transform);
			Im3d_PushMatrix (prism_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawPrism (vec3 (0.0, -1, 0.0), vec3 (0.0, 1, 0.0), 1, 3);
			Im3d_PopMatrix (); Im3d_PopSize ();
			
			Im3d_Gizmo (Im3d_MakeId ("ArrowGizmo"), *arrow_transform);
			Im3d_PushMatrix (arrow_transform);
			Im3d_PushSize (SHAPE_THICKNESS);
				Im3d_DrawArrow (vec3 (0.0), vec3 (0.0, 1, 0.0), 0.1, 10);
			Im3d_PopMatrix (); Im3d_PopSize ();
		Im3d_PopColor ();
		
		Im3d_Gizmo (Im3d_MakeId ("TeapotGizmo"), *teapot_transform);
		draw_teapot (teapot_transform, camera.view_projection_matrix);

		im3d_end_frame ();

		swap_window_buffers (*window);
	}

	im3d_terminate ();
}

sign :: inline (val : $T) -> T
{
	     if val < 0 then return -1;
	else if val > 0 then return 1;

	return 0;
}

abs :: inline (val : $T) -> T
{
	if val < 0 then return -val;

	return val;
}

print :: inline (val : $T)
{
	print ("%", val);
}

println :: inline (val : $T)
{
	print ("%\n", val);
}

println :: inline (fmt : string, args : ..Any)
{
	print (fmt, ..args);
	print ("\n");
}

tprintz :: (format_string: string, args: .. Any) -> string {
    builder: String_Builder;
    builder.allocator = __temporary_allocator;
    defer free_buffers(*builder);
    
    print_to_builder(*builder, format_string, ..args);
	print_to_builder(*builder, "\0");

    return builder_to_string(*builder, __temporary_allocator, null);
} @PrintLike
