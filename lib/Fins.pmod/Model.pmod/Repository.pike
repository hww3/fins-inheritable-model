mapping(string:.DataObject) object_definitions = ([]);
mapping(program:.DataObject) program_definitions = ([]);
mapping(string:program) instance_definitions = ([]);
static mapping(object:object) scaffold_controllers = ([]);
static object model_module;
static object object_module;

object log = Tools.Logging.get_logger("model");

object Objects = objects(this);

private .DataModelContext default_context;

class objects(object repository)
{
  mixed `[](mixed a)
  {
    if(instance_definitions[a]) return instance_definitions[a];
    else throw(Error.Generic("unknown object type " + a + ".\n"));
  }
}

function(void|.DataModelContext,string|program|object,mapping,void|.Criteria:array) _find = old_find;

.DataModelContext get_default_context()
{
   return default_context;
}

void set_default_context(.DataModelContext c)
{
	default_context = c;
}

//!
array old_find(void|.DataModelContext context, string|program|object ot, mapping qualifiers, void|.Criteria criteria)
{
   object o;
   if(!objectp(ot))
     o = get_object(ot);
   else
     o = ot;
   if(!o) throw(Error.Generic("Object type " + ot + " does not exist.\n"));
   if(!context) context = get_default_context();
   return get_instance(o->instance_name)(UNDEFINED)->find(qualifiers, criteria, context);
}

//!
object get_model_module()
{ 
  return model_module;
}

//!
object get_object_module()
{
  return object_module;
}

//! called in Fins.FinsModel.
void set_model_module(object o)
{
  model_module = o;
}

//! called in Fins.FinsModel.
void set_object_module(object o)
{
  object_module = o;
}

//!
.DataObject get_object(string|program name)
{
  if(programp(name))
   return program_definitions[name];
  else
   return object_definitions[name];
}

//!
program get_instance(string name)
{
   return instance_definitions[name];
}

//!
void add_object_type(.DataObject t, program i)
{
   log->debug("adding type def: %O", t->instance_name);
   object_definitions[t->instance_name] = t;
   program_definitions[object_program(t)] = t;
   instance_definitions[t->instance_name] = i;
}

//!
object get_scaffold_controller(object model_component)
{
 // werror("get_scaffold_controller(%O) in %O\n", model_component, scaffold_controllers);

  return scaffold_controllers[model_component];
}

//!
void set_scaffold_controller(object model_component, object controller)
{
   scaffold_controllers[model_component] = controller;
}

//!
array find_all(void|.DataModelContext context, string|object ot)
{

  return old_find(context, ot, ([]));
}

// find() is in module.pmod.

//!
.DataObjectInstance find_by_id(void|.DataModelContext context, string|program|object ot, int id)
{
   object o;
   if(!objectp(ot))
     o = get_object(ot);
   else
     o = ot;
   if(!o) throw(Error.Generic("Object type " + ot + " does not exist.\n"));
   return  get_instance(o->instance_name)(id, context);
}

//!
array find_by_query(void|.DataModelContext context, string|program|object ot, string query)
{
   object o;
   if(!objectp(ot))
     o = get_object(ot);
   else
     o = ot;
   if(!o) throw(Error.Generic("Object type " + ot + " does not exist.\n"));

   return old_find(context, o, (["0": Fins.Model.Criteria(query)]));
}

//!
.DataObjectInstance find_by_alternate(void|.DataModelContext context, string|program|object ot, mixed id)
{
   object o;
   if(!objectp(ot))
     o = get_object(ot);
   else
     o = ot;
   if(!o) throw(Error.Generic("Object type " + ot + " does not exist.\n"));
   if(!o->alternate_key)
     throw(Error.Generic("Object type " + ot + " does not have an alternate key.\n"));

   return get_instance(o->instance_name)(UNDEFINED)->find_by_alternate(id, context);
}

//!
.DataObjectInstance new(void|.DataModelContext context, string|program|object ot)
{
   object o;
   if(!objectp(ot))
     o = get_object(ot);
   else
     o = ot;
  if(!o) throw(Error.Generic("Object type " + ot + " does not exist.\n"));
  return  get_instance(o->instance_name)(UNDEFINED, context);
}
