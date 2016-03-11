
function list_extend(by_list) {
    cur.done = true;
    for(var i in by_list){  // TODO might be nicer to .AppendChild(but the outer TR...)
        cur.done = false;
        ge('list').innerHTML += by_list[i];
    }
    cur.at_i += by_list.length;
    cur.last_el = ge('list').children[ge('list').children.length - 1];

    ge('cnt').textContent = cur.at_i;
}

function search_extend(search_term, cnt) {
    var cnt = cnt || step_cnt;

    if( !cur.locked ) {
        cur.locked = true;
        prepend_child(ge('list'), a.working_row_el());

        ge("search_button").textContent = "(w)";
        callback_rpc_search([search_term, {limit:[cur.at_i, cnt], rest_path:rest_path}],
                            function(ret) {
                                ge('sql').value = ret[1];
                                textarea_fitting(ge('sql'), config.sql_textarea);

                                ge("search_button").textContent = "Go";
                                ge('list').innerHTML = "";
                                list_extend(ret[0]);
                                cur.locked = false;
                            });
    }
}

function search_anew(search_term, cnt) {
    var cnt = cnt || initial_cnt;
    cur = { at_i:0, search_term:search_term, done:false };

    search_extend(search_term, cnt);
    cur.search_term = search_term;
}

// Control visibility of sql mode.
function visible_sql(yes) {
    ge('sql').hidden = !yes;
    ge('sql_button').hidden = !yes;

    ge('visible_sql').textContent = yes ? "Hide SQL" : "Show Sql";
}

// Extends list until out of view. (TODO doesnt work...)
function update_visibility(n) {
    for(var i = 0 ; i < (n || 2) ; i++ ) {
        if(!cur.done && cur.last_el && in_viewport(cur.last_el)) {
            search_extend(cur.search_term);
        }
    }
}

var gui_search_prev_value;
function gui_search() {
    if( ge('search').value != gui_search_prev_value ) {
        gui_search_prev_value = ge('search').value;
        search_anew(ge('search').value);
    }
}

// Basically here because list entries arent handy units.
// (but i kindah want the vertical alignment of tables.)

function list_move(i, funs) {
    var edit_el = ge("edit_el_" + i);
    if( edit_el.no_result ){
        funs.limit_u();
    } else {
        edit_el.onfocus = function() {
            edit_el.hidden = false;
            focus_table_list(edit_el, false);  // Add the borders.
        }
        edit_el.onblur = function(){
            edit_el.hidden = true;
            focus_table_list(edit_el, true);  // Remove the borders.
        }
        edit_el.onkeydown = function(ev) {
            if(ev.keyCode == 38){ list_move(i - 1, funs) }
            else if(ev.keyCode == 40){ list_move(i + 1, funs) }
        }
        edit_el.onclick = function() { alert("SUB" + i); }
        edit_el.hidden = false;
        edit_el.focus();
    }
}

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
