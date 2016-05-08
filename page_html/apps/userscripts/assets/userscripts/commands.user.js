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
// @grant       GM_setClipboard
// @grant       GM_addStyle
// ==/UserScript==

{
    var h = "";
{%css/userscript/commands.css}
{%css/style.css}
{%css/ListView.css}
    GM_addStyle(h);
}

{%js/common.js}
{%js/search_common.js}
{%js/pegasus_send.js}
{%figure_server.js}

{%list_assist.js}

var command_element;

function sayit() {
    alert("Submitted:" + command_element.value);
}

var selection, pos_frac;  // Holds selection, as otherwise lost due to focus change.

var iface_state = {}

document.onmouseover = function(ev){
    var el = ge('CommandPanel'), is = iface_state;
    if(!el || el.hidden){
        is.hovered = ev.target;
        is.hovered_href = is.hovered.href || is.hovered_href;
    }

    is.x = ev.clientX - document.body.clientLeft;
	  is.y = ev.clientY - document.body.clientTop;
}
/*
if( (GM_getValue('cmd_track_cursor') || "yes") == "yes" ) {
    var is = iface_state;
    document.onmousemove = function(ev) {
        is.x = ev.pageX;
        is.y = ev.pageY;
    }
} */

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

        // TODO line around, other styling.
        var h = "";
{%parts/command_panel.htm}
        element.innerHTML = h;

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
    ge('command_input').onkeydown = null;
    toggle_commandpanel(); // Turn off.
}

GM_registerMenuCommand("Command Panel", toggle_commandpanel);

var funs = {};

{%make_bookmark.js}
funs.bm = make_bookmark;

{%quickmarks.js} // TODO
funs.qm = cmd_make_quickmark;
funs.gqm = cmd_go_quickmark;

{%cmd_on_string.js}

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

if( GM_getValue('cmd_syms', true) ) {
    funs.syms = function() {
        ge('command_extend').innerHTML = "<br><input id='cmd_sym_val'><br><span id='cmd_sym_output'></span>";
        var sym_val = ge('cmd_sym_val');
        sym_val.focus();
        sym_val.onkeydown = function(ev) {
            if( ev.keyCode == 13 ) {
                GM_setClipboard(ge('cmd_sym_output').innerHTML);
                finish_commandpanel();
            }
        }
        sym_val.onkeyup = function(ev) {
            ge('cmd_sym_output').innerHTML = "&" + sym_val.value + ";";
        }
    }
}

// --- Manuals and documentation.
function cmd_opentab(button_str, httpreq) {
    return cmd_on_string(function(str) {
        ge('command_extend').innerHTML += "working...";
        send(httpreq, [str], function(result_obj){
            var result = JSON.parse(result_obj.responseText);
            if( result.length > 0 ){ GM_openInTab(result); }
            finish_commandpanel();
        });
    }, button_str, true);
}

funs.man   = cmd_opentab("View man page",      'util/.man');
funs.doc   = cmd_opentab("View documentation", 'util/.doc');
funs.pydoc = cmd_opentab("View pydoc page",    'util/.pydoc');

{%cmd_vid.js}
funs.vid = cmd_vid;

function cmd_fclip() {  // TODO cliboardData doesn't work?
    ge('command_extend').innerHTML = "working...";
    send('util/.fclip', [], function(result_obj){
        GM_setClipboard(JSON.decode(result_obj.responseText));
        finish_commandpanel();
    })
}
funs.fclip = cmd_fclip;

// Keydown listener.

(window.opera ? document.body : document).addEventListener('keydown', function(ev) {
    iface_state.x = ev.pageX;
    iface_state.y = ev.pageY;
    if( ev.ctrlKey && ev.keyCode == 59 ) { // Thats control-;.
        toggle_commandpanel(!ev.shiftKey);
    } else if( command_element && !command_element.hidden ){
        if( ev.keyCode == 27 ) { // Escape.
            ge('command_input').value = "";
            toggle_commandpanel();
            return;
        }
    }
    return false;
}, !window.opera);