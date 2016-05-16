// --- Running videos

var cmd_vid_fun = function(el) {
    ge('cmd_vid_say').innerHTML =
        "working...<code class='minor'>(" + el.href + ")</code>";
    send('util/.vid', [{}, el.href],
         function(result_obj) {
             var tab = JSON.parse(result_obj.responseText);
             if( tab ) {
                 var on_get_success = function(){
                     var uri = tab.pref_uri || tab.m_uri;
                     if(GM_getValue('new_tab_own_mirror') || uri != document.documentURI){
                         GM_openInTab(uri);
                     }
                 }

                 if(tab.get_it) { // Get result asking to get it via the userscript.
                     GM_xmlhttpRequest({
                         method:'GET', url:el.href,
                         onload:function(result_obj){
                             if( tab.view_it ) {
                                 send('history/.collect.mirror',
                                      [{}, el.href, result_obj.responseText],
                                      tab.view_it && on_get_success);
                             }
                         }})
                 } else{ if( tab.view_it ) {  // Asking to view it.
                     on_get_success();
                 } }
             }
             finish_commandpanel();
        });
}

function cmd_vid() {  // Try open as video.
    ge('command_extend').textContent = "working...";

    var hover_uri = iface_state.hovered_href;
    if( (GM_getValue('cmd_vid_linklist') || "yes") != "yes" ) {
        cmd_vid_fun({href:hover_uri || document.documentURI});
    } else {  // NOTE the thing seems not very effective..
        // Get sorted list.  (closest links aren't good enough..)
        var list = [{ textContent:"cur page", href:document.documentURI }];
        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }

        ge('command_extend').innerHTML =
            "<span id='{%.prep}cmd_vid_say'></span><span id='{%.prep}cmd_vid_extend'></span>";
        produce_action_list(ge('cmd_vid_extend'), list, null, cmd_vid_fun, 'cmd_input');

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        ge('cmd_vid_0').focus();
    }
}
