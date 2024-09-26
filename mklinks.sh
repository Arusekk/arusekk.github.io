#!/bin/sh

cd public

export HTTEMPLATE='<!DOCTYPE html><html><meta http-equiv=refresh content="0;url=%s"><script>location.replace("%s"+location.hash)</script><a href="%s">Moved'
find * -type d -exec sh -c '[ ! -f $0/index.html ] || printf "$HTTEMPLATE" "${0##*/}/" "${0##*/}/" "${0##*/}/" >$0.html' '{}' \;
find -name index.html -print0 | xargs -0 sed -i 's@href="\([^/".]*\)\.md"@href="../\1/"@g'
ln -fs posts/index.xml atom.xml
