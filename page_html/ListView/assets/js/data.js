config = {
    list_el_nameprep : "{%list_el_nameprep}",
    sql_textarea : { max_rows:10, cols:90 },
    step_cnt : {%step_cnt},
    sql_enabled : {%sql_enabled},
    list_names : {%list_names},
}

a = {working_short:"(w)", working_long:"<span class='working'>...working...</span>",
     table_wid:{%table_wid}};

a.working_row_ = "<td colspan=" + a.table_wid+ ">" + a.working_long;

a.working_row_el = function(extra) {
    var el = document.createElement("TR")
    el.innerHTML = (a.working_row_ + (extra || "") + "</td>");
    return el
}

initial_cnt = {%at_i};
cur = { at_i:initial_cnt, search_term:"{%search_term}" }

search_continuous = true;
