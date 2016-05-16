
function values_figure_table(search) {
    var str = "";
    for each (var key in GM_listValues()) {
        if( key.search(search) >= 0 ) {
            var val = GM_getValue(key);
            str +=  "<tr><td>" + key + "</td><td>" + val + "</td></tr>";
        }
    }
    return str;
}

function values_act() {
    var key = ge('list_search').value, val = ge('values_set').value;
    if( key == "" ){ return; }
    else if( val == "" ){
        GM_deleteValue(key);
    } else {
        GM_setValue(key, val);
    }
    // Update the list.
    ge('values_list_table').innerHTML = values_figure_table(ge('list_search').value);
}

function cmd_values() {
    var str = '<input id="{%.prep}list_search">'
    str += '<input id="{%.prep}values_set">'
    str += '<button id="{%.prep}values_button">Delete&larr;fill to set</button>';
    str += '<table id="{%.prep}values_list_table">'
    str += values_figure_table("") + '</table>';
    ge('command_extend').innerHTML = str;

    var search_keyup = function(ev){
        ge('values_list_table').innerHTML = values_figure_table(ge('list_search').value);
        if( ev.ctrlKey ){
            var kc = ev.keyCode;
            if( kc == 38 || kc == 37 ){ ge('command_input').focus(); }
            else if( kc == 40 || kc == 13 ||  kc == 39 ){
                ge('values_set').focus();
            }
        }
    }
    ge('list_search').onkeyup = search_keyup;
    ge('list_search').focus();

    var set_keyup = function(ev){
        ge('values_button').textContent =
            (ge('values_set').value.length > 0 ? "Set" : "Delete");
        var kc = ev.keyCode;
        if( kc == 13 ){ values_act(); }
        else if( ev.ctrlKey && (kc == 38 || kc == 37) ){ ge('list_search').focus(); }
        else if( ev.ctrlKey && (kc == 40 || kc == 39) ){ ge('values_button').focus(); }
    }
    ge('values_set').onkeyup = set_keyup;

    var button_keyup = function(ev) {
        var kc = ev.keyCode;
        if(ev.ctrlKey && (kc == 38 || kc == 37) ){ ge('values_set').focus(); }
    }
    ge('values_button').onkeyup = button_keyup;
    ge('values_button').onclick = values_act;
}
