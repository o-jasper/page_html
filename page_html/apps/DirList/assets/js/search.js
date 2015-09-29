var search_busy = false;
var waiting_search = false;

function rawsearch(str, info, cb) {
    search_busy = true
    callback_search([str, info], cb);
}

var last_search = "";
function do_search() {
    var cur = ge("search_input").value
    if( last_search != cur ) {
        if( search_busy ) {
            ge("waiting").textContent = cur;
            waiting_search = cur;
        } else {
            search_update(cur, 0, 20)
        }
        last_search = cur
    }
}

function search_update(str, fr, to) {
    rawsearch(str, { html_list:true, direct:{ limit:[fr, to] },
                     to_dir:"/home/jasper/proj/decentreddit/page_html/page_html" },
              function(ret) {
                  ge("cnt").textContent = ret.cnt + " results;";
                  var list_el = ge("list")
                  if(ret.html_raw) {
                      list_el.innerHTML = ret.html_raw
                  } else {
                      list_el.hidden = true  // Maybe it helps..
                      list_el.innerHTML = ""
                      for(i in ret.html_list) {
                          var html = ret.html_list[i]
                          var el = document.createElement("TR");
                          el.innerHTML = html;
                          list_el.appendChild(el);
                      }
                      list_el.hidden = false
                  }
                  search_busy = false;
              });
    if(waiting_search){
        waiting_search = false;
        search_update(ge("search_input").value, 0, 20)
    }
}
