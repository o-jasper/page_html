
function ge(id) { 
    return document.getElementById(id) || {};
}

// TODO put maybe_ge here? (put all common js together)

function prepend_child(to_el, add_el) {
    if(to_el.childNodes[0]) {
        to_el.insertBefore(add_el, to_el.childNodes[0]);
    } else {
        to_el.appendChild(add_el);
    }
}

// -- TODO not used.
function set_ids(idvals) {
    if(idvals) for( k in idvals ) {
        if( k == "sql_input" ){  // TODO block at right time.
            ge(k).value = idvals[k];
        }
        else if(idvals[k]) {
            ge(k).innerHTML = idvals[k];
        }
    }
}
function get_ids(ids) {
    var ret = {}
    for( k in ids ){ ret[ids[k]] = ge(ids[k]).value; }
    return ret;
}

var hide_buttons = false;
function hide_button(name, yes) {
    var el = ge(name);
    el.hidden   = hide_buttons && yes;
    el.disabled = yes;
}

function toggle_editmode(of_name, yes) {
    ge(of_name).hidden = yes;
    ge("edit_" + of_name).hidden = !yes;
}

function in_viewport(el) {
    var height = window.innerHeight;
    var top    = el.offsetBottom;
    var bottom = el.offsetTop;
    return top > 0 ? top <= height : (bottom > 0 && bottom <= height);
}
