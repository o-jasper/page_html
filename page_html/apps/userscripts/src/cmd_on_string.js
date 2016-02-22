
function cmd_on_string(fun, button_str, dont_finish) {
    return function() {
        ge('command_extend').innerHTML = "<br><textarea id='cmd_js_code'></textarea>" +
            "<br><button id='cmd_submit'>" + button_str + "</button>";

        var code_el = ge('cmd_js_code');

        code_el.rows = Math.max(code_el.value.split("\n").length, 0);
        code_el.cols = GM_getValue('reasonable_width', 80);

        var cs = ge('cmd_submit');

        cs.onclick = function() {
            fun(code_el.value);
            if(!dont_finish){ finish_commandpanel(); }
        }

        code_el.onkeydown = function(ev) {
            code_el.rows = Math.max(code_el.value.split("\n").length, 0);

            if( ev.keyCode == 13 && ev.shiftKey ) { cs.onclick(); }
        }
        code_el.focus();
    }
}
