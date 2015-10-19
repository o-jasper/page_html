-- This is the recommended way.
return {
   name = "templated",

   repl_pattern = function(self, args)
      if args.rest_path == "js.js" then
         return [[document.getElementById("serverlike").textContent = "could get src asset";]]
      else
         return [[
{%inject_js}
<p>Templated, using replacements</p>
<p id="add">Javascript -via-lua did <b>not</b> operate</p><hr>
<a style="font-size:70%" href="/direct">to direct</a>

<span style="color:gray;font-size:70%">{%date}</span>

<p>{%auto.html}</p>

<script>document.getElementById("add").textContent = get_str();</script>

<p>All the arg values:({%all_arg_cnt})<p><table>{%all_arg}</table>
<p>All the conf values:({%all_conf_cnt})<p><table>{%all_conf}</table>

<p id="serverlike">Not serverlike/javascript disabled</p>

<script src="/{%page_name}/js.js"></script>
{%unfindable}
]]
      end
   end,
   
   rpc_js = { 
      get_str = function() 
         return "Will enter javascript functions for you"
      end,
   },
   
   repl = function(self, args)
      local all_arg, n = "", 0
      for k, v in pairs(args) do
         all_arg = string.format("%s<tr><td>%s=</td><td>%s</td></tr>",
                                 all_arg, k, v)
         n = n + 1
      end
      local all_conf, m = "", 0
      for k, v in pairs(args.conf) do
         all_conf = string.format("%s<tr><td>%s=</td><td>%s</td></tr>",
                                  all_conf, k, v)
         m = m + 1
      end
      return { inject_js = args.inject_js or " ",
               page_name = self.name, date = os.date(),
               all_arg = all_arg,   all_arg_cnt = n,
               all_conf = all_conf, all_conf_cnt = m }
   end,

   where = {"page_html/serve/examples/"}
}
