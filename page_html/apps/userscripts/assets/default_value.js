function default_value(name, to) {
    if( !GM_getValue(name) ) {
        GM_setValue(name, to);
    }
}
