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

=a=js/pegasus_send.js
=s=figure_server.js

send('history/.collect', [document.documentURI, document.title || ""],
     function(response_data) {
         // TODO kindah want to figure out the nature of the links/anchors,
         // and try keep track of "what is going on".
         // But the position info might not carry enough information.

         // TODO finished loading?
         var response = JSON.parse(response_data.responseText);

         // NOTE: mirroring done in rather dumb way, as you can see.
         //  just knowing CSS would make it better a bunch.
         if( response.mirror && GM_getValue('may_mirror', true) ) {
             send('history/.collect.mirror',
                  [location.origin + location.pathname + location.search,
                   document.body.innerHTML]);
         }
/*       if( response.anchors && GM_getValue("may_anchors", true) ) {
         }
         if( response.links && GM_getValue("may_links", true) ) {
         }
         if( response.links && GM_getValue("may_images", true) ) {
         }
         // document.applets
         // document.cookie
         if( response.links && GM_getValue("may_scripts", true) ) {
             var s = document.scripts;
             var list = [];
             for( i in s ){
                 list.push([s[i].src, s[i].innerHTML]);
             }
             send("scripts", [data.uri, list]);
         }
         // document.forms
         // document.referrer // Want to control this thing?
*/
     });


/*
function on_ready() {
}

document.addEventListener("click", on_ready);*/
