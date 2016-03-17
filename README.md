spritz.lua
==========
An `Spritz` cipher implementation in pure [Lua 5.3](https://www.lua.org).

Spritz is a RC4 redesign by Ron Rivest and Jacob Schuldt
[(PDF)](https://people.csail.mit.edu/rivest/pubs/RS14.pdf).

Exports
-------
* `spritz.encrypt(m, k)`
* `spritz.decrypt(m, k)`
* `spritz.crypt(m, k)`
* `spritz.hash(m)`

License
-------
Release into the [Public Domain](LICENSE).
