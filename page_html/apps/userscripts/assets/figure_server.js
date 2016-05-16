var server_url = GM_getValue('server', "http://localhost:{%port}/");
function send(on_name, data, onload){
    data[0].dumb_pw = GM_getValue('dumb_pw', "{%dumb_pw}");
    pegasus_send(server_url, on_name, data, onload);
}
