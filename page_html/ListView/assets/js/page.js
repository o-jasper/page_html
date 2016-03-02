
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

var cur_sel;

function list_el_lose_focus() {
    if(cur_sel) { for( var i in cur_sel ){ cur_sel[i].className = ""; } }
}

// Basically here because list entries arent handy units.
// (but i kindah want the vertical alignment of tables.)

function list_move(go_up, funs) {
    // Clear old.
    list_el_lose_focus();
    var cur = cur_sel[cur_sel.length - 1];  // Go to the end.
    cur_sel = [];

    var isnt = function(what) {  // Finds beginning/endings.
        if(cur) {
            var match = (cur.textContent || "").substr(0, what.length);
            return !(cur.nodeName != 'TR' && (match == what));
        }
    }
    if(cur) {
        if(!go_up) {
            cur = cur.previousSibling;
            // Go up until see a start.
            while( isnt(" start ") ) { cur = cur.previousSibling; }
            if(!cur){ funs.limit_u(); return; } // Hit top.
            cur = cur.previousSibling;
            while( isnt(" start ") ) { cur = cur.previousSibling; }
            if(!cur){ funs.limit_u(); return; }
        }
        //  Go down until see a start.
        while( isnt(" start ") ) { cur = cur.nextSibling; }
        if(!cur){ funs.limit_d(); return; }  // Hit bottom.
        // This is the start, what is the name?
        var name = cur.textContent;
        name = name.substr(7, name.length - 8);
        var edit_el = ge("edit_el_" + name);
        if( edit_el ){
            edit_el.hidden = false;
            edit_el.focus();

            edit_el.onblur = function(){
                list_el_lose_focus(); edit_el.hidden = true;
            }
            edit_el.onkeydown = function(ev) {
                if(ev.keyCode == 38){ list_move(false, funs) }
                else if(ev.keyCode == 40){ list_move(true, funs) }
            }
        }

        var str = "";
        var i = 0  // Record until see an end.
        while( isnt(" end ") ) {
            str += "<br>\n" + cur.innerHTML;
            if( cur.nodeName == 'TR' ) {
                cur_sel.push(cur);
                cur.className = "row";
            }
            cur = cur.nextSibling
            i = i += 1
        }
        // TODO hmm need to add buttons onto there...
        cur_sel[0].className += " top";
        cur_sel[cur_sel.length - 1].className += " bottom";
    } else if(go_up){ funs.limit_u(); } else{ funs.limit_d(); }
}

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
