#!/bin/sh

DEST='public/vendor'
SRC='node_modules'

cp -r $SRC/semantic-ui/build/packaged/fonts public/ &&
cp -r $SRC/open-sans-fontface/fonts $DEST/ &&
cp $SRC/open-sans-fontface/open-sans.css $DEST/ &&
cp $SRC/notify.js/notify.js $DEST/ &&
cp $SRC/moment/min/moment.min.js $DEST/ &&
cp $SRC/moment/locale/fr.js $DEST/moment-fr.js &&
cp $SRC/semantic-ui/build/packaged/css/semantic.css $DEST/ &&
cp $SRC/pouchdb/dist/pouchdb.min.js $DEST/ &&
cp $SRC/mithril/mithril.js $DEST/
