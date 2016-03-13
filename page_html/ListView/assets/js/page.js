
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

function list_move(i, name, info) {
    if(name) {
        var funs = info[name] || info;
        var cur = ge(info.nameprep + i + "_" + name);
        if( cur.no_result ){
            (funs.limit_u || info.limit_u)();
        } else {
            cur.onfocus = function() {
                cur.hidden = false;
                focus_table_list(cur, false);  // Add the borders.
            }
            cur.onblur = function(){
                cur.hidden = funs.hide_it;
                focus_table_list(cur, true);  // Remove the borders.
            }
            cur.onkeydown = function(ev) {
                var kc = ev.keyCode, order = info.order;
                var ol = order.length;

                if(kc == 38){ list_move(i - 1, name, info) }
                else if(kc == 40){ list_move(i + 1, name, info) }
                else if(kc == 37){ list_move(i, order[(funs.i - 1 + ol)%ol], info) }
                else if(kc == 39){ list_move(i, order[(funs.i + 1)%ol], info) }
            }
            cur.onclick = funs.onclick || null;
            cur.hidden = false;
            cur.focus();
        }
    }
}

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
