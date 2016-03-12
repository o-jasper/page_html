
// --- Running videos

var cmd_vid_go_uri = function(uri) {
    send('util/.vid', [uri], function(){ finish_commandpanel(); });
}

function cmd_vid() {  // Try open as video.
    ge('command_extend').innerHTML = "working...";

    var is = iface_state;

    var hover_uri = (is.hovered && find_a_href(is.hovered)) || is.hovered_href;
    if( (GM_getValue('cmd_track_cursor') || "yes") != "yes" ) {
        cmd_vid_go_uri(hover_uri || document.documentURI);
    } else {  // NOTE the thing seems not very effective..
        // Get sorted list.
        var know_uri = {}
        know_uri[hover_uri] = true;

        var list = find_closest(
            [is.x, is.y],
            document.getElementsByTagName("A") || document.links,
            (GM_getValue('cmd_vid_range') || 0.2)*window.innerWidth,
            function(el) {
                if(el.href && !know_uri[el.href]) {
                    know_uri[el.href] = true; return true;
                }
            });
        // Enforce a limit on number of items.
        var limit = GM_getValue('cmd_vid_limit_cnt') || 6;
        while( list.length > limit ){ list.pop(); }

        var h = "<table>"
        // TODO this is a pita...
        // TODO now to put the list in..
        var n= 0, entry_list = []
        var add_one = function(str, uri) {
            entry_list.push([n, str, uri])
            h += "<!--" + n + "--><tr><td><button id ='cmd_vid_";
            h += n;
            h += "'>";
            h += str;
            h += "</button></td><td><code>";
            h += uri;
            h += "</code></td></tr>";
            n ++;
        }

        if(hover_uri){ add_one("hovered", hover_uri); }
        add_one("cur page", document.documentURI);

        for( var i in list ) {
            var el = list[i];
            add_one(el.textContent, el.href);
        }

        h += "</table>";

        ge('command_extend').innerHTML = h;
        ge('cmd_vid_0').focus();

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        // Keyboard navigable, and onclick.
        for( var i = 0 ; i < entry_list.length ; i++ ) {
            (function(j, el) {
                el.onclick = function(){ cmd_vid_go_uri(entry_list[j][2]); }
                el.onkeydown = function(ev) {
                    if( ev.keyCode == 40 ) {
                        ge('cmd_vid_' + (j + 1)).focus();
                    } else if( ev.keyCode == 38 ){
                        ge((j == 0) ? 'command_input' : ('cmd_vid_' + (j - 1))).focus();
                    }
                }
                el.onblur = function(ev) {
                    focus_table_list(el, true);
                }
                el.onfocus = function(ev){
                    focus_table_list(el); //cur_sel_list_cleanup);
                }
            })(i, ge('cmd_vid_' + i));
        }
    }
}

