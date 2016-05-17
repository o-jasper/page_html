// TODO make it a mirror thing.

default_value('mirror.new_tab', "true");
default_value('mirror.list', "true");

var cmd_mirror_fun = function(el) {
    ge('cmd_mirror_say').innerHTML =
        "working...<code class='minor'>(" + el.href + ")</code>";
    send('util/.mirror', [{}, el.href],
         function(result_obj) {
             var tab = JSON.parse(result_obj.responseText);
             if( tab && tab.view_it ) {
                 var uri = tab.pref_uri || tab.m_uri;
                 if(GM_getValue('mirror.new_tab')=="true" && uri != document.documentURI){
                     GM_openInTab(uri);
                 }
             }
             finish_commandpanel();
        });
}

function cmd_mirror() {
    ge('command_extend').textContent = "working...";

    var hover_uri = iface_state.hovered_href;
    var hover_src = iface_state.hovered_src;
    if( GM_getValue('mirror.list') == "true" ) {
        // Get sorted list.  (closest links aren't good enough..)
        var list = [];
        list.unshift({ textContent:"cur page", href:document.documentURI });
        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }
        if(hover_src){ list.push({ textContent:"img src", href:hover_src }); }

        ge('command_extend').innerHTML =
            "<span id='{%.prep}cmd_mirror_say'></span><span id='{%.prep}cmd_mirror_extend'></span>";
        produce_action_list(ge('cmd_mirror_extend'), list, null,
                            cmd_mirror_fun, 'command_input');

        below_cmd_input = 'cmd_vid_0';
        ge('cmd_vid_0').focus();
    } else {
        cmd_mirror_fun({href:hover_uri || hover_src || document.documentURI});
    }
}
