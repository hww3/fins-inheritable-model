inherit .DataObjectInstance;

constant type_name = "unknown";
object repository = Fins.Model;

static void create(int identifier)
{
  object o = repository["get_object"](type_name);

  werror("name: %O, object: %O\n", type_name, o);
  ::create(identifier, o);
}

