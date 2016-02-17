// Send to pegasus, but w/o the pegasus js available.

function pegasus_send(server_url, on_name, data, onload) {
    var path = on_name.split("/")
    var last = path.pop()

    var full_url = server_url + path.join("/") + "/PegasusJs/" + last;
    var send_data = JSON.stringify({d:data});

    GM_xmlhttpRequest({
        method: 'POST',
        url: full_url,
        data: send_data,
        headers: {
            'Content-Type': "application/x-www-form-urlencoded"
        },
        onload: onload
    });
}
