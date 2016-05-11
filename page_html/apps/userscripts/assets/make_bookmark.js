// ---- Bookmarks.

// NOTE strongly suggest not editing,
//  to be superseeded by apps/bookmarks/assets/js/bookmark_setup.js

function make_bookmark() {
    var h = "";
    {%parts/make_bookmark.htm}
    ge('command_extend').innerHTML = h;
    ge('cmd_bm_uri').value   = document.documentURI;
    ge('cmd_bm_quote').value = selection;

    // NOTE: otherwise need to escape stuff.(which would be silly)
    ge('cmd_bm_title').value = document.title;

    var graph = {
        command_input : { d :'cmd_bm_uri' },
        cmd_bm_uri    : { d :'cmd_bm_title', u : 'command_input' },
        cmd_bm_title  : { d :'cmd_bm_text',  u : 'cmd_bm_uri' },
        cmd_bm_text   : { d :'cmd_bm_quote', u : 'cmd_bm_title' },
        cmd_bm_quote  : { d :'cmd_bm_tags',  u : 'cmd_bm_text' },
        cmd_bm_tags   : {
            d : 'cmd_bm_submit', u:'cmd_bm_quote',
            r : function(){
                var to = ge('cmd_bm_taglist').childNodes[0];
                if(to){ to.focus(); }
            },
            l : function(){
                var children = ge('cmd_bm_taglist').childNodes;
                var to = children[children.length - 1];
                if(to){ to.focus(); }
            }
        },
        cmd_bm_submit : { u : 'cmd_bm_tags' }
    };
    var fg = follow_graph(graph);

    ge('command_input').onkeydown = fg;
    ge('cmd_bm_uri').onkeydown = fg;
    ge('cmd_bm_title').onkeydown = fg;
    var config = { max_rows:20, cols:90 }
    textarea_update('cmd_bm_text',  fg, config);
    textarea_update('cmd_bm_quote', fg, config);

    var cs = ge('cmd_bm_submit');
    cs.onclick = function() {
        var tag_els = ge('cmd_bm_taglist').childNodes;
        var tag_list = [];
        for(var i in tag_els){
            if( tag_els[i].nodeName == 'BUTTON' ){
                tag_list.push(tag_els[i].textContent);
            }
        }
        send('bookmarks/.collect',
             [ge('cmd_bm_uri').value,
              ge('cmd_bm_title').value,
              ge('cmd_bm_text').value,
              ge('cmd_bm_quote').value,
              tag_list, pos_frac]);

        // TODO instead of returning, respond by telling if success?
        finish_commandpanel();
    }

    cs.onkeydown = function(ev) {  // Cycle _inside_ the thing.
        if( ev.keyCode == 9 ){ ge('command_immediate').focus(); }
        else{ fg(ev); }
        // else if( ev.keyCode == 13 ){ cs.onclick(); }  // Already automatically so.
    }

    var ct = ge('cmd_bm_tags');
    ct.onkeydown = function(ev){
        if( ev.keyCode == 13 ) {
            // TODO shift-enter should focus-and-submit, otherwise,
            //  just select the button-to-submit.(currently not so..)
            if( ct.value.length == 0 ){ cs.focus(); return false; }

            // Add a button signifying the tag, clicking removes.
            var button = document.createElement('button');
            button.textContent = ct.value;
            button.onmouseover = function(){  // TODO use CSS hover instead..
                button.style['text-decoration'] = 'line-through';
            }
            button.onmouseout = function(){ button.style['text-decoration'] = null }

            button.onclick = function(){
                var to = button.nextSibling || button.previousSibling;
                if(to){ to.focus(); } else{ ge('cmd_bm_tags').focus(); }
                ge('cmd_bm_taglist').removeChild(button);
            };

            button.onkeydown = function(ev) {
                if( ev.keyCode == 37 ) {
                    (button.previousSibling || ge('cmd_bm_tags')).focus();
                } else if( ev.keyCode == 39 ) {
                    (button.nextSibling || ge('cmd_bm_tags')).focus();
                } else if( ev.keyCode == 40 ) {
                    ge('cmd_bm_submit').focus();
                } else if( ev.keyCode == 38 ) {
                    ge('cmd_bm_quote').focus();
                }
            }

            // We'll just use this as list of tags too.
            ge('cmd_bm_taglist').appendChild(button);
            ct.value = "";
        }
        fg(ev);
    }

    ge('cmd_bm_text').focus();
}
