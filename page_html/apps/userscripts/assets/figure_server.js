var server_url = GM_getValue('server', "http://localhost:{%port}/");
function send(on_name, data, onload){
    data[0].dumb_pw = GM_getValue('dumb_pw', "{%dumb_pw}");

    var extra = GM_getValue('extra');  // Extra data for doing stuff. And things.
    if(extra){ data[0].extra = extra; }

    pegasus_send(server_url, on_name, data, onload);
}
