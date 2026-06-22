---
title: Lossless GIF recompression via exhaustive search
date: 2026-06-22
description: Exploring GIFs, flexiGIF and LZW compression
---

## A bit of history

GIF is the oldest widespread compressed image format.
Today, it is mostly famous for allowing animations in an image file, but I am not so interested in that use.

Actually, it turns out this was the only image format ever supported by NCSA Mosaic.
Your website must have a GIF fallback for all critical images if it ever wants to truly support old browsers. I'm not talking old as in old Chromium.
I mean actual Mosaic, Netscape, IE, Netsurf, Dillo, Konqueror - like those you can try on [oldweb.today](https://oldweb.today).
(You are probably not interested in supporting them, but this is a fun exercise.)

I really wanted the [1-Click Linux](https://1clicklinux.org) website to look acceptable even in the oldest browsers,
so I decided that I would use `<picture>` with fallback to GIF.
I believe each modern web feature, if used in production, should be reasonably widely compatible on itself already,
and then only have one fallback, which should be the one with absolute 1000% compatibility.

## Problem

The problem is, GIF compression is not impressive.
Let's face it, in 2026 you should most likely only use SVG and WebP (lossy for photos, lossless for small-pallette drawings/logos).
Not PNG, not JPEG, and God forbid AI, DWG or any other proprietary format (looking at you, DICOM).
Well, okay, at least on the web (as the name says, WebP).

A partial solution is to use a small image.
The truly old devices have truly small screen sizes, like 240x320 Nokia phones.
So an icon or logo fallback can safely be 128x128, as 256x256 might not even fit on the screen.

Can we do better? Yes. There is an entire field dedicated to image optimisation, and it starts with stripping metadata.
Then we can remove unused colors from the palette, then remove rarely used colors from the palette, and so on.

But none of the steps above mention actual compression itself!

## ZopfliPNG

I heard about zopflipng. PNG uses DEFLATE, the compression format known from ZIP and GZIP. This is a variant of LZ77 with Huffman coding.
In this format, and quite commonly in other compression formats, there are many different ways to represent the exact same uncompressed data.

DEFLATE is also the name of an algorithm that generates a reasonably compressed input,
and it can be tuned to spend more time compressing in hopes to achieve better compression (for the same data, remember?).
But there are many syntactically valid DEFLATE streams that are never produced by DEFLATE the algorithm,
which is kind of funny, because [you can make a ZIP that contains itself][rzip], but anyway,
some of them are even better than the largest 'compression level'.

Now, Zopfli is the software that performs an exhaustive search across all possible syntactically valid streams,
in order to find what is actually the smallest number of bits to represent the given uncompressed input.
Then ZopfliPNG is the variant that does it for PNG and also explores the PNG pixel encodings.
We need to be careful here, because finding the actual best compression for an arbitrary format can be equivalent to solving the halting problem.
But the compression formats we talk about today have some helpful invariants guaranteeing the search always halts.

[rzip]: https://research.swtch.com/zip

## ZopfliGIF?

There is no ZopfliGIF, but there is flexiGIF, which does almost exactly that.
It is obviously a wonderful tool, and you should go use it on all your GIFs.
But the thing is, GIF uses a very different compression scheme - LZW.
And I found a baffling remark in its README, saying that it can leave files larger than the original algorithm.
This was very suspicious.
So I set out on an exploration. 'It was made by a single human - therefore I can understand it, too.' - thought I.

## LZW

Then I found it a bit difficult to understand, because like all the papers from that time,
the original description insists on building the data format around the algorithm.
But we, decades later, already know that this is a mistake:
for us, interoperability-focused people, the data format is more interesting,
of course, than the algorithm.
Changing the format requires changing the decoder software.
Keep the format, change the encoder software, and enjoy still using the same decoders.
Compatibility.

To save you some time, let me describe it to you: compressed stream consists of actions,
each either saying 'yield this byte',
or naming a previous action and saying 're-do all of this operation again, but then also add the first byte of the action that followed'.
(The edge case of choosing the last action works just fine, and is called KwKwK in the paper.)
(GIF also has an 'end of data' action and a 'zero the state' action, but this is not relevant.)

Simple, right?
Well, it does sound simpler to me at least. Way simpler than starting the understanding by reading 9 lines of compression pseudocode,
and 9 lines of corresponding decompression pseudocode.

Then the algorithm can be simply expressed as the greedy approach, looking at all the previous actions, and taking the longest one that matches what follows.
This is doubly reasonable,
since (a) what is locally best at least has a chance of being globally best,
and (b) it always adds a new 'word' to the 'vocabulary'.

To save you some time, here is an example stream for compression:

```
a b a b a b a a b a a b a a a b
```

One of the possible ways (the greedy way) to split it is:

```
a b a-b a-b-a a-b-a-a b-a a a-b
1. Say a. (no way to say ab; replaying this action will say ab)
2. Say b. (no way to say ba; replaying this action will say ba)
3. Replay action 1. (says ab, no way to say aba; replaying this one will say aba)
4. Replay action 3. (says aba, no way to say abaa; replaying this one will say abaa)
5. Replay action 4. (says abaa, no way to say abaab; replaying this one will say abaab)
6. Replay action 2. (says ba, no way to say baa; replaying this one will say baa)
7. Say a. (no way to say aa; replaying this one will say aa)
8. Replay action 1. (says ab. no way to say abEOF; the last one is never replayed,
                     but it would go aba or abb depending on what would be
                     the first letter of 9)
```

But it is not the only way. Let's see:

```
a b a-b a-b-a a-b-a a-b-a-a a-b
1. Say a. (no way to say ab; replaying this action will say ab)
2. Say b. (no way to say ba; replaying this action will say ba)
3. Replay action 1. (says ab, no way to say aba; replaying this one will say aba)
4. Replay action 3. (says aba, no way to say abaa; replaying this one will say abaa)
5. Replay action 3. (says aba, although 4 would say abaa; replaying this one will say abaa
                     - the same as replaying 4! a wasted dictionary slot!)
6. Replay action 4. (says abaa, no way to say abaab; replaying this one will say abaab)
7. Replay action 1. (says ab. no way to say abEOF; the last one is never replayed,
                     but it would go aba or abb depending on what would be
                     the first letter of 8)
```

One action less! However, notice the note on step 5.

Okay, so back to flexiGIF. The thing done by it is *flexible parsing*.
What this means is that the program does not immediately decide on a furthest-reaching action,
but defers the decision until it knows what would be the furthest-reaching combination of two actions.
Then it emits the first action, but still holds the second one for reassessment.
This is called one-step lookahead. So basically still greedy, but now uses two actions.

In theory, it should be way better, and even optimal,
but what happened on step 5 means there is now a wasted dictionary slot,
and it is lost forever (at least until a reset happens).
So this is why flexiGIF can give worse results.
It fully gives up on greedy compression
and sticks to 'for each (sub)greedy match, find the greedy next match; emit the former'.

## ZGIF

That's where I needed to write my own thing. I was wondering, 'how slow would it be to actually check all the possibilities?'
So I tried it and what have I found out?
GLACIALLY SLOW.
(Here I should note that Python is not the best choice for CPU-bound software.
I want to take the opportunity to learn Zig.)
It takes 4 minutes on my laptop to fully compress a 16x16 image.
That's 256 bytes uncompressed.
And it takes several minutes.
Wow.

I must be computing the same thing several times, right?
(No, it's just things that provide no improvements. The first version took 30 minutes.)

So I decided that there should be an option to make it just a little faster,
by skipping all explorations that cannot be immediately extended beyond what's currently best (uhm, limiting the search to 1-step lookahead).
This worsens the results (does not find the actually best solution),
but going from 4m down to 4s while still beating the current state-of-the-art is a win worth considering.

You can take a look at [the ZGIF repository on SourceHut][zgif].
The code is not in any way clean,
but you can see my thought process in the Git history -
going from A* to dynamic programming to a hybrid search with pruning.

Hope it is useful to you!

[zgif]: https://git.sr.ht/~arusekk/zgif/
