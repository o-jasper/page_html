// TODO make it a mirror thing.

var cmd_mirror_fun = function(el) {
    ge('cmd_mirror_say').innerHTML =
        "working...<code class='minor'>(" + el.href + ")</code>";
    send('util/.mirror', [{}, el.href],
         function(result_obj) {
             var tab = JSON.parse(result_obj.responseText);
             if( tab && tab.view_it ) {
                 var uri = tab.pref_uri || tab.m_uri;
                 if(GM_getValue('new_tab_own_mirror') || uri != document.documentURI){
                     GM_openInTab(uri);
                 }
             }
             finish_commandpanel();
        });
}

function cmd_mirror() {
    ge('command_extend').textContent = "working...";

    var hover_uri = iface_state.hovered_href;
    if( (GM_getValue('cmd_mirror_linklist') || "yes") != "yes" ) {
        cmd_mirror_fun({href:hover_uri || document.documentURI});
    } else {  // NOTE the thing seems not very effective..
        // Get sorted list.  (closest links aren't good enough..)
        var list = [];
        list.unshift({ textContent:"cur page", href:document.documentURI });
        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }

        ge('command_extend').innerHTML =
            "<span id='{%.prep}cmd_mirror_say'></span><span id='{%.prep}cmd_mirror_extend'></span>";
        produce_action_list(ge('cmd_mirror_extend'), list, null, cmd_mirror_fun, 'cmd_input');

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_mirror_0').focus(); }
        }
        ge('cmd_mirror_0').focus();
    }
}
