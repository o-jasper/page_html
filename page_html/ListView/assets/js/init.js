ge('search').onkeydown = function(ev) {
    if(search_continuous || ev.keyCode == 13){ gui_search(); }
};
ge('search').focus();
// visible_sql(false);  // uncomment to defaultly not show the sql.
