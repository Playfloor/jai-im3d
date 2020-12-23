#import "Basic";
#import "Compiler";
#import "String";
#import "Process";
#import "File";
#import "File_Utilities";

build :: ()
{
	set_working_directory (#filepath);
	build_options := get_build_options ();
	build_options.output_type = .NO_OUTPUT;
	set_build_options (build_options);

	workspace := compiler_create_workspace ();
	executable_name := "im3d_example";

	#if OS == .WINDOWS
	{
		build_dir := "bin/win/";
		output_filename := join (executable_name, ".exe");
		executable_path := join (build_dir, executable_name, ".exe");
	}
	else #if OS == .LINUX
	{
		build_dir := "bin/linux/";
		output_filename := executable_name;
		executable_path := join (build_dir, executable_name);
	}

	build_options.output_type             = .EXECUTABLE;
	build_options.output_executable_name  = executable_name;
	build_options.output_path             = build_dir;
	array_add (*build_options.modules_search_path_array, "../../");

	run_on_success := false;
	debugging      := false;
	args           := compiler_get_command_line_arguments ();

	for args
	{
		if it == 
		{
		case "run";   run_on_success = true;
		case "debug"; debugging = true;
		case;         print ("Unknown argument: '%'\n", it);
		}
	}

	if debugging then build_options.backend = .LLVM;
	else              build_options.backend = .X64;

	set_build_options (build_options, workspace);
	make_directory_if_it_does_not_exist (build_dir);
	build_success := false;
	compiler_begin_intercept (workspace);
	add_build_file ("main.jai", workspace);

	build_complete := false;
	while !build_complete
	{
		message := compiler_wait_for_message ();

		if message.kind ==
		{
		case .COMPLETE;
			build_complete = true;
			build_success = (cast (*Compiler_Message_Complete) message).error_code == .NONE;
		}
	}

	compiler_end_intercept (workspace);

	set_working_directory (build_dir);
	
	if build_success && run_on_success
	{
		print ("Running '%'...\n", output_filename);
		os_run_command (output_filename);
	}
	else if !build_success
	{
		print ("Failed to compile %\n", workspace);
	}
}

#run build ();
