
function ge(id) { 
    return document.getElementById(id) || { no_result:true };
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
function go_graph(to, ev) {
    if( typeof(to) == 'function' ) { to(ev); }
    else if(to) { maybe_ge(to).focus(); }
}

function follow_graph(graph) {
    return function(ev) {
        var kc = ev.keyCode, cur = graph[ev.target.id];
        if( kc == 13 ) {
            if( cur.ed && (!cur.sd || ev.shiftKey) ) { go_graph(cur.d, ev); }
        } else if( kc == 40 ) {
            if( !cur.sd || ev.shiftKey ) { go_graph(cur.d, ev); }
        } else if( kc == 38 ) {
            if( !cur.su || ev.shiftKey ) { go_graph(cur.u, ev); }
        } else if( kc == 37 ) {
            if( !cur.sl || ev.shiftKey ) { go_graph(cur.l, ev); }
        } else if( kc == 39 ) {
            if( !cur.sr || ev.shiftKey ) { go_graph(cur.r, ev); }
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
