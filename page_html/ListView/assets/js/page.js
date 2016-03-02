
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

var cur_sel

function list_el_lose_focus() {
    if(cur_sel) { for( var i in cur_sel ){ cur_sel[i].className = ""; } }
}

function list_move(go_down, limit) {
    // Clear old.
    list_el_lose_focus();
    var cur = cur_sel[cur_sel.length - 1];  // Go to the end.
    cur_sel = [];

    var is = function(what) {
        var match = (cur.textContent || "").substr(0, what.length);
//        if( what == " end " ){ alert(match + " ? " + (match == what)); }
        return cur.nodeName != 'TR' && (match == what);
    }
    if(cur) {
        if(!go_down) {
            cur = cur.previousSibling;
            // Go up until see a start.
            while( cur && !is(" start ") ) { cur = cur.previousSibling; }
        }
        //  Go down until see a start.
        while( cur && !is(" start ") ) { cur = cur.nextSibling; }
        if(!cur){ limit(); return; }  // Off the map.

        var str = "";
        var i = 0  // Record until see an end.
        while( cur && !is(" end ") ) {
            str += "<br>\n" + cur.innerHTML;
            if( cur.nodeName == 'TR' ) {
                cur_sel.push(cur)

                //cur.style.outline = "0.2em solid black";
                cur.className = "row";
                cur.style.color = "red";
            }
            cur = cur.nextSibling
            i = i += 1
        }
        // TODO hmm need to add buttons onto there...
        cur_sel[0].className += " top";
        cur_sel[cur_sel.length - 1].className += " bottom";
    } else{ limit(); }
}

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
