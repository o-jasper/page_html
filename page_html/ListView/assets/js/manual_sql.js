// Note: probably want to keep this disabled!

function do_sql_command(sql_cmd) {
    cur = { at_i:0, sql_cmd:sql_cmd, done:false };
    
    // TODO it might not be smart enough for this.. make an element.
    list_el.innerHTML = a.working_row + list_el.innerHTML;
    ge("sql_button").textContent = a.working_short;

    callback_rpc_sql([sql_cmd], function(ret) {
        ge("sql_button").textContent = "Run Sql";
        list_el.innerHTML = "";
        list_extend(ret);
    });
}

function gui_sql_command() {
    do_sql_command(ge("sql").value);
}
