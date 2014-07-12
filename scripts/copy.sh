#!/bin/sh

DEST='public/vendor'
SRC='bower_components'

cp -r $SRC/semantic-ui/build/packaged/fonts public/ &&
cp -r $SRC/open-sans-fontface/fonts $DEST/ &&
cp $SRC/open-sans-fontface/open-sans.css $DEST/ &&
cp $SRC/notify.js/notify.js $DEST/ &&
cp $SRC/semantic-ui/build/packaged/css/semantic.css $DEST/
# TODO :mithril, pouchdb
