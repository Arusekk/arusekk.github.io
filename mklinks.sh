#!/bin/sh

export HTTEMPLATE='<!DOCTYPE html><html><meta http-equiv=refresh content=1;%s><script>location="%s"+location.hash</script><a href=%s>Moved'
cd public
find * -type d -exec sh -c '[ ! -f $0/index.html ] || printf "$HTTEMPLATE" "${0##*/}" "${0##*/}" "${0##*/}" >$0.html' '{}' \;
ln -fs posts/index.xml atom.xml
