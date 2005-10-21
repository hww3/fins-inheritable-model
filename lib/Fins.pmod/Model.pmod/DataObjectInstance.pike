.DataObject master_object;

string object_type;
multiset fields_set = (<>);
mapping object_data = ([]);
mapping cached_object_data = ([]);
static int key_value = UNDEFINED;
int new_object = 0;
int saved = 0;

string _sprintf(mixed ... args)
{
  return object_type + "(" + key_value + ")";
}

static void create(int|void id, string|void _object_type)
{
   if(_object_type)
     object_type = _object_type;

   .DataObject o = .get_object(object_type);  

   if(!o)
   {
     throw(Error.Generic("object type " + object_type + " does not exist.\n"));
   }
   master_object = o;

   

  if(id == UNDEFINED)
  {
    set_new_object(1);
  }

  else
  {
    master_object->load(id, this);
  }
}

void refresh()
{
   master_object->load(key_value, this);
}

void set_cache(mapping c)
{
   cached_object_data = c;
}

.DataObjectInstance new()
{
   .DataObjectInstance new_object = object_program(this)();  

   new_object->set_new_object(1);
   return   new_object;
}

.DataObjectInstance find(int id)
{
   .DataObjectInstance new_object = object_program(this)();

    master_object->load(id, new_object);

   return new_object;
}

int delete()
{
   return master_object->delete(this);
}

int save()
{
   return master_object->save(this);
}

int set_atomic(mapping values)
{
   return master_object->set_atomic(values, this);
}

int set(string name, string value)
{
   return master_object->set(name, value, this);
}

mixed get_atomic()
{
   return master_object->get_atomic(this);
}

mixed get(string name)
{
   return master_object->get(name, this);
}

void set_id(int id)
{
  key_value = id;   
}

int get_id()
{
   return key_value;
}

void set_new_object(int(0..1) i)
{
   new_object = i;
}

void set_saved(int(0..1) i)
{
   saved = i;
}

int is_saved()
{
   return saved;
}

int is_new_object()
{ 
   return new_object;
}

mixed `[]=(mixed i, mixed v)
{
  if(v == UNDEFINED)
  {
    return get(i);
  }

  else return set(i, v);
}

mixed `[](mixed arg)
{
  return get(arg);
}

