a = {working_short:"(w)", working_long:"<span class='working'>...working...</span>",
     table_wid:{%table_wid}};

a.working_row = "<td colspan=" + a.table_wid+ ">" + a.working_long + "</td>";

a.working_row_el = function() {
    var el = document.createElement("TR")
    el.innerHTML = a.working_row;
    return el
}

initial_cnt = {%at_i};
cur = { at_i:initial_cnt, search_term:"{%search_term}" }
step_cnt = {%step_cnt};

