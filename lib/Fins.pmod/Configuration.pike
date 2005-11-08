
static mapping values;

//!
static void create(string config_file)
{
	string fc = Stdio.read_file(config_file);
	
	// the "spec" says that the file is utf-8 encoded.
	fc=utf8_to_string(fc);
	
	values = Public.Tools.ConfigFiles.Config.read(fc);
}

//! returns a string containing the first occurrance of a configuration 
//! variable item in configuration section "section".
string get_value(string section, string item)
{
  string val;

  if(!values[section])
  {
    throw(Error.Generic("Unable to find configuration section " + section + ".\n"));
  }

  else if(!values[section][item] && zero_type(values[section][item]))
  {
    throw(Error.Generic("Item " + item + " in configuration section " + section + " does not exist.\n"));
  }

  else if(arrayp(values[section][item])
  {
    return values[section][item][0];
  }
  
  else return values[section][item];
}


//! returns an array containing all occurrances of a configuration 
//! variable item in configuration section "section".
array get_value_array(string section, string item)
{
  array val;

  if(!values[section])
  {
    throw(Error.Generic("Unable to find configuration section " + section + ".\n"));
  }

  else if(!values[section][item] && zero_type(values[section][item]))
  {
    throw(Error.Generic("Item " + item + " in configuration section " + section + " does not exist.\n"));
  }

  else if(arrayp(values[section][item])
  {
    values[section][item];
  }
  
  else return ({ values[section][item] }); 
}
