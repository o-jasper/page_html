
function ge(id) { 
    return document.getElementById(id) || {};
}
function maybe_ge(el) {
    return (typeof(el) == 'string' && ge(el)) || el; 
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

// Fits the length constantly.
function textarea_update(te, after_keydown) {
    var te = maybe_ge(te);
    te.rows = Math.max(te.value.split("\n").length, 0);
    te.cols = GM_getValue("reasonable_width", 80);

    te.onkeydown = function(ev){
        te.rows = Math.max(te.value.split("\n").length, 0);
        if(after_keydown){ after_keydown(ev); }
    }
}

// Adds next/prev, left/right functionality.
function next_prev(next, prev, need_shift, left, right) {
    var next = maybe_ge(next), prev = maybe_ge(prev);
    return function(ev) {
        if( need_shift && !ev.shiftKey ){ return; }
        if( next && ev.keyCode == 13 ) {
            next.focus();
        } else if( next && ev.keyCode == 40 ) {
            next.focus();
        } else if( prev && ev.keyCode == 38 ) {
            prev.focus();
        } else if( left && ev.keyCode == 37 ) {
            left.focus();
        } else if( right && ev.keyCode == 39 ) {
            right.focus();
        }
    }
}