 var graph = {
    search : { sr:true, r:'search_button', sl:true, l:'sql_button', d:'sql' },
    search_button : { r:'visible_sql', l:'search', d:'sql' },
    visible_sql : { r:'sql_button', l:'search_button', d:'sql' },
    sql_button : { r:'search', l:'visible_sql', d:'sql' },
    sql : { su:true, u:'search' }
};

var fg = follow_graph(graph);

ge('search').onkeydown = function(ev) {
    if(search_continuous || ev.keyCode == 13){ gui_search(); }
    fg(ev);
};

ge('search_button').onkeydown = fg;
ge('visible_sql').onkeydown = fg;
ge('sql_button').onkeydown = fg;
ge('sql').onkeydown = fg;

ge('search').focus();
// visible_sql(false);  // uncomment to defaultly not show the sql.
