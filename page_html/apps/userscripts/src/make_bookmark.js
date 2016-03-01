// ---- Bookmarks.
// TODO feel like maybe want bare tag-uri too? (just immediately select the tag?)

function make_bookmark() {
    var h = "";
=a=parts/make_bookmark.htm
    ge('command_extend').innerHTML = h;
    ge('cmd_bm_quote').value = selection;

    // NOTE: otherwise need to escape stuff.(which would be silly)
    ge('cmd_bm_title').value = document.title;
    ge('cmd_bm_title').style.width = "100%";

    var graph = {
        cmd_bm_uri   : { d :'cmd_bm_title', u : 'command_input' },
        cmd_bm_title : { ed:true, d :'cmd_bm_text'}, // u : 'cmd_bm_uri' } // TODO
        cmd_bm_text  : { ed:true, sd:true, d : 'cmd_bm_quote', su:true, u : 'cmd_bm_title' },
        cmd_bm_quote : { ed:true, sd:true, d : 'cmd_bm_tags',  su:true, u : 'cmd_bm_text' },
        cmd_bm_tags  : { d : 'cmd_bm_submit', u:'cmd_bm_quote' }, //, l: TODO deleting tags
        cmd_bm_submit: { u : 'cmd_bm_tags' }
    };
    var fg = follow_graph(graph);

    ge('cmd_bm_title').onkeydown = fg
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
        else{ fg(ev); }
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
        fg(ev);
    }

    ge('cmd_bm_text').focus();
}
