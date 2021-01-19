---
title: I translated Git!
date: 2020-12-27
description: Linguistic digressions on how hard it is to translate stuff
---

I found that Git has no Polish translation!
Terrible feeling, right?

So now it has one.
I spent every evening for a month before Christmas on translating it.

So here are the main things I noticed:

1. Software designers (or whoever does the things I mean) are very anglocentric.
They mostly don't care about other languages, even the similar ones,
not to mention [the exotic][wine-icu] (search for *designed well*).
The Polish analogue would be "dwie" for two (female).

[wine-icu]: https://www.winehq.org/interview/16

2. English word formation is endemic.
An example is adjective nominalization.
Many nouns formed from adjectives need to be translated as the whole phrase.
They say "laptop" for a laptop computer, "remote" for a remote control
(in git "remote" == remote repository, "upstream" == upstream branch),
"English" for an English citizen, "television" for television set,
"pickle" for pickled cucumber, "glass" for a glass cup,
"flat" for a flat apartment, "review" for a review document,
"plastic" for plastic material, "composite" for composite material,
"wearable" for wearable equipment and so on.

In Polish, we say some of those from English, but we tend to be more like
saying "control" for remote control, "material" for composite material,
"equipment" for wearable equipment, "cucumber" for a pickled cucumber,
and for the rest we make sure that they are different from their base word
(those words are an attempt at literal translation,
so almost certainly none of them exist):
"livement" for a flat, "Englisher", "televisor", "glassie", "reviewment".

In Polish, all nouns have inherent invariable gender,
and all adjectives have every gender, and by design they cannot be the same.
One can easily form adjectives from nouns, which is the equivalent of adding
"-y", "-ing" or "-ish" in English.

Like "blaze" -> "blazy", "blazing" or "blazish" would be
"płomień" -> "płomienny", "płomienisty", "płomieniowy" or "płomiennawy".

But guess what? The oposite is not as easy. Or it is, but describes
a different thing.

Let's take a remote. Literal Polish translation would be "zdalny".
So let's make it a noun: "zdalność" (meaning "remoteness"),
"zdalniak"/"zdalnek"/"zdalka" (not actual words, but would mean "remotey"
and they sound infantile).

3. Inventing new words.
The basic word of Git is "commit". Again, this is both a noun and a verb.
I chose "zapis" for "a commit" (meaning "a record"/"a save")
and "złożyć" for "to commit" (meaning "put together" or "hand in").
I decided that "złożenie", which is "a putting together" or "a handing in",
misses the meaning and sounds worse.

I also found out about many secret features of Git, like
git diff --color-words, git pull --autostash
and all the interactive procedures.

Yeah so the best part of translating is the satisfaction
of it finally being done.
