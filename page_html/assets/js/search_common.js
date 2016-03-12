// Common stuff about finding stuff in elements.

// Finds something with a href.
function find_a_href(el) {
    var href = el.href;
    for(var i in el.children){
        if( href ){ return href; }
        href = find_a_href(el.children[i])
    }
    return href;
}

// Function returning cursor-distance-to-element. Doesnt work. Why
//  arent there clear coordinate systems...
function element_pos_dist(x,y) {
    return function(el) {
        var ex = el.clientLeft - document.body.clientLeft,
            ey = el.clientTop - document.body.clientTop;

        // Note the weights!
//TODO...
        return Math.sqrt(Math.pow(x - ex, 2) + Math.pow(y - ey, 2));
    }
}

function find_closest(dist, search_list, range, allow) {
    if( typeof(dist) != "function" ) { dist = element_pos_dist(dist[0], dist[1]); }
    var ret = [];
    for( var i in search_list ){ // Unsorted, just in-range.
        var el = search_list[i];
        if( el && dist(el) < range && (!allow || allow(el))) { ret.push(el); }
    }
    ret.sort(dist);
    return ret;
}
