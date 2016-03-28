// --- Running videos

var cmd_vid_fun = function(el) {
    send('util/.vid', [el.href],
         function(result_obj) {
             var tab = JSON.parse(result_obj.responseText);
             // Sometimes it will run it on-browser.
             if( tab && tab.success ) { GM_openInTab(tab.pref_uri || tab.m_uri); }
             finish_commandpanel();
        })
}

function cmd_vid() {  // Try open as video.
    ge('command_extend').innerHTML = "working...";  // TODO Dont see this?

    var is = iface_state;

    var hover_uri = (is.hovered && find_a_href(is.hovered)) || is.hovered_href;
    if( (GM_getValue('cmd_vid_linklist') || "yes") != "yes" ) {
        cmd_vid_fun({href:hover_uri || document.documentURI});
    } else {  // NOTE the thing seems not very effective..
        // Get sorted list.
        var list = find_cursor_closest_links(false, hover_uri);

        list.unshift({ textContent:"cur page", href:document.documentURI });
        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }

        ge('command_extend').innerHTML = "";
        produce_action_list(ge('command_extend'), list, null, cmd_vid_fun, 'cmd_input');

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        ge('cmd_vid_0').focus();
    }
}
