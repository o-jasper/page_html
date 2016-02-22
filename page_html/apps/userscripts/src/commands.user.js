//  Copyright (C) 05-02-2016 Jasper den Ouden.
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the Afrero GNU General Public License as published
//  by the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

// ==UserScript==
// @name        Commands
// @namespace   Jasper
// @description Commands hub
// @include     *
// @include     file://*
// @version     0.0
// @grant       GM_getValue
// @grant       GM_registerMenuCommand
// @grant       GM_xmlhttpRequest
// @grant       GM_openInTab
// ==/UserScript==

=a=js/common.js
=a=js/pegasus_send.js
=s=figure_server.js

var command_element;

function sayit() {
    alert("Submitted:" + command_element.value);
}

var selection, pos_frac;  // Holds selection, as otherwise lost due to focus change.
var hovered, hovered_href;

document.onmouseover = function(ev){
    var el = ge('CommandPanel');
    if(!el || el.hidden){
        hovered = ev.target;
        hovered_href = hovered.href || hovered_href;
    }
}

function currentPosFraction()
{
    var el = document.documentElement;

    var w = el.scrollHeight;// - el.clientHeight;
    var h = el.scrollWidth; //  - el.clientWidth;

    var x = el.scrollTop;  //  + d.body.scrollTop;
    var y = el.scrollLeft; // + d.body.scrollLeft;

// TODO better to just pass w,h along?
    return [x/w, y/h]
}

// TODO separate each portion.

var commandpanel_html =
    "Cmd <input id='command_immediate' type='checkbox'>" +
    "<input id='command_input' onsubmit='sayit();' onkeydown='sayit();'>" +
    "<button onclick='sayit();'>Do</button>" +
    "<span id='command_extend'</span>";

function toggle_commandpanel(immediate) {
    selection = window.getSelection().toString();
    pos_frac  = currentPosFraction();

    if( command_element ) {
        command_element.hidden = !command_element.hidden;
    } else {
        var document = window.document;

        var element = command_element || document.createElement('div');
        command_element = element;

        element.id = 'CommandPanel'

        var style = element.style
        style.borderWidth = "0.1em";
        style.borderRadius = "0.3em";
        style.borderColor = "#000"

        style.position = 'fixed';
        style.top  = "1em";
        style.left = "1em";
        style.padding = "2em";
        style.backgroundColor = "#fff";
        style['z-index'] = 1e16;

        // TODO line around.
        element.innerHTML = commandpanel_html;

        document.body.appendChild(element);

        // Run stuff if complete inputs.
        ge('command_input').oninput = function(){
            var ci = ge('command_input');
            // Strip out the command starter.
            ci.value = ci.value.replace(";", "");

            if( ge('command_immediate').checked ) {
                var fun = funs[ci.value];
                if(fun && fun()) {
                    ci.value = "";
                    toggle_commandpanel();
                }
            }
        }
    }
    ge('command_immediate').checked = immediate;
    if( command_element.hidden ) {
        ge('command_input').blur();
        // TODO kindah want to select the thing we left.
    } else {
        ge('command_input').focus();
    }
}

function finish_commandpanel() {
    ge('command_extend').innerHTML = ""; // Clean up.
    ge('command_input').value = "";
    toggle_commandpanel(); // Turn off.
}

GM_registerMenuCommand("Command Panel", toggle_commandpanel);

var funs = {};

// ---- Bookmarks.
// TODO feel like maybe want bare tag-uri too? (just immediately select the tag?)

function bookmark() {
    var h = "<span style='font-size:150%; text-weight:bold'>Bookmark</span><table>";
    h += "<tr><td>Title:</td><td><input type='text' id='cmd_bm_title'></td></tr>";
    h += "<tr><td>Text:</td><td><textarea id='cmd_bm_text'></textarea><br>";
    h += "<tr><td>Quote:</td><td><textarea id='cmd_bm_quote'>";
    h += selection + "</textarea></td></tr>";
    // TODO tags enter-to-add-1 and make them buttons-to-remove one.
    h += "<tr><td>Tags</td><td><input type='text' id='cmd_bm_tags'>";
    h += "<span id='cmd_bm_taglist'></span></td></tr>";
    h += "<tr><td span=2><button id='cmd_bm_submit'>Submit</button></td></tr>";
    h += "</table>";
    ge('command_extend').innerHTML = h;

    // NOTE: otherwise need to escape stuff.(which would be silly)
    ge('cmd_bm_title').value = document.title;
    ge('cmd_bm_title').style.width = "100%";

    ge('cmd_bm_title').onkeydown = next_prev('cmd_bm_text');
    textarea_update('cmd_bm_text',  next_prev('cmd_bm_quote', 'cmd_bm_title', true));
    textarea_update('cmd_bm_quote', next_prev('cmd_bm_tags',  'cmd_bm_text',  true));

    var cs = ge('cmd_bm_submit');
    cs.onclick = function() {
        var tag_els = ge('cmd_bm_taglist').childNodes;
        var tag_list = [];
        for(i in tag_els){
            if( tag_els[i].nodeName == 'BUTTON' ){
                tag_list.push(tag_els[i].textContent);
            }
        }
        send('bookmarks/.collect',
             [document.documentURI,
              ge('cmd_bm_title').value,
              ge('cmd_bm_text').value,
              ge('cmd_bm_quote').value,
              tag_list, pos_frac]);

        // TODO instead of returning, respond by telling if success?
        finish_commandpanel();
    }

    cs.onkeydown = function(ev) {  // Cycle _inside_ the thing.
        if( ev.keyCode == 9 ){ ge('command_immediate').focus(); }
        // else if( ev.keyCode == 13 ){ cs.onclick(); }  // Already automatically so.
    }

    var ct = ge('cmd_bm_tags');
    ct.onkeydown = function(ev){
        if( ev.keyCode == 13 ) {
            // TODO shift-enter should focus-and-submit, otherwise,
            //  just select the button-to-submit.(currently not so..)
            if( ct.value.length == 0 ){ cs.focus(); return; }

            // Add a button signifying the tag, clicking removes.
            var button = document.createElement('button');
            button.textContent = ct.value;
            button.onmouseover = function(){  // TODO use CSS hover instead..
                button.style['text-decoration'] = 'line-through';
            }
            button.onmouseout = function(){ button.style['text-decoration'] = null }
            button.onclick = function(){ ge('cmd_bm_taglist').removeChild(button); };

            // We'll just use this as list of tags too.
            ge('cmd_bm_taglist').appendChild(button);
            ct.value = "";
        }
        next_prev(false, 'cmd_bm_quote')(ev);
    }

    ge('cmd_bm_text').focus();
}

function cmd_on_string(fun, button_str, dont_finish) {
    return function() {
        ge('command_extend').innerHTML = "<br><textarea id='cmd_js_code'></textarea>" +
            "<br><button id='cmd_submit'>" + button_str + "</button>";

        var code_el = ge('cmd_js_code');

        code_el.rows = Math.max(code_el.value.split("\n").length, 0);
        code_el.cols = GM_getValue('reasonable_width', 80);

        var cs = ge('cmd_submit');

        cs.onclick = function() {
            fun(code_el.value);
            if(!dont_finish){ finish_commandpanel(); }
        }

        code_el.onkeydown = function(ev) {
            code_el.rows = Math.max(code_el.value.split("\n").length, 0);

            if( ev.keyCode == 13 && ev.shiftKey ) { cs.onclick(); }
        }
        code_el.focus();
    }
}

funs.bm = bookmark;

// --- Javascript/lua evaluation.
if( GM_getValue('cmd_js', false) ) {
    funs.js  = cmd_on_string(function(str){ alert(eval(str)) }, "Run js");
}

// NOTE: doesnt work at this point!
if( GM_getValue('cmd_lua', false) ) {
    funs.lua = cmd_on_string(function(str){
        send('util/.run_lua', [str], function(result_obj) {
            var result = JSON.decode(result_obj.responseText);
            if(result.disallowed) { alert("Disallowed"); }
            else{ alert("Allowed: " + result); }
            finish_commandpanel();
        });
    }, "Run lua(server side, if allowed)", true);
}

// --- Manuals and documentation.
function cmd_opentab(button_str, httpreq) {
    return cmd_on_string(function(str) {
        send(httpreq, [str], function(result_obj){
            var result = JSON.parse(result_obj.responseText);
            if( result.length > 0 ){ GM_openInTab(result); }
        });
    }, button_str);
}

funs.man   = cmd_opentab("View man page",      'util/.man');
funs.doc   = cmd_opentab("View documentation", 'util/.doc');
funs.pydoc = cmd_opentab("View pydoc page",    'util/.pydoc');

function find_a_href(el) {
    var href = el.href;
    for(i in el.children){
        if( href ){ return href; }
        href = find_a_href(el.children[i])
    }
    return href;
}

// --- Running videos

function cmd_vid() {  // Try open as video.
    // TODO hackish, just want the hovered link...
    var href = find_a_href(hovered) || hovered_href;

    send('util/.vid', [href || document.documentURI]);

    finish_commandpanel();
}
funs.vid = cmd_vid;

// Keydown listener.

(window.opera ? document.body : document).addEventListener('keydown', function(ev) {
    if( ev.ctrlKey && ev.keyCode == 59 ) { // Thats control-;.
        toggle_commandpanel(!ev.shiftKey);
    } else if( command_element && !command_element.hidden ){
        if( ev.keyCode == 27 ) { // Escape.
            toggle_commandpanel();
            return;
        }
    }
    return false;
}, !window.opera);
