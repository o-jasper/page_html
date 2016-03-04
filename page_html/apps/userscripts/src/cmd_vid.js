function find_a_href(el) {
    var href = el.href;
    for(var i in el.children){
        if( href ){ return href; }
        href = find_a_href(el.children[i])
    }
    return href;
}

// --- Running videos

function cmd_vid() {  // Try open as video.
    ge('command_extend').innerHTML = "working...";
    // TODO hackish, just want the hovered link...
    var href = (hovered && find_a_href(hovered)) || hovered_href;
    send('util/.vid', [href || document.documentURI],
         function(){ finish_commandpanel(); });
}
