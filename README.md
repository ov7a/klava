# Klava

It's a pet project intended to write something useful (a tiny bag-of-words search engine) in an exotic language [Koka](https://koka-lang.github.io) for fun. And suffering.

You can see it in action in my [personal blog](https://ov7a.github.io/search). Yes, [typical developer side projects](https://ov7a.github.io/assets/images/blog-development.png).

Please do not use this in production :)

In code, you can find:
- bag-of-words search engine with [BM25 scoring](./src/core/search.kk)
- [Snowball stemmer](./src/core/stem.kk) for Russian language
- [data-extractor](./src/extractor/) from front-matter files (no markdown parsing)
- almost zero-JS [frontend](./src/frontend/)
- "purely-functional" self-written [json parser](./src/utils/json.kk)
- [string view](./src/utils/string-view.kk) with a weird set of methods
- [C code](./src/utils/unicode_ops.c) to implement unicode lowercase (sic!)
- dumb [package manager](./install_libs.sh)

Regarding the name — there's a song by Klava Koka (never head about her before, TBH, but my wife did) named intriguely "LA LA LA" and it [has](https://www.musixmatch.com/lyrics/%D0%9A%D0%BB%D0%B0%D0%B2%D0%B0-%D0%9A%D0%BE%D0%BA%D0%B0/%D0%9B%D0%90-%D0%9B%D0%90-%D0%9B%D0%90/translation/english) the following line:

> Чё те нужно?

Which can be translated as `What u need?`. I think it's a good fit :)
