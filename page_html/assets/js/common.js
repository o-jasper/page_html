
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
        var got = maybe_ge((graph.extra_prep || "") + to);
        if( !got.hidden ){ ev.preventDefault(); got.focus(); }
        else{ follow_graph(graph)({target:got, keyCode:ev.keyCode, shiftKey:true}); }
    }
}

// TODO more configurability with regard to which keys do what.

function follow_graph(graph) {
    return function(ev) {
        var strip_l = (graph.extra_prep ? graph.extra_prep.length : 0) + ge_prep.length;
        var kc = ev.keyCode, cur = graph[ev.target.id.substr(strip_l)];

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

// NOTE function below works by returning true if need to skip over.

// Basically here because list entries arent handy units.
// (but i kindah want the vertical alignment of tables.)
function list_move(i, name, info, alt_fun, ev) {
    if(name) {
        if(ev && !info.dont_prevent){ ev.preventDefault(); }

        var funs = info[name] || info;
        var cur = ge(info.nameprep + i + "_" + name);

        if( cur.no_result ){
            // TODO instead, skip.
            return (alt_fun || funs.alt_fun || info.alt_fun ||
                    function(){ return true; })();
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

                if(kc == 38){ // Up.
                    if(info.on_leave){ info.on_leave(info, cur, i, name); }
                    var k = i - 1;
                    while(list_move(k, name, info, info.limit_u, ev)){ k -= 1; }
                    if(info.on_enter){ info.on_enter(info, cur, k, name); }
                } else if(kc == 40){ // Down.
                    if(!(info.alt_d && info.alt_d(info, cur, i, name, ev))){
                        if(info.on_leave){ info.on_leave(info, cur, i, name); }
                        var k = i + 1;
                        while(list_move(k, name, info, info.limit_d, ev)){ k += 1; }
                        if(info.on_enter){ info.on_enter(info, cur, k, name); }
                    }
                } else if(kc == 37){ // Left.
                    var k = funs.i - 1 + ol;
                    while(list_move(i, order[k%ol], info, info.limit_r, ev)){ k -= 1; }
                } else if(kc == 39){ // Right.
                    var k = funs.i + 1 + ol;
                    while(list_move(i, order[k%ol], info, info.limit_l, ev)){ k += 1; }
                }
            }
            if(info.block_keyup){ cur.onkeyup = function(){} }
            cur.onclick = funs.onclick || cur.onclick;
            cur.hidden = false;
            if(!cur.focus){ alert("Couldnt focus:" + info.nameprep + i + "_" + name); }
            cur.focus();
            return ge('el_' + i).hidden;  // Skip over if whole thing is hidden.
        }
    }
}
