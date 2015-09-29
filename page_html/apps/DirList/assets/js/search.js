function rawsearch(str, info, cb) {
    callback_search([str, info], cb);
}

function do_search() {
    ge("list").innerHTML = ""
    search_update(ge("search_input").value, 0, 20)
}

function touch_search() { do_search(); }

function search_update(str, fr, to) {
    rawsearch(str, { html_list:true, direct:{ limit:[fr, to] },
                     to_dir:"/home/jasper/proj/decentreddit/page_html/page_html" },
              function(ret) {
                  ge("cnt").textContent = ret.cnt + " results;";
                  var list_el = ge("list")
                  if(ret.html_raw) {
                      list_el.innerHTML = ret.html_raw
                  } else {
                      for(i in ret.html_list) {
                          var html = ret.html_list[i]
                          var el = document.createElement("TR");
                          el.innerHTML = html;
                          list_el.appendChild(el);
                      }
                  }
              });
}
