import Fins.Model;

int main()
{
   object s = Sql.Sql("mysql://hww3:pastram.@localhost/hww3");
   object d = Fins.Model.DataModelContext(); 
   d->sql = s;
   d->debug = 1;
   add_object_type(name_object(d));

     
   object a = name();
   a->set("First_Name", "Bill");
   a->set("Last_Name", "Welliver");
   a["Cards_Received"] = 24;
   a->save();

   write("!Last Name: " + a->get("Last_Name") + "\n");
   a["Last_Name"] = "Lupart";

   write("Last Name: " + a["Last_Name"] + "\n");
   werror("Cards Received: %O\n", a["Cards_Received"]);
   object b = name(a->get_id());
   b->set_atomic((["Last_Name":"Welliver", "First_Name": "Jennifer", "Cards_Received": 42]));
   write("from b: " + b["First_Name"] +"\n");
   write("from b: " + b["Last_Name"] + "\n");
   write("from b: " + b["Cards_Received"] + "\n");
   
}

class name
{
   inherit DataObjectInstance;
   
   string object_type = "name";  
}

class name_object
{
   inherit DataObject;

   static void create(DataModelContext c)
   {  
      ::create(c);
      set_name("name");
      add_field(PrimaryKeyField("id"));
      add_field(StringField("First_Name", 32, 0));
      add_field(StringField("Last_Name", 32, 0));
      add_field(IntField("Cards_Received", 0, 1));
      set_primary_key("id");
   }
   
}
