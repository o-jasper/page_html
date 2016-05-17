default_value('on_string.width', "80")

function cmd_on_string(fun, button_str, dont_finish) {
    return function() {
        ge('command_extend').innerHTML = "<br><textarea id='{%.prep}cmd_js_code'></textarea>" +
            "<br><button id='{%.prep}cmd_submit'>" + button_str + "</button>";

        var graph = {
            //command_input : { d:'cmd_js_code' },
            cmd_js_code   : { u:'command_input', d:'cmd_submit'},
            cmd_submit    : { u:'cmd_js_code' }
        }
        var fg = follow_graph(graph);

        below_cmd_input = 'cmd_js_code';

        var code_el = ge('cmd_js_code');

        code_el.rows = Math.max(code_el.value.split("\n").length, 0);
        code_el.cols = Number(GM_getValue('on_string.width'));

        var cs = ge('cmd_submit');

        cs.onclick = function() {
            fun(code_el.value);
            if(!dont_finish){ finish_commandpanel(); }
        }
        cs.onkeydown = fg;

        code_el.onkeydown = function(ev) {
            code_el.rows = Math.max(code_el.value.split("\n").length, 0);

            if( ev.keyCode == 13 && ev.shiftKey ) { cs.onclick(); }
            fg(ev);
        }
        code_el.focus();
    }
}
