
function into_from_top() {

    function limit(){ ge(ge('sql').hidden ? 'search' : 'sql').focus(); }

    cur_sel = [ge('list').rows[0]];
    // TODO the `limit_u` probably better off pressing the MOAR button.
    list_move(1, "linked_title", {
        limit_d:limit, limit_u:limit,
        nameprep:config.list_el_nameprep,
        mirror:{i:0}, linked_title:{i:1},
        order:["mirror", "linked_title"],
    });
}

var graph = {
    search : { sr:true, r:'search_button', sl:true, l:'sql_button', d:'sql' },
    search_button : { r:'visible_sql', l:'search', d:'sql' },
    visible_sql : { r:'sql_button', l:'search_button', d:'sql' },
    sql_button : { r:'search', l:'visible_sql', d:'sql' },
    sql : { su:true, u:'search', sd:true, d:into_from_top }
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

ge('search').focus();
// visible_sql(false);  // uncomment to defaultly not show the sql.
