if( GM_getValue('cmd_syms', true) ) {
    funs.syms = function() {
        var h = "<br><input id='{%.prep}cmd_sym_val'>"
        h += "<br><span id='{%.prep}cmd_sym_output'></span>";
        ge('command_extend').innerHTML = h;

        var sym_val = ge('cmd_sym_val');
        sym_val.focus();
        sym_val.onkeydown = function(ev) {
            if( ev.keyCode == 13 ) {
                GM_setClipboard(ge('cmd_sym_output').innerHTML);
                finish_commandpanel();
            }
        }
        sym_val.onkeyup = function(ev) {
            ge('cmd_sym_output').innerHTML = "&" + sym_val.value + ";";
        }
    }
}
