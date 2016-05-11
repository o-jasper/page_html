
function list_extend(by_list) {
    cur.done = true;
    var h = "";
    for(var i in by_list){  // TODO might be nicer to .AppendChild(but the outer TR...)
        cur.done = false;
        h += by_list[i];
    }
    ge('list').innerHTML += h;
    cur.at_i += by_list.length;
    cur.last_el = ge('list').children[ge('list').children.length - 1];

    ge('cnt').textContent = cur.at_i;
}

function search_extend(search_term, cnt) {
    if( !cur.locked ) {
        cur.locked = true;
        var working_indicator = a.working_row_el(search_term + " (" + cnt + ")");
        prepend_child(ge('list'), working_indicator);

        ge("search_button").textContent = "(w)";

        callback_rpc_search([search_term, {limit:[cur.at_i, cnt], rest_path:rest_path}],
                            function(ret) {
                                ge('sql').value = ret[1];
                                textarea_fitting(ge('sql'), config.sql_textarea);

                                ge("search_button").textContent = "Go";
                                list.removeChild(working_indicator);

                                list_extend(ret[0]);
                                cur.locked = false;
                            });
    }
}

function gui_search_extend(search_term, cnt) {
    search_extend(search_term || cur.search_term || "", cnt || config.step_cnt || 50);
}

function hide_list_gui_section(i, yes, not_n) {
    var cur = ge('el_' + i), n= not_n || 0;
    while(cur && (cur.nodeName == "TR" || cur.nodeName == "#text")) {
        n -= 1;
        cur.hidden = yes && (n < 0);
        cur = cur.nextSibling;
    }
}

var marked_for_deletion = {}
function gui_delete(i, id) {
    if( marked_for_deletion[i] ){
        hide_list_gui_section(i, true);
        callback_delete_id([id]);
    } else {
        marked_for_deletion[i] = true;
        ge('list_el_' + i + "_del").style.backgroundColor = "red";
    }
}
function gui_edit(i, id) {
    var mod_el = ge("el_mod_" + i);
    if( !mod_el.no_result && mod_el.children.length == 0 ) {
        mod_el.innerHTML = config.edit_html.replace(/{%i}/g, i);
        mod_el.hidden = true;
        callback_get_id([id], function(ret) {
            var top    = function(){ ge('list_el_' + i + "_edit").focus(); }
            var bottom = function(){
                ge('list_el_' + (i + 1) + "_linked_title").focus();
            }
            cmd_bm_setup(i + "_", ret, top, bottom,
                         function(ret){ callback_update_id([ret]); },
                         function(){
                             hide_list_gui_section(i, false);
                             mod_el.innerHTML = "";
                             mod_el.hidden = true;
                         })
        })
    }
    hide_list_gui_section(i, true, 3);
    mod_el.hidden = !mod_el.hidden;
}

function search_anew(search_term, cnt) {
    var cnt = cnt || initial_cnt;
    cur = { at_i:0, search_term:search_term, done:false };

    ge('list').innerHTML = "";  // Anew; remove list.
    search_extend(search_term, cnt);
    cur.search_term = search_term;
}

// Control visibility of sql mode.
function visible_sql(yes) {
    ge('sql').hidden = !yes;
    ge('sql_button').hidden = !yes;

    ge('visible_sql').textContent = yes ? "Hide SQL" : "Show SQL";
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

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
