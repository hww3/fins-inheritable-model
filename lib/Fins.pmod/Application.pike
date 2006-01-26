import Tools.Logging;

//! this is the base application class.

//!
.FinsController controller;

//!
.FinsModel model;

//!
.FinsView view;

//!
.FinsCache cache;

//!
string static_dir;

//!
.Configuration config;

//!
static void create(.Configuration _config)
{
   config = _config;
   static_dir = Stdio.append_path(config->app_dir, "static");
   
   load_cache();
   load_model();
   load_view();
   load_controller();

   start();
}

//!
void start()
{
	
}

static void load_cache()
{
  werror("Starting Cache...\n");

  cache = .FinsCache();
}

static void load_view()
{
  string viewclass = (config["view"] ? config["view"]["class"] :0);
  if(viewclass)
    view = ((program)viewclass)(this);
  else Log.debug("No view defined!");
}

static void load_controller()
{
  string conclass = (config["controller"]? config["controller"]["class"] :0);
  if(conclass)
    controller = ((program)conclass)(this);
  else Log.debug("No controller defined!");
}

static void load_model()
{
  string modclass = (config["model"] ? config["model"]["class"] : 0);
  if(modclass)
    model = ((program)modclass)(this);
  else Log.debug("No model defined!");
}

//!
public mixed handle_request(.Request request)
{
  function event;

  request->fins_app = this;

  Log.info("SESSION INFO: %O", request->misc->session_variables);

  // we have to short circuit this one...
  if(request->not_query == "/favicon.ico")
  {
    request->not_query = "/static/favicon.ico";
    return static_request(request)->get_response();
  }

  if(has_prefix(request->not_query, "/static/"))
  {
    return static_request(request)->get_response();
  }

  array x = get_event(request);
  if(sizeof(x)>=1)
    event = x[0];

  array args = ({});

  if(sizeof(x)>1)
   args = x[1..];

  .Response response = .Response(request);

  if(objectp(event) || functionp(event))
    event(request, response, @args);

  else response->set_data("Unknown event: %O\n", request->not_query);

  return response->get_response();
}

//!
array get_event(.Request request)
{
  .FinsController cc = controller;
  function event;
  array args = ({});

  array r = request->not_query/"/";

  // first, let's find the right function to call.
  foreach(r; int i; string comp)
  {
    if(!strlen(comp))
    {
      // ok, the last component was a slash.
      // that means we should call the index method in 
      // the current controller.
      if((i+1) == sizeof(r))
      {
         if(event)
         {
           werror("undefined situation! we have to fix this.\n");
         }
         else if(cc && cc["index"])
         {
           event = cc["index"];
         }
         else
         {
            werror("cc: %O\n", cc);
         }
         break;
      }
      else
      {
        // what should we do?
        if(event)
        {
          args+=({comp});
        }
      }
    }

    // ok, the component was not empty.
    else
    {
      if(event)
      {
        args+=({comp});
      }
      else if(cc && cc[comp] && functionp(cc[comp]))
      {
        event = cc[comp];
      }
      else if(cc && cc[comp] && objectp(cc[comp]))
      {
        if(Program.implements(object_program(cc[comp]), Fins.Helpers.Runner))
        {
          event = cc[comp];
        }    
        else if(Program.implements(object_program(cc[comp]), Fins.FinsController))
        {
          cc = cc[comp];
        }    
        else
        {
          throw(Error.Generic("Component " + comp + " is not a Controller.\n"));
        }
      }
      else if(cc && cc["index"])
      {
         event = cc["index"];
         args += ({comp});
      }
      else
      {
        throw(Error.Generic("Component " + comp + " does not exist.\n"));
      }
    }
  }

//  werror("got to end of path; current controller: %O, event: %O, args: %O\n", cc, event, args);

  // we got all this way without an event.
  if(!event && r[-1] != "")
  {
    event = lambda(.Request request, .Response response, mixed ... args)
    {
      response->redirect(request->not_query + "/");
    };
  }

  if(sizeof(args))
    return ({event, @args});
 
  else return ({event});

}

//!
.Response static_request(.Request request)
{
  .Response response = .Response();
  string fn = Stdio.append_path(static_dir, request->not_query[7..]);
  Stdio.Stat stat = file_stat(fn);
  if(!stat || stat->isdir)
  {
    response->not_found(request->not_query);
    return response;
  }

  if(request->request_headers["if-modified-since"] && 
      Protocols.HTTP.Server.http_decode_date(request->request_headers["if-modified-since"]) 
        > stat->mtime) 
  {
    response->not_modified();
    return response;
  }

  response->set_header("Cache-Control", "max-age=7200");
  response->set_type(Protocols.HTTP.Server.filename_to_type(basename(fn)));
  response->set_file(Stdio.File(fn));

  return response;
}
