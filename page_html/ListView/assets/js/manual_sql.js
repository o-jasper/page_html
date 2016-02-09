// Note: probably want to keep this disabled!

function do_sql_command(sql_cmd) {
    cur = { at_i:0, sql_cmd:sql_cmd, done:false };
    list_el.innerHTML = "";

    callback_rpc_sql([sql_cmd],
                     function(ret) { list_extend(ret) });
}

function gui_sql_command() {
    do_sql_command(ge("sql").value);
}
