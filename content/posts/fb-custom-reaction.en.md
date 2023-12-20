---
title: Facebook messenger custom reactions
date: 2023-12-20
description: You can react with custom reactions on Facebook Messenger and here's how
---

Well, not exactly custom, but you can basically put any string there.
This is a Javascript snippet that makes it possible to change a `:hugging_face:` into `:people_hugging:`.
You can of course change it to turn nearly any emoji to any other emoji.

You can execute it for example by pressing F12 and pasting it in the command line.

**WARNING**: read the code before pasting!
if I was a cybercriminal I could take over your account; this technique is called [Self-XSS][sxss].

**WARNING 2**: by doing this kind of things you might violate some Facebook terms of service,
and you might probably get banned if you are not careful
(take extra caution against accidental spam, maybe practice on a test account).
I however developed it on my official-ish account and did not get banned (yet™).

```js
oldSend=window.oldSend||WebSocket.prototype.send;FBOFFSET=14;
WebSocket.prototype.send = function() {
        try {
                const arg = new Uint8Array(arguments[0]);
                let txt = new TextDecoder().decode(arg.slice(FBOFFSET));
                console.log(txt);
                if (arg.toString() !== [...arg.slice(0,FBOFFSET), ...new TextEncoder().encode(txt)].toString())
                        console.log('AAAAAAAAAAAAAAAAAAAA unsupported!!!', arg.toString());
                else {
                        txt = txt.replace('🤗','🫂');
                        arguments[0] = new Uint8Array([...arg.slice(0,FBOFFSET), ...new TextEncoder().encode(txt)]);
                }
        } catch (e) { console.log(e); } /* dont get me banned pls */
        return oldSend.apply(this, arguments);
}
```

Here's an explanation of how it works: it overwrites (hooks) the browser's internal code (WebSocket sending API)
to replace all occurrences of a specific emoji (`:hugging_face:`) with another one (`:people_hugging:`).
And it takes extra caution not to change anything in case something goes wrong.

It was quite sad to see how a byte array is not a convenient thing in JS, and neither is encoding/decoding UTF-8.
The same code in Python (my personal favourite) would roughly look like (IMO simpler):
```py
if 'oldSend' not in globals():
    oldSend = WebSocket.send
FBOFFSET = 14
def newSend(self, *args):
    try:
        arg = args[0]
        txt = arg[FBOFFSET:].decode()
        print(repr(txt))
        if repr(arg) != repr(arg[:FBOFFSET] + txt.encode()):
            print('AAAAAAAAAAAAAAAAAAAA unsupported!!!', repr(arg))
        else:
            txt = txt.replace('🤗','🫂')
            args = txt.encode(), *args[1:]
    except Exception as e:
        print(e)
    return oldSend(self, *args)
WebSocket.send = newSend
```

[sxss]: https://en.wikipedia.org/wiki/Self-XSS
