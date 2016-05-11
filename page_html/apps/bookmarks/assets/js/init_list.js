// To sql input if that is not hidden, otherwise to search input/
var limit_u = function(){ ge(ge('sql').hidden ? 'search' : 'sql').focus(); }
// Extend if at bottom.
var limit_d = function(){  gui_search_extend(); }

var on_enter = function(info, cur, i, name) {
    var prep = info.nameprep + i;
    ge(prep + "_del").hidden = false;
    ge(prep + "_edit").hidden = false;
    ge("el_mod_" + i).hidden = false;
}
var on_leave = function(info, cur, i, name) {
    var prep = info.nameprep + i;
    ge(prep + "_del").hidden = true;
    ge(prep + "_edit").hidden = true;
    ge("el_mod_" + i).hidden = true;
}

var alt_d = function(info, cur, i, name, ev) {
    if( !ge('el_mod_' + i).hidden && ge(i + '_bm_title').focus ){
        ge(i + '_bm_title').focus();
        ev.preventDefault()
        return true;
    }
    return false;
}

var info = {
    limit_d:limit_d, limit_u:limit_u,
    alt_d : alt_d,
    nameprep:config.list_el_nameprep,
    order:(cur && cur.sql_cmd ? ["whole"] : ["del", "edit", "mirror", "linked_title"]),
    del:{i:0}, edit:{i:1}, mirror:{i:2}, linked_title:{i:3},
    block_keyup:true,
    on_enter : on_enter, on_leave : on_leave
}

function select_list_index(index) {
    if(info.cur_i){ on_leave(info, null, info.cur_i, null); }
    info.cur_i = index;
    on_enter(info, null, index, null);

    list_move(index, (cur && cur.sql_cmd ? "whole" : "linked_title"), info);
}
