var server_url = GM_getValue('server', "http://localhost:9090/");
function send(on_name, data, onload){ pegasus_send(server_url, on_name, data, onload); }
