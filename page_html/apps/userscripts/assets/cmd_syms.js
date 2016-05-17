default_value("syms.enabled", "true")

if( GM_getValue('syms.enabled') == "true" ) {
    funs.syms = function() {
        var h = "<br><input id='{%.prep}cmd_sym_val'>"
        h += "<br><span id='{%.prep}cmd_sym_output'></span>";
        ge('command_extend').innerHTML = h;

        below_cmd_input = 'cmd_sym_val';
        var sym_val = ge('cmd_sym_val');
        sym_val.focus();
        sym_val.onkeydown = function(ev) {
            var kc = ev.keyCode;
            if( kc == 13 ) {
                GM_setClipboard(ge('cmd_sym_output').innerHTML);
                finish_commandpanel();
            } else if( kc == 38 && ev.ctrlKey ){
                ge('command_input').focus();
            }
        }
        sym_val.onkeyup = function(ev) {
            ge('cmd_sym_output').innerHTML = "&" + sym_val.value + ";";
        }
    }
}
