inherit .Relationship;

constant type="Foreign Key";

mapping otherobjects = ([]);

string otherobject; 
string otherkey; 
mixed default_value = .Undefined;
int null = 0;
int is_shadow=1;

static void create(string _name)
{
  name = _name;
}

// value will be null in a foreign key, as we're not in an object where that's a real field.
mixed decode(string value, void|.DataObjectInstance i)
{
  return .DataObjectInstance(UNDEFINED, otherobject)->find(([ i->master_object->primary_key->field_name :
                                  (int) i->get_id()]));
}

// value should be a dataobject instance of the type we're looking to set.
string encode(.DataObjectInstance value, void|.DataObjectInstance i)
{
  return "";
}


mixed validate(mixed value, void|.DataObjectInstance i)
{
  return 0;
}
