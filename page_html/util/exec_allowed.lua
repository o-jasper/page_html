return {
   blacklist = {"^rm[%s]", "[$()`]", "^echo.+$"},


   no_print = {[[^mkdir %-p "[%w_+-./:]+"$]], [[^mkdir "[%w_+-./:]+"$]],
      "^echo$"
   },

   -- Basically a list of all my usages..
   -- TODO it'd be neater if central place produced both filters and patterns.
   --  however even better if script is out of the loop in the first place.
   required = {
      [[^mkdir %-p ".+"$]], [[^mkdir ".+"$]],
      "^echo$",
      [[^man %-%-html="cat %%s > .+" .+$]],
      [[^bash %-c "cd ,+; pydoc %-w .+"$]],
      [[^curl ".+" > ".+"$]],
      [[^wget %-%-convert%-links %-P ".+" %-e robots=off %-%-user%-agent=one_page_plz %-p ".+"$]],

      [[^mpv %-%-force%-window %-%-fs ".+" &$]],
      [[^mpv %-%-force%-window %-%-geometry=[%wx%%]+ ".+" &$]],
   }
}
