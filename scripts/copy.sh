#!/bin/sh

DEST='public/vendor'
SRC='bower_components'

cp -r $SRC/semantic-ui/build/packaged/fonts public/ &&
cp -r $SRC/open-sans-fontface/fonts $DEST/ &&
cp $SRC/open-sans-fontface/open-sans.css $DEST/ &&
cp $SRC/moment/min/moment.min.js $DEST/ &&
cp $SRC/moment/locale/fr.js $DEST/moment-fr.js &&
cp $SRC/underscore/underscore-min.js $DEST/ &&
cp $SRC/semantic-ui/build/packaged/css/semantic.css $DEST/ &&
cp $SRC/semantic-ui/build/minified/modules/dimmer.min.js $DEST/ &&
cp $SRC/semantic-ui/build/minified/modules/modal.min.js $DEST/ &&
cp $SRC/semantic-ui/build/minified/modules/popup.min.js $DEST/ &&
cp $SRC/pouchdb/dist/pouchdb.min.js $DEST/ &&
cp $SRC/lightrouter/dist/lightrouter.min.js $DEST/ &&
cp $SRC/jquery/dist/jquery.min.js $DEST/ &&
cp $SRC/chosen_v1.2.0/chosen.jquery.min.js $DEST/ &&
cp $SRC/reactive-coffee/dist/reactive-coffee.js $DEST/
