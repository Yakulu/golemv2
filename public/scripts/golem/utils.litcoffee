# Common utilities

## Title

`title` is a very simple utility helping setting a suffix to the document's
title, keeping the real title in place

    title = (suffix) -> "#{L 'TITLE'} - #{suffix}"

## Public API

    golem.utils =
      title: title
