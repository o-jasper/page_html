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
