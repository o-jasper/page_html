//  Copyright (C) 05-02-2016 Jasper den Ouden.
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the Afrero GNU General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

// ==UserScript==
// @name        Page mirrorer
// @namespace   Jasper
// @description Just mirrors, note that effectively, history, due to timestamps.
// @include     *
// @version     0.0
// @grant       GM_getValue
// @grant       GM_xmlhttpRequest
// ==/UserScript==

// Where to send information.
var server_url = GM_getValue('server', "http://localhost:9090/");

function send(on_name, data, onload) {
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

function send(on_name, data, onload) {
    var full_url = server_url + on_name;
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

if( response.mirror && GM_getValue('direct.may_mirror', true) ) {
    send('history/.collect.mirror',
         [location.origin + location.pathname + location.search,
          document.body.innerHTML]);
}
