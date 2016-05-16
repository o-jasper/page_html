//  Copyright (C) 05-02-2016 Jasper den Ouden.
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the Afrero GNU General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

// ==UserScript==
// @name        History collector
// @namespace   Jasper
// @description Collects information, including rudementary mirroring.
// @include     *
// @version     0.0
// @grant       GM_getValue
// @grant       GM_xmlhttpRequest
// ==/UserScript==

// Note: no access to `GM_setValue`, so no `default_value`.

{%js/pegasus_send.js}
{%figure_server.js}

send('history/.collect', [{}, document.documentURI, document.title || ""],
     function(response_data) {
         var response = JSON.parse(response_data.responseText);

         // NOTE: mirroring done in rather dumb way, as you can see.
         //  just knowing CSS would make it better a bunch.
         if( response.mirror && GM_getValue('may_mirror', "true") == "true" ) {
             send('history/.collect.mirror',
                  [{}, location.origin + location.pathname + location.search,
                   document.body.innerHTML]);
         }
     });
