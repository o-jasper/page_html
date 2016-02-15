// Note: probably want to keep this disabled!

function do_sql_command(sql_cmd) {
    cur = { at_i:0, sql_cmd:sql_cmd, done:false };
    
    prepend_child(ge('list'), a.working_row_el());
    ge("sql_button").textContent = a.working_short;

    callback_rpc_sql([sql_cmd], function(ret) {
        ge("sql_button").textContent = "Run Sql";
        ge('list').innerHTML = "";
        list_extend(ret);
    });
}

function gui_sql_command() { do_sql_command(ge("sql").value); }
