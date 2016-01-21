
var initial_cnt = {%at_i};
var list_el = ge("list");

var cur = { at_i:initial_cnt, search_term:"{%search_term}" };

var step_cnt = {%step_cnt};

function search_extend(search_term, cnt) {
    var cnt = cnt || step_cnt;

    callback_rpc_search([search_term, null, [cur.at_i, cur.at_i + cnt]],
                        function(list) {
                            cur.done = true;
                            for(var i in list){
                                cur.done = false;
                                list_el.innerHTML += list[i];
                            }
                        });

    cur.last_el = list_el.children[list_el.children.length - 1];

    cur.at_i += cnt
}

function search_anew(search_term, cnt) {
    var cnt = cnt || initial_cnt;
    cur = { at_i:0, search_term:search_term, done:false };
    list_el.innerHTML = "";

    search_extend(search_term, cnt);
    cur.search_term = search_term;
}

// Extends list until out of view.
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

(window.opera ? document.body : document).addEventListener('onscroll', function(ev) {
    update_visibility();
})
