
var initial_cnt = {%at_i};
var list_el = ge("list");

var cur = { at_i:initial_cnt, search_term:"{%search_term}" };

var step_cnt = {%step_cnt};

function list_extend(by_list, cnt) {
    cur.done = true;
    for(var i in by_list){
        cur.done = false;
        list_el.innerHTML += by_list[i];
    }
    if(cnt){ cur.at_i += cnt }
    cur.last_el = list_el.children[list_el.children.length - 1];
}

function search_extend(search_term, cnt) {
    var cnt = cnt || step_cnt;

    if( !cur.locked ) {
        cur.locked = true;
        callback_rpc_search([search_term, {limit:[cur.at_i, cnt]}],
                            function(ret) {
                                ge("sql").textContent = ret[1];
                                list_extend(ret[0], cnt);
                                cur.locked = false;
                            });
    }
}

function search_anew(search_term, cnt) {
    var cnt = cnt || initial_cnt;
    cur = { at_i:0, search_term:search_term, done:false };
    list_el.innerHTML = "";

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

function gui_search() { search_anew(ge("search").value); }

search_continuous = false;

ge('search').onkeydown = function(ev){ if( ev.keyCode == 13 ){ gui_search(); } };

// Why the hell does it not call?
(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
}, !window.opera);
