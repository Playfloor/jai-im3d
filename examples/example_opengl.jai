#import "GL";

#scope_file

vao, vbo : u32;
points_spo, lines_spo, triangles_spo : u32;

teapot : struct
{
	vao, vbo, ibo : u32;
	spo : u32;
};

#scope_export

im3d_init :: () -> bool
{
	gl_load (*gl, get_gl_proc_address);

	points_spo    = create_gl_shader_program (false, SHADER_SOURCE, "#define POINTS");
	if points_spo == 0 then return false;
	lines_spo     = create_gl_shader_program (true,  SHADER_SOURCE, "#define LINES");
	if lines_spo == 0 then return false;
	triangles_spo = create_gl_shader_program (false, SHADER_SOURCE, "#define TRIANGLES");
	if triangles_spo == 0 then return false;

	glGenBuffers (1, *vbo);
	glGenVertexArrays (1, *vao);
	glBindVertexArray (vao);
	glBindBuffer (GL_ARRAY_BUFFER, vbo);
	glEnableVertexAttribArray (0);
	glVertexAttribPointer (0, 4, GL_FLOAT, GL_FALSE, size_of (Im3d_VertexData), cast (*void) offset_of (Im3d_VertexData, "positionSize"));
	glEnableVertexAttribArray (1);
	glVertexAttribPointer (1, 4, GL_UNSIGNED_BYTE, GL_TRUE, size_of (Im3d_VertexData), cast (*void) offset_of (Im3d_VertexData, "color"));
	glBindVertexArray (0);

	glGenVertexArrays (1, *teapot.vao);
	glGenBuffers (1, *teapot.vbo);
	glGenBuffers (1, *teapot.ibo);
	glBindVertexArray (teapot.vao);
	glBindBuffer (GL_ARRAY_BUFFER, teapot.vbo);
	glBufferData (GL_ARRAY_BUFFER, size_of (float) * TEAPOT_VERTICES.count, TEAPOT_VERTICES.data, GL_STATIC_DRAW);
	glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, teapot.ibo);
	glBufferData (GL_ELEMENT_ARRAY_BUFFER, size_of (u32) * TEAPOT_INDICES.count, TEAPOT_INDICES.data, GL_STATIC_DRAW);
	// Vertex position
	glEnableVertexAttribArray (0);
	glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 2 * size_of (Vec3), cast (*void) 0);
	// Vertex normal
	glEnableVertexAttribArray (1);
	glVertexAttribPointer (1, 3, GL_FLOAT, GL_FALSE, 2 * size_of (Vec3), cast (*void) size_of (Vec3));
	teapot.spo = create_gl_shader_program (false, MODEL_SHADER_SOURCE, "");
	if teapot.spo == 0 then return false;

	return true;
}

im3d_terminate :: ()
{
	glDeleteBuffers (1, *vbo);
	glDeleteVertexArrays (1, *vao);
	glDeleteProgram (triangles_spo);
	glDeleteProgram (lines_spo);
	glDeleteProgram (points_spo);
	destroy_window (*window);
}

im3d_new_frame :: (delta_time : float)
{
	data := Im3d_GetAppData ();
	data.deltaTime = delta_time;
	data.viewportSize = vec2 (xx camera.viewport_w, xx camera.viewport_h);
	data.viewOrigin = camera.position;
	data.viewDirection = camera.direction;
	data.worldUp = UP_VECTOR;
	data.projOrtho = camera.use_orthographic_projection;

	if camera.use_orthographic_projection then data.projScaleY = 2.0 / camera.projection_matrix.n22;
	else                                       data.projScaleY = 2.0 * Math.tan (to_radians (camera.fov_in_degrees) * 0.5);

	cursor_x, cursor_y := get_cursor_position (*window);
	cursor_position := vec2 (cursor_x / data.viewportSize.x - .5, cursor_y / data.viewportSize.y - .5) * 2;
	cursor_position.y = -cursor_position.y;
	ray_origin, ray_direction : Vec3;

	if camera.use_orthographic_projection
	{
		ray_origin.x  = cursor_position.x / camera.projection_matrix.n11;
		ray_origin.y  = cursor_position.y / camera.projection_matrix.n22;
		ray_origin.z  = 0.0;
		ray_origin    = vec3 (camera.transform * vec4 (ray_origin, 1.0));
		ray_direction = vec3 (camera.transform * vec4 (0.0, 0.0, -1.0, 0.0));
	}
	else
	{
		ray_origin       = data.viewOrigin;
		ray_direction.x  = cursor_position.x / camera.projection_matrix.n11;
		ray_direction.y  = cursor_position.y / camera.projection_matrix.n22;
		ray_direction.z  = -1.0;
		ray_direction    = vec3 (camera.transform * vec4 (get_normalized (ray_direction), 0.0));
	}

	data.cursorRayOrigin = ray_origin;
	data.cursorRayDirection = ray_direction;

	Im3d_AppData_SetCullFrustum (data, camera.view_projection_matrix, true);

	data.keyDown[Im3d_Key.Select] = is_mouse_button_down (.LEFT);

	ctrl_down := is_key_down (.CONTROL);
	data.keyDown[Im3d_Key.GizmoLocal]       = ctrl_down && is_key_down (.L);
	data.keyDown[Im3d_Key.GizmoTranslation] = ctrl_down && is_key_down (.T);
	data.keyDown[Im3d_Key.GizmoRotation]    = ctrl_down && is_key_down (.R);
	data.keyDown[Im3d_Key.GizmoScale]       = ctrl_down && is_key_down (.S);

	if ctrl_down
	{
		data.snapTranslation = 0.5;
		data.snapRotation    = to_radians (30.0);
		data.snapScale       = 0.5;
	}
	else
	{
		data.snapTranslation = 0.0;
		data.snapRotation    = 0.0;
		data.snapScale       = 0.0;
	}

	Im3d_NewFrame ();
}

im3d_end_frame :: ()
{
	Im3d_EndFrame ();

	glEnable (0x8861);		// GL_POINT_SPRITE
	glEnable (GL_PROGRAM_POINT_SIZE);
	glEnable (GL_BLEND);
	glBlendEquation (GL_FUNC_ADD);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	draw_lists := Im3d_GetDrawLists ();

	for draw_list : draw_lists
	{
		primitive : GLenum;
		spo : GLuint;
		if draw_list.primType ==
		{
		case .Points;
			primitive = GL_POINTS;
			spo = points_spo;
			glDisable (GL_CULL_FACE);

		case .Lines;
			primitive = GL_LINES;
			spo = lines_spo;
			glDisable (GL_CULL_FACE);

		case .Triangles;
			primitive = GL_TRIANGLES;
			spo = triangles_spo;
		}

		glBindVertexArray (vao);
		glBindBuffer (GL_ARRAY_BUFFER, vbo);
		glBufferData (GL_ARRAY_BUFFER, draw_list.vertexCount * size_of (Im3d_VertexData), draw_list.vertexData, GL_STREAM_DRAW);

		app_data := Im3d_GetAppData ();
		glUseProgram (spo);
		glUniform2f (glGetUniformLocation (spo, "u_Viewport"), app_data.viewportSize.x, app_data.viewportSize.y);
		glUniformMatrix4fv (glGetUniformLocation (spo, "u_View_Projection_Matrix"), 1, GL_FALSE, *camera.view_projection_matrix.n11);
		glDrawArrays (primitive, 0, xx draw_list.vertexCount);
	}
	
	glBindBuffer (GL_ARRAY_BUFFER, 0);
	glBindVertexArray (0);
	glUseProgram (0);
	glDisable (GL_BLEND);
	glDisable (GL_PROGRAM_POINT_SIZE);
	glDisable (0x8861);		// GL_POINT_SPRITE
}

draw_teapot :: (transform : Mat4, view_projection_matrix : Mat4)
{
	glUseProgram (teapot.spo);
	glUniformMatrix4fv (glGetUniformLocation (teapot.spo, "u_Transform_Matrix"), 1, GL_FALSE, *transform.n11);
	glUniformMatrix4fv (glGetUniformLocation (teapot.spo, "u_View_Projection_Matrix"), 1, GL_FALSE, *view_projection_matrix.n11);
	glBindVertexArray (teapot.vao);
	glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, teapot.ibo);
	glBindBuffer (GL_ARRAY_BUFFER, teapot.vbo);
	glEnable (GL_DEPTH_TEST);
	glEnable (GL_CULL_FACE);

	glDrawElements (GL_TRIANGLES, TEAPOT_INDICES.count, GL_UNSIGNED_INT, null);
	
	glDisable (GL_CULL_FACE);
	glDisable (GL_DEPTH_TEST);
	glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer (GL_ARRAY_BUFFER, 0);
	glBindVertexArray (0);
	glUseProgram (0);
}

#scope_file

create_gl_shader_program :: ($has_geometry_stage : bool, shader_source : string, header : string) -> u32
{
	vertex_shader_source := tprintz (shader_source, "#define VERTEX_SHADER", header);
	#if has_geometry_stage  geometry_shader_source := tprintz (shader_source, "#define GEOMETRY_SHADER", header);
	fragment_shader_source := tprintz (shader_source, "#define FRAGMENT_SHADER", header);

	status : GLint;
	info_log : [4096]u8;

	vertex_shader := glCreateShader (GL_VERTEX_SHADER);
	defer glDeleteShader (vertex_shader);
	glShaderSource (vertex_shader, 1, *vertex_shader_source.data, null);
	glCompileShader (vertex_shader);
	glGetShaderiv (vertex_shader, GL_COMPILE_STATUS, *status);

	if status == 0
	{
		glGetShaderInfoLog (vertex_shader, info_log.count, null, info_log.data);
		println ("GL: Failed to compile vertex shader:\n%", cast (string) cast ([]u8) info_log);

		return 0;
	}

	#if has_geometry_stage
	{
		geometry_shader := glCreateShader (GL_GEOMETRY_SHADER);
		defer glDeleteShader (geometry_shader);
		glShaderSource (geometry_shader, 1, *geometry_shader_source.data, null);
		glCompileShader (geometry_shader);
		glGetShaderiv (geometry_shader, GL_COMPILE_STATUS, *status);

		if status == 0
		{
			glGetShaderInfoLog (geometry_shader, info_log.count, null, info_log.data);
			println ("GL: Failed to compile geometry shader:\n%", cast (string) cast ([]u8) info_log);

			return 0;
		}
	}

	fragment_shader := glCreateShader (GL_FRAGMENT_SHADER);
	defer glDeleteShader (fragment_shader);
	glShaderSource (fragment_shader, 1, *fragment_shader_source.data, null);
	glCompileShader (fragment_shader);
	glGetShaderiv (fragment_shader, GL_COMPILE_STATUS, *status);

	if status == 0
	{
		glGetShaderInfoLog (fragment_shader, info_log.count, null, info_log.data);
		println ("GL: Failed to compile fragment shader:\n%", cast (string) cast ([]u8) info_log);

		return 0;
	}

	shader_program := glCreateProgram ();
	glAttachShader (shader_program, vertex_shader);
	#if has_geometry_stage  glAttachShader (shader_program, geometry_shader);
	glAttachShader (shader_program, fragment_shader);
	glLinkProgram (shader_program);
	glGetProgramiv (shader_program, GL_LINK_STATUS, *status);

	if status == 0
	{
		glGetProgramInfoLog (shader_program, info_log.count, null, info_log.data);
		println ("GL: Failed to link shader program:\n%", cast (string) cast ([]u8) info_log);

		return 0;
	}

	return shader_program;
}

SHADER_SOURCE :: #string END
#version 330

%
%

#if !defined (POINTS) && !defined (LINES) && !defined (TRIANGLES)
	#error No primitive type defined
#endif
#if !defined (VERTEX_SHADER) && !defined (GEOMETRY_SHADER) && !defined (FRAGMENT_SHADER)
	#error No shader stage defined
#endif

#define Vertex_Data\
	_Vertex_Data\
	{\
		noperspective float edge_distance;\
		noperspective float size;\
		smooth        vec4  color;\
	}

#define ANTIALIASING 2.0

#ifdef VERTEX_SHADER
	layout (location = 0) in vec4 a_Position_Size;
	layout (location = 1) in vec4 a_Color;

	uniform mat4 u_View_Projection_Matrix;

	out Vertex_Data Data;

	void main ()
	{
		Data.color = a_Color.abgr;
		#if !defined (TRIANGLES)
			Data.color.a *= smoothstep (0.0, 1.0, a_Position_Size.w / ANTIALIASING);
		#endif
		Data.size = max (a_Position_Size.w, ANTIALIASING);
		gl_Position = u_View_Projection_Matrix * vec4 (a_Position_Size.xyz, 1.0);
		#if defined (POINTS)
			gl_PointSize = Data.size;
		#endif
	}
#endif

#ifdef GEOMETRY_SHADER
	uniform vec2 u_Viewport;

	layout (lines) in;
	layout (triangle_strip, max_vertices = 4) out;

	in  Vertex_Data Data_Input[];
	out Vertex_Data Data_Output;

	void main ()
	{
		vec2 pos0 = gl_in[0].gl_Position.xy / gl_in[0].gl_Position.w;
		vec2 pos1 = gl_in[1].gl_Position.xy / gl_in[1].gl_Position.w;

		vec2 dir = pos0 - pos1;
		dir = normalize (vec2 (dir.x, dir.y * u_Viewport.y / u_Viewport.x));
		vec2 tng0 = vec2 (-dir.y, dir.x);
		vec2 tng1 = tng0 * Data_Input[1].size / u_Viewport;
		tng0 = tng0 * Data_Input[0].size / u_Viewport;

		gl_Position = vec4 ((pos0 - tng0) * gl_in[0].gl_Position.w, gl_in[0].gl_Position.zw);
		Data_Output.edge_distance = -Data_Input[0].size;
		Data_Output.size          =  Data_Input[0].size;
		Data_Output.color         =  Data_Input[0].color;
		EmitVertex ();

		gl_Position = vec4 ((pos0 + tng0) * gl_in[0].gl_Position.w, gl_in[0].gl_Position.zw);
		Data_Output.edge_distance = Data_Input[0].size;
		Data_Output.size          = Data_Input[0].size;
		Data_Output.color         = Data_Input[0].color;
		EmitVertex ();

		gl_Position = vec4 ((pos1 - tng1) * gl_in[1].gl_Position.w, gl_in[1].gl_Position.zw);
		Data_Output.edge_distance = -Data_Input[1].size;
		Data_Output.size          =  Data_Input[1].size;
		Data_Output.color         =  Data_Input[1].color;
		EmitVertex ();

		gl_Position = vec4 ((pos1 + tng1) * gl_in[1].gl_Position.w, gl_in[1].gl_Position.zw);
		Data_Output.edge_distance = Data_Input[1].size;
		Data_Output.size          = Data_Input[1].size;
		Data_Output.color         = Data_Input[1].color;
		EmitVertex ();
	}
#endif

#ifdef FRAGMENT_SHADER
	in Vertex_Data Data;

	layout (location = 0) out vec4 Frag_Color;

	void main ()
	{
		Frag_Color = Data.color;

		#if defined (LINES)
			float d = abs (Data.edge_distance) / Data.size;
			d = smoothstep (1.0, 1.0 - (ANTIALIASING / Data.size), d);
			Frag_Color.a *= d;
		#elif defined (POINTS)
			float d = length (gl_PointCoord.xy - vec2 (0.5, 0.5));
			d = smoothstep (0.5, 0.5 - (ANTIALIASING / Data.size), d);
			Frag_Color.a *= d;
		#endif
	}
#endif
END

MODEL_SHADER_SOURCE :: #string END
#version 330 core

%

#ifdef VERTEX_SHADER
	layout (location = 0) in vec3 a_Position;
	layout (location = 1) in vec3 a_Normal;

	uniform mat4 u_Transform_Matrix;
	uniform mat4 u_View_Projection_Matrix;

	smooth out vec3 Normal;

	void main ()
	{
		Normal = mat3 (u_Transform_Matrix) * a_Normal;
		gl_Position = u_View_Projection_Matrix * u_Transform_Matrix * vec4 (a_Position, 1.0);
	}
#endif

#ifdef FRAGMENT_SHADER
	smooth in vec3 Normal;

	layout (location = 0) out vec3 Frag_Color;

	void main ()
	{
		vec3 normal = normalize (Normal);
		vec3 light_dir = normalize (vec3 (1.0, 1.0, 1.0));
		float intensity = max (dot (normal, light_dir), 0.0) * 0.5;
		Frag_Color = vec3 (intensity);
	}
#endif
END

#import "Basic";

offset_of :: inline ($T : Type, $member : string) -> s64
{
	#insert #run sprint (BODY, member);

	BODY :: #string DONE
		dummy : T = ---;
		
		return cast (*void) (*dummy.%) - cast (*void) *dummy;
	DONE
}
