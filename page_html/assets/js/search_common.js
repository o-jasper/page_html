// Common stuff about finding stuff in elements.

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

// Finds something with a href.
function find_a_href(el) {
    var href = el.href;
    for(var i in el.children){
        if( href ){ return href; }
        href = find_a_href(el.children[i])
    }
    return href;
}
