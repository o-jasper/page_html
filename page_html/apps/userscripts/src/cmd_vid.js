// --- Running videos

var cmd_vid_go_uri = function(uri) {
    send('util/.vid', [uri], function(){ finish_commandpanel(); });
}

function cmd_vid() {  // Try open as video.
    ge('command_extend').innerHTML = "working...";

    var is = iface_state;

    var hover_uri = (is.hovered && find_a_href(is.hovered)) || is.hovered_href;
    if( (GM_getValue('cmd_vid_linklist') || "yes") != "yes" ) {
        cmd_vid_go_uri(hover_uri || document.documentURI);
    } else {  // NOTE the thing seems not very effective..
        // Get sorted list.
        var list = find_cursor_closest_links(false, hover_uri);

        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }
        list.unshift({ textContent:"cur page", href:document.documentURI });

        produce_action_list(ge('command_extend'), list, null,
                            function(el, j){ cmd_vid_go_uri(el.href); });

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        ge('cmd_vid_0').focus();
    }
}
