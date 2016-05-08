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

// Enter a list of actions, defaultly of links.

function produce_action_list(into, list, html, go_action, before_id, after_id) {
    activated_list(into, list,
                   html || ("<!--{%i}--><tr><td><button id='{%.prep}cmd_vid_{%i}'>" +
                            "{%textContent}</button></td><td>" + 
                            "<a href='{%href}'><code>{%href}</code></a></td></tr>"),
                   function(el, j) {
                       var set = ge('cmd_vid_' + j);
                       set.onclick = function(){ go_action(el, j); }
                       set.onkeydown = function(ev) {
                           if( ev.keyCode == 40 ) {
                               ge((after_id && j == list.length-1) ? after_id :
                                  'cmd_vid_' + (j+1)).focus();
                           } else if( ev.keyCode == 38 ){
                               ge((before_id && j == 0) ? before_id :
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
}
