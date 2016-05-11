function cmd_bm_add_tag(prep, name) {
    // Add a button signifying the tag, clicking removes.
    var button = document.createElement('button');
    button.textContent = name;
    button.onmouseover = function(){  // TODO use CSS hover instead..
        button.style['text-decoration'] = 'line-through';
    }
    button.onmouseout = function(){ button.style['text-decoration'] = null }

    button.onclick = function(){
        var to = button.nextSibling || button.previousSibling;
        if(to){ to.focus(); } else{ ge(prep + 'bm_tags').focus(); }
        ge(prep + 'bm_taglist').removeChild(button);
    };

    button.onkeydown = function(ev) {
        if( ev.keyCode == 37 ) {
            (button.previousSibling || ge(prep + 'bm_tags')).focus();
        } else if( ev.keyCode == 39 ) {
            (button.nextSibling || ge(prep + 'bm_tags')).focus();
        } else if( ev.keyCode == 40 ) {
            ge(prep + 'bm_submit').focus();
        } else if( ev.keyCode == 38 ) {
            ge(prep + 'bm_quote').focus();
        }
    }
    // We'll just use this as list of tags too.
    ge(prep + 'bm_taglist').appendChild(button);
}


function cmd_bm_fill_data(prep, data) {
    ge(prep + "bm_uri").value   = data.uri;
    ge(prep + "bm_title").value = data.title;
    ge(prep + "bm_text").value  = data.text;
    ge(prep + "bm_quote").value = data.quote;
    for(var i in (data.tags || [])){ cmd_bm_add_tag(prep, data.tags[i]); }
}

function cmd_bm_setup(prep, data, top, bottom, update_values, finished) {
    cmd_bm_fill_data(prep, data);

    var graph = {
        extra_prep : prep,
        bm_uri    : { d : 'bm_title', u : top },
        bm_title  : { d : 'bm_text',  u : 'bm_uri' },
        bm_text   : { d : 'bm_quote', u : 'bm_title' },
        bm_quote  : { d : 'bm_tags',  u : 'bm_text' },
        bm_tags   : {
            d : 'bm_submit', u: 'bm_quote',
            r : function(){
                var to = ge(prep + 'bm_taglist').childNodes[0];
                if(to){ to.focus(); }
            },
            l : function(){
                var children = ge(prep + 'bm_taglist').childNodes;
                var to = children[children.length - 1];
                if(to){ to.focus(); }
            }
        },
        bm_submit : { u : 'bm_tags', d : bottom, r : 'bm_cancel', l : 'bm_cancel' },
        bm_cancel : { u : 'bm_tags', d : bottom, r : 'bm_submit', l : 'bm_submit'  },
    };
    var fg = follow_graph(graph);
    for( var to_name in graph ){
        if(to_name!='extra_prep'){ ge(prep + to_name).onkeydown = fg; }
    }

    var cs = ge(prep + 'bm_submit');
    cs.onclick = function() {
        var tag_els = ge(prep + 'bm_taglist').childNodes;
        var tag_list = [];
        for(var i in tag_els) {  // Buttons store the tags. (is it bad?)
            if( tag_els[i].nodeName == 'BUTTON' ){
                tag_list.push(tag_els[i].textContent);
            }
        }
        update_values({ uri   : ge(prep + 'bm_uri').value,
                        title : ge(prep + 'bm_title').value,
                        text  : ge(prep + 'bm_text').value,
                        quote : ge(prep + 'bm_quote').value,
                        tags : tag_list });
        finished();
    }

    ge(prep + 'bm_cancel').onclick = function(){ finished(); }


    var ct = ge(prep + 'bm_tags');
    ct.onkeydown = function(ev){
        if( ev.keyCode == 13 ) {  // Submit.
            // TODO shift-enter should focus-and-submit, otherwise,
            //  just select the button-to-submit.(currently not so..)
            if( ct.value.length == 0 ){ cs.focus(); return false; }
            cmd_bm_add_tag(prep, ct.value);
            ct.value = "";
        }
        fg(ev);  // Go for the regular graph motions.
    }
}
