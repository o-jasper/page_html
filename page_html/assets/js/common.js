
ge_prep = "";

function ge(id) {
    return document.getElementById(ge_prep + id) || { no_result:true };
}
function maybe_ge(el) {
    if( typeof(el) == 'string' ){ return ge(el); } else{ return el; }
}

function prepend_child(to_el, add_el) {
    if(to_el.childNodes[0]) {
        to_el.insertBefore(add_el, to_el.childNodes[0]);
    } else {
        to_el.appendChild(add_el);
    }
}

var hide_buttons = false;
function hide_button(name, yes) {
    var el = maybe_ge(name);
    el.hidden   = hide_buttons && yes;
    el.disabled = yes;
}

function in_viewport(el) {
    var height = window.innerHeight;
    var top    = el.offsetBottom;
    var bottom = el.offsetTop;
    return top > 0 ? top <= height : (bottom > 0 && bottom <= height);
}

function textarea_fitting(te, config) {
    var te = maybe_ge(te);
    te.rows = Math.min(Math.max(te.value.split("\n").length, 0),
                       config.max_rows);
    te.cols = config.cols;
}

// Fits the length constantly.
function textarea_update(te, after_keydown, config) {
    var te = maybe_ge(te);
    textarea_fitting(te, config);

    te.onkeydown = function(ev){
        textarea_fitting(te, config);
        if(after_keydown){ after_keydown(ev); }
    }
}

// Travelling through guis.
function go_graph(to, ev, graph) {
    if( typeof(to) == 'function' ) { ev.preventDefault(); to(ev); }
    else if(to) {
        var got = maybe_ge(to);
        if( !got.hidden ){ ev.preventDefault(); got.focus(); }
        else{ follow_graph(graph)({target:got, keyCode:ev.keyCode, shiftKey:true}); }
    }
}

// TODO more configurability with regard to which keys do what.

function follow_graph(graph) {
    return function(ev) {
        var kc = ev.keyCode, cur = graph[ev.target.id.substr(ge_prep.length)];

        if( !ev.ctrlKey ) {   //Always control key, its consistent.
            return;
        } else if( kc == 13 ) {
            if( cur.ed && (!cur.sd || ev.shiftKey) ) { go_graph(cur.d, ev, graph); }
        } else if( kc == 40 ) {
            if( !cur.sd || ev.shiftKey ) { go_graph(cur.d, ev, graph); }
        } else if( kc == 38 ) {
            if( !cur.su || ev.shiftKey ) { go_graph(cur.u, ev, graph); }
        } else if( kc == 37 ) {
            if( !cur.sl || ev.shiftKey ) { go_graph(cur.l, ev, graph); }
        } else if( kc == 39 ) {
            if( !cur.sr || ev.shiftKey ) { go_graph(cur.r, ev, graph); }
        }
    }
}

// Making lines around current list selection in tables.
function focus_table_list(el, out, prep) {
    var prep = prep || "";
    // Find the `TR` level.
    if( el.nodeName != '#comment' ) {
        while(el && el.nodeName != 'TR'){ el = el.parentNode; }
    }
    // Find the comment node representing the "the start of the section."
    var prev = el;
    while( el  && el.nodeName != '#comment' ) {
        prev = el;
        el = el.previousSibling;
    }
    el = prev;  // Iterate, applying the classes.
    var first, last;
    while( el && (el.nodeName != '#comment') ) {
        first = first || (el.nodeName == 'TR' && el);
        last  = (el.nodeName == 'TR' && el) || last;

        el.className = (out ? "" : prep + "row");

        el = el.nextSibling;
    }
    if( !out ) {
        first.className += " " + prep + "top";
        last.className  += " " + prep + "bottom";
    }
}


// Basically here because list entries arent handy units.
// (but i kindah want the vertical alignment of tables.)
function list_move(i, name, info, alt_fun, ev) {
    if(name) {
        if(ev && !info.dont_prevent){ ev.preventDefault(); }

        var funs = info[name] || info;
        var cur = ge(info.nameprep + i + "_" + name);

        if( cur.no_result ){
            // TODO instead, skip.
            (alt_fun || funs.alt_fun || info.alt_fun ||
             function(){ alert("No:" + info.nameprep + i + "_" + name); })();
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
                if( !ev.ctrlKey ) { return; }

                var kc = ev.keyCode, order = info.order;
                var ol = order.length;

                if(kc == 38){
                    if(info.on_leave){ info.on_leave(info, cur, i, name); }
                    if(info.on_enter){ info.on_enter(info, cur, i - 1, name); }
                    list_move(i - 1, name, info, info.limit_u, ev);
                } else if(kc == 40){
                    if(info.on_leave){ info.on_leave(info, cur, i, name); }
                    if(info.on_enter){ info.on_enter(info, cur, i + 1, name); }
                    list_move(i + 1, name, info, info.limit_d, ev);
                } else if(kc == 37){
                    list_move(i, order[(funs.i - 1 + ol)%ol], info, info.limit_r, ev);
                }
                else if(kc == 39){
                    list_move(i, order[(funs.i + 1)%ol], info, info.limit_l, ev);
                }
            }
            if(info.block_keyup){ cur.onkeyup = function(){} }
            cur.onclick = funs.onclick || null;
            cur.hidden = false;
            if(!cur.focus){ alert("Couldnt focus:" + info.nameprep + i + "_" + name); }
            cur.focus();
        }
    }
}
