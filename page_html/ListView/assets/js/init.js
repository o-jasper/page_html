function into_from_top(){ select_list_index(1); }

var graph = {
    search : { r:'search_button', l:'sql_button', d:'sql' },
    search_button : { r:'visible_sql', l:'search', d:'sql' },
    visible_sql : { r:'sql_button', l:'search_button', d:'sql' },
    sql_button : { r:'search', l:'visible_sql', d:'sql' },
    sql : { u:'search', d:into_from_top },
    moar_button : { u:function(){select_list_index(cur.at_i); } },
};

var fg = follow_graph(graph);

ge('search').onkeydown = fg;
ge('search').onkeyup = function(ev){
    if(search_continuous || ev.keyCode == 13){ gui_search(); }
}

ge('search_button').onkeydown = fg;
ge('visible_sql').onkeydown = fg;
ge('sql_button').onkeydown = fg;
ge('sql').onkeydown = fg;
ge('moar_button').onkeydown = fg;

ge('search').focus();

if( config.sql_enabled ){
    ge('sql').hidden = true;
    ge('sql_button').hidden = true;
    ge('sql_button').disabled = true;
}
