// ---- Bookmarks.
// TODO feel like maybe want bare tag-uri too? (just immediately select the tag?)

function make_bookmark() {
    var h = "";
=a=parts/make_bookmark.htm
    ge('command_extend').innerHTML = h;

    g('cmd_bm_quote').value = selection;

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
