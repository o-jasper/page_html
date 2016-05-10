function select_list_index(index) {
    // To sql input if that is not hidden, otherwise to search input/
    var limit_u = function(){ ge(ge('sql').hidden ? 'search' : 'sql').focus(); }
    // Extend if at bottom.
    var limit_d = function(){  gui_search_extend(); }

    cur_sel = [ge('list').rows[0]];

    list_move(index, (cur.sql_cmd ? "whole" : "linked_title"), {
        limit_d:limit_d, limit_u:limit_u,
        nameprep:config.list_el_nameprep,
        mirror:{i:0}, linked_title:{i:1},
        order:(cur.sql_cmd ? ["whole"] : ["mirror", "linked_title"]),
        block_keyup:true,
    });
}
