// To sql input if that is not hidden, otherwise to search input/
var limit_u = function(){ ge(ge('sql').hidden ? 'search' : 'sql').focus(); }
// Extend if at bottom.
var limit_d = function(){  gui_search_extend(); }

var on_enter = function(info, cur, i, name) {
    ge(info.nameprep + i + "_del").hidden = false;
}
var on_leave = function(info, cur, i, name) {
    ge(info.nameprep + i + "_del").hidden = true;
}

var info = {
    limit_d:limit_d, limit_u:limit_u,
    nameprep:config.list_el_nameprep,
    order:(cur && cur.sql_cmd ? ["whole"] : ["del", "mirror", "linked_title"]),
    del:{i:0}, mirror:{i:1}, linked_title:{i:2},
    block_keyup:true,
    on_enter : on_enter, on_leave : on_leave
}

function select_list_index(index) {
    if(info.cur_i){ on_leave(info, null, info.cur_i, null); }
    info.cur_i = index;
    on_enter(info, null, index, null);

    list_move(index, (cur && cur.sql_cmd ? "whole" : "linked_title"), info);
}
