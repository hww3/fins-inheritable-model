Fins.Application load_app(string app_dir, string config_name)
{
  string cn;
  Fins.Application a;

  if(!file_stat(app_dir)) 
    throw(Error.Generic("Application directory " + app_dir + " does not exist.\n"));

  add_program_path(app_dir + "/classes"); 

  cd(app_dir);

  Fins.Configuration config = load_configuration(config_name);

  program p;

  add_constant("app", a);

  cn = "application";
  p = (program)(cn);

  a = p(config);

  return a;
}

Fins.Configuration load_configuration(string config_name)
{
	string config_file = combine_path("config", config_name+".cfg");

//	werror("config file: " + config_file + "\n");

   Stdio.Stat stat = file_stat(config_file);
	if(!stat || stat->isdir)
		throw(Error.Generic("Unable to load configuration file " + config_file + "\n"));
		
  	return Fins.Configuration(config_file);
}
