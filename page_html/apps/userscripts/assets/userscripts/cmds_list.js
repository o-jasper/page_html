{%make_bookmark.js}
funs.bm = make_bookmark;

default_value("qm.enabled", "true")
if(GM_getValue("qm.enabled")) {
    {%quickmarks.js} // TODO
    funs.qm = cmd_make_quickmark;
    funs.gqm = cmd_go_quickmark;
}

{%cmd_on_string.js}

default_value('js.enabled', '{%js_enabled}');
// --- Javascript/lua evaluation.
if( GM_getValue('js.enabled') == 'true' ) {
    funs.js  = cmd_on_string(function(str){ alert(eval(str)) }, "Run js");
}

default_value('lua.enabled', '{%lua_enabled}');
// NOTE: doesnt work at this point!
if( GM_getValue('lua.enabled', false) ) {
    funs.lua = cmd_on_string(function(str){
        send('util/.run_lua', [{}, str], function(result_obj) {
            var result = JSON.decode(result_obj.responseText);
            if(result.disallowed) { alert("Disallowed"); }
            else{ alert("Allowed: " + result); }
            finish_commandpanel();
        });
    }, "Run lua(server side, if allowed)", true);
}

{%cmd_syms.js}

// --- Manuals and documentation.
function cmd_opentab(button_str, httpreq) {
    return cmd_on_string(function(str) {
        ge('command_extend').innerHTML +=
            "Working... <code class='minor'>(" + str + ")</code>";
        send(httpreq, [{}, str], function(result_obj){
            var result = JSON.parse(result_obj.responseText);
            if( result.length > 0 ){ GM_openInTab(result); }
            finish_commandpanel();
        });
    }, button_str, true);
}

funs.man   = cmd_opentab("View man page",      'util/.man');
funs.doc   = cmd_opentab("View documentation", 'util/.doc');
funs.pydoc = cmd_opentab("View pydoc page",    'util/.pydoc');

{%cmd_vid.js}
funs.vid = cmd_vid;

{%cmd_mirror.js}
funs.mirror = cmd_mirror;

function cmd_fclip() {  // TODO cliboardData doesn't work?
    ge('command_extend').innerHTML = "Working...";
    send('util/.fclip', [{}], function(result_obj){
        GM_setClipboard(JSON.decode(result_obj.responseText));
        finish_commandpanel();
    })
}
funs.fclip = cmd_fclip;

{%cmd_values.js}
funs.values = cmd_values;
