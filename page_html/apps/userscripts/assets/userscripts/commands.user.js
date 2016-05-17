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
// @version     0.0.3
// @grant       GM_getValue
// @grant       GM_setValue
// @grant       GM_deleteValue
// @grant       GM_listValues
// @grant       GM_registerMenuCommand
// @grant       GM_xmlhttpRequest
// @grant       GM_openInTab
// @grant       GM_setClipboard
// @grant       GM_addStyle
// ==/UserScript==

{%default_value.js}

{
    var h = "";
{%css/userscript/commands.css}
{%css/style.css}
{%css/ListView.css}
    GM_addStyle(h);
}

{%js/common.js}
{%js/less_common.js}
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
    var is = iface_state;
    is.hovered = ev.target;
    is.hovered_href = is.hovered.href || is.hovered_href;
    is.hovered_src  = is.hovered.src || is.hovered_src;

//    is.x = ev.clientX - document.body.clientLeft;
//	  is.y = ev.clientY - document.body.clientTop;
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

var focus_from;  // Where the focus came from.(hopefully)
below_cmd_input = null;

function toggle_commandpanel(immediate) {
    selection = window.getSelection().toString();
    pos_frac  = currentPosFraction();

    var document = window.document;
    if( command_element ) {  // Already exists, just toggle.
        command_element.hidden = !command_element.hidden;
    } else {
// Doesnt exist yet, make and enable.
        var element = document.createElement('div');
        command_element = element;
        element.id = '{%.prep}CommandPanel'

        var h = "";  // TODO damn styles enter it...
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
        var inp_onkeydown = function(ev) {
            if(below_cmd_input && ev.ctrlKey ){
                var kc = ev.keyCode;
                if( kc == 40 ){ ge(below_cmd_input).focus(); }
            }
        }
        ge('command_input').onkeydown = inp_onkeydown;
    }
    ge('command_immediate').checked = immediate;
    if( command_element.hidden ) {
        ge('command_input').blur();
        if( focus_from ) { focus_from.focus(); focus_from = null; }
    } else {
        focus_from = document.activeElement;
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

{%userscripts/cmds_list.js}

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
