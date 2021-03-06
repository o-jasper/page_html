// --- Quick bookmarks (not good enough!)

default_value('qm.linklist', 'true');

var cmd_make_quickmark_fun = function(el) {
    //TODO
    send('bookmarks/.make_quickmark',
         [{}, el.href, document.title, ge('cmd_qm_name').value, pos_frac],
         function(){ finish_commandpanel(); });
}

function cmd_make_quickmark() {  // Try open as video.
    ge('command_extend').innerHTML = "working...";

    var hover_uri = iface_state.hovered_href;
    var hover_src = iface_state.hovered_src;
    if( GM_getValue('qm.linklist') == "true" ) {
        // Get sorted list.
        var list = [{ textContent:"cur page", href:document.documentURI }];
        if(hover_uri){ list.unshift({ textContent:"hovered", href:hover_uri }); }
        if(hover_src){ list.push({ textContent:"img src", href:hover_src }); }

        ge('command_extend').innerHTML = "<input id='{%.prep}cmd_qm_name' value='default'>";
        produce_action_list(ge('command_extend'), list, null, cmd_make_quickmark_fun,
                            'cmd_qm_name');

        ge('cmd_qm_name').onkeydown = function(ev) {
            if( ev.keyCode == 40 ) {
                ge('cmd_vid_0').focus();
            } else if(ev.keyCode == 38) {
                ge('command_input').focus();
            } else if( ev.keyCode == 13 ) {
                // Enter uses the top one.(hovered or current page)
                cmd_bookmark_fun(list[0]);
            }
        }

        ge('command_input').onkeydown = function(ev) {
            if(ev.keyCode == 40){ ge('cmd_vid_0').focus(); }
        }
        ge('cmd_qm_name').focus();
    } else {
        cmd_make_quickmark_fun({href:hover_uri || hover_src || document.documentURI});
    }
}

var quickmark_prev_name;
var cmd_go_quickmark_fun = function(name) {
    if( quickmark_prev_name != name && name != "" ) {  // Only if changed.
        quickmark_prev_name = name;
        ge('cmd_qm_list').innerHTML = "getting...";
        send('bookmarks/.get_quickmarks_html', [{}, name],
             function(result_obj) {
                 var html_list = JSON.parse(result_obj.responseText)[0];
                 ge('cmd_qm_list_cnt').innerHTML = html_list.length;
                 var h = "";
                 for(var i in html_list) { h += html_list[i]; }
                 ge('cmd_qm_list').innerHTML = h;
             });
    }
}
// TODO this thing doesnt have the needed classes.
//
// TODO can be improved; button to "open all in tabs",
// selecting a subset, "open selected in tabs", deleting.
//
// HOWEVER, consider what you want in the list functionality in general,
// preferably it transfers to _both_
function cmd_go_quickmark() {
    var h = "Name <input id='{%.prep}cmd_qm_name' value='default'>";
    h += "Got <span id='{%.prep}cmd_qm_list_cnt'>(count)</span>";
    h += "<table id='{%.prep}cmd_qm_list'><tr><td colspan=4>(initial)</td></tr></table>";
    ge('command_extend').innerHTML = h;

    var name_el = ge('cmd_qm_name');
    name_el.focus();

    var d = function() {
        list_move(1, 'linked_title', {
            limit_u:function() { ge('cmd_qm_name').focus(); },
            nameprep:"list_el_",
            mirror:{i:0}, linked_title:{i:1},
            order:["mirror", "linked_title"],
        });
    }

    var graph = { //command_input:{ r:'cmd_qm_name',   d:'cmd_qm_name' },
                  cmd_qm_name : { l:'command_input', u:'command_input',
                                  d:d
                                }
                };
    below_cmd_input = 'cmd_qm_name';
    var fg = follow_graph(graph);
    name_el.onkeydown = fg;

    quickmark_prev_name = null;  // Force re-do.
    cmd_go_quickmark_fun(name_el.value); // Default.
    name_el.onkeyup = function(ev) {
        cmd_go_quickmark_fun(name_el.value);
    }
}
