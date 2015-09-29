var search_busy = false;
var waiting_search = false;

function rawsearch(str, info, cb) {
    search_busy = true
    callback_search([str, info], cb);
}

var last_search = "";
function do_search() { search(ge("search_input").value); }

function search(cur) {
    if( last_search != cur ) {
        if( search_busy ) {
            ge("waiting").textContent = cur;
            waiting_search = cur;
            ge("search_working").textContent = "W";
        } else {
            search_update(cur, 0, 20)
        }
        last_search = cur
    }
}

function search_update(str, fr, to) {
    ge("search_working").textContent = "X";
    rawsearch(str, { html_list:true, direct:{ limit:[fr, to] },
                     to_dir:"/home/jasper/proj/decentreddit/page_html/page_html" },
              function(ret) {
                  ge("cnt").textContent = ret.cnt + " results;";
                  var list_el = ge("list")
                  if(ret.html_raw) {
                      list_el.innerHTML = ret.html_raw
                  } else {
                      // TODO kindah want a mode where they can be added w/o resetting.
                      var html = ""
                      for(i in ret.html_list) {
                          html = html + ret.html_list[i]
                      }
                      list_el.innerHTML = html
                  }
                  search_busy = false;
                  ge("search_working").textContent = "V";
                  if(waiting_search){
                      waiting_search = false;
                      search_update(ge("search_input").value, 0, 20)
                  }
              });
}
