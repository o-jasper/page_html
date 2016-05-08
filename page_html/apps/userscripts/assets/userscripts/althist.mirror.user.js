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

{%js/pegasus_send.js}
{%figure_server.js}

if( response.mirror && GM_getValue('direct.may_mirror', true) ) {
    send('history/.collect.mirror',
         [location.origin + location.pathname + location.search,
          document.body.innerHTML]);
}
