
// Closest links sorted
function find_cursor_closest_links(limit, got_uri) {
    var know_uri = {}
    if(typeof(got_uri) == 'string') { know_uri[got_uri] = true; }
    else{ for( var k in got_uri ){ know_uri[k] = true; } }

    var list = find_closest_els(
        [iface_state.x, iface_state.y],
        document.getElementsByTagName("A") || document.links,
        (GM_getValue('cmd_vid_range') || 0.2)*window.innerWidth,
        function(el) {
            if(el.href && !know_uri[el.href]) {
                know_uri[el.href] = true; return true;
            }
        });
    // Enforce a limit on number of items.
    var limit = limit || GM_getValue('cmd_vid_limit_cnt') || 6;
    while( list.length > limit ){ list.pop(); }
    return list;
}

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

        activated_list(ge('command_extend'), list,
                       "<!--{%i}--><tr><td><button id ='cmd_vid_{%i}'>" + 
                       "{%textContent}</button></td><td><code>{%href}</code></td></tr>",
                       function(el, j) {
                           var set = ge('cmd_vid_' + j);
                           set.onclick = function(){ cmd_vid_go_uri(el.href); }
                           set.onkeydown = function(ev) {
                               if( ev.keyCode == 40 ) {
                                   ge('cmd_vid_' + (j+1)).focus();
                               } else if( ev.keyCode == 38 ){
                                   ge((j == 0) ? 'command_input' :
                                      ('cmd_vid_' + (j - 1))).focus();
                               }
                           }
                           set.onblur = function(ev) {
                               focus_table_list(set, true);
                           }
                           set.onfocus = function(ev){
                               focus_table_list(set); //cur_sel_list_cleanup);
                           }
                       });

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        ge('cmd_vid_0').focus();
    }
}
