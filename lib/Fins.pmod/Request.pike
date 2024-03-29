constant low_protocol = "NONE";
object fins_app;

string current_lang;
string not_args;
string controller_path;
string controller_name;
string event_name;
object controller;
mixed event;

mapping iso639_2 = Tools.Language.Names.iso639_2;

function get_session_by_id = _get_session_by_id;

static mixed cast(string typen)
{
  if(typen == "mapping")
  {
    return mkmapping(indices(this), values(this));
  }
}

//!
static mapping _get_session_by_id(string SessionID)
{
  return ([]);
}

multiset (string) pragma = (< >);

//!
string get_compress_encoding()
{

  if(this->misc->session_variables && this->misc->session_variables->__encode)
    return this->misc->session_variables->__encode;

  array available = ({"deflate", "gzip"});

  // we need to figure out the encoding supported.
  //  else
  {
    string encode = 0;
    string eh;
    array ae = ({});
    array aq = ({});

    if(this->request_headers["accept-encoding"])
      eh = this->request_headers["accept-encoding"];

    if(!eh || !sizeof(eh)) return 0;

    foreach(eh/",";;string encode)
    {
      array e = encode/";";
      float q = 1.0;
      encode = String.trim_all_whites(e[0]);
      if(sizeof(e)>1)
      {
        e[1] = String.trim_all_whites(e[1]);
        if(has_prefix(e[1], "q="))
          q = (float)e[1][2..];
        else q = 1.0;
      }
      ae += ({encode});
      aq += ({q});
    }
    sort(aq, ae);
    ae = reverse(ae);
     // we prefer gzip.
     if(search(ae, "gzip") != -1)
       encode = "gzip";
     else
      foreach(ae;;string desired)
        if(search(available, desired) != -1)
        {
          encode = desired;
          break;
        }
#ifdef DEBUG
    werror("SELECTED ENCODING: %O\n", encode);
#endif
    if (this->misc->session_variables)
      this->misc->session_variables->__encode = encode;
    return encode;
  }

}

//! allows you to override the detected language.
void set_lang(string lang) {
  if (sizeof(lang) == 2) {
    if (iso639_2[lang])
      this->misc->set_lang = iso639_2[lang];
  }
  else if (sizeof(lang) == 3) {
    string l = search(iso639_2, lang);
    if(l) this->misc->set_lang = lang;
  }
}

string _locale_project;

//! returns the default 
string get_project()
{
  if(!_locale_project) _locale_project = fins_app->config->app_name;
	return _locale_project;
}

//! returns a 3 letter iso 639 language code based on accept-language headers
//!
//! @note
//! this value is cached for the life of the session
string get_lang()
{
  if(!current_lang)
    current_lang = low_get_lang();
  
  return current_lang;
}

//! the purpose of this method is to convert an iso language code
//! to one familiar with the pike locale system.
array map_languages(array languages)
{
  array out = ({}); 

  foreach(languages;;string l)
    if(iso639_2[l])
      out += ({iso639_2[l]});
    else if(sizeof(l)>2 && iso639_2[l[0..1]])
      out += ({iso639_2[l[0..1]]});

  return out;
}

string low_get_lang()
{

  // if we've explicitly set a language (using the _lang variable, 
  // see HTTPRequest and friends,) write it here.
  if (this->misc->set_lang)
  {
//werror("low_get_lang(): setting language %O with header %O.\n", this->misc->set_lang,  this->request_headers["accept-language"]);
    this->misc->session_variables->__lang = this->misc->set_lang;
    this->misc->session_variables->__lang_header = 
          this->request_headers["accept-language"];
    m_delete(this->misc, "set_lang");
    return this->misc->session_variables->__lang;
  }
  // if we've already calculated the language, and the headers are
  // still coming in the same as when we made the decision, don't
  // recalculate the language.
  else if(this->misc->session_variables->__lang &&  
      (this->misc->session_variables->__lang_header == 
         this->request_headers["accept-language"]))
    return this->misc->session_variables->__lang;


  // we need to figure out the language.
  //  else
  {
    string lang;
    string lh;
    array al = ({});
    array aq = ({});

    // if we've specified a language, use it, otherwie, we default to english.
    if(catch(lang = fins_app->config->get_value("application","default_language")))
      lang = "eng";

    if(this->request_headers["accept-language"])
      lh = this->request_headers["accept-language"];
    if(!lh) lh = "";
    foreach(lh/",";;string lang)
    {
      array l = lang/";";
      float q = 1.0;
      lang = String.trim_all_whites(l[0]);
      if(sizeof(l)>1)
      {
	l[1] = String.trim_all_whites(l[1]);
	if(has_prefix(l[1], "q="))
	  q = (float)l[1][2..];
	else q = 1.0;
      }
      al += ({lang});
      aq += ({q});
    }

    sort(aq, al);
    al = reverse(al);

    al = map_languages(al);
    array available = Locale.list_languages(fins_app->config->app_name);

#ifdef DEBUG
    werror("REQUESTED LANGUAGES: %O\n", al);
    werror("AVAILABLE LANGUAGES: %O\n", Locale.list_languages(fins_app->config->app_name));
#endif
    foreach(al;;string desired)
      if(search(available, desired) != -1)
      {
	lang = desired;
	break;
      }
#ifdef DEBUG
    werror("SELECTED LANGUAGE: %O\n", lang);
#endif
    this->misc->session_variables->__lang = lang;
    this->misc->session_variables->__lang_header = lh;
    return lang;
  }
}
