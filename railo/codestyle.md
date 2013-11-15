Style
=====
* No getters except for properties with accessors. Hardcoded getter functions have the name of the property, for instance: `parent()` instead of `getParent()`.
* Private members have names that start with _. This avoids name clashes with getters.
* Private members are treated private to the component that defines them. If a subclass needs access, a private getter is provided.
* For all functions containing 3 or more lines, the function starts with an empty line. The last line is a return statement, or an empty line if the returntype is void.

Railo specifics usage
=====================

Syntax
------
* No semicolons except where the parser needs them (basically, only after script tags such as property or abort).
* JSON style creation of structs (: instead of =).

Features
--------
* Member functions wherever possible except for scopes.
* Break out of current and parent loops using break [loop name].

Administrator settings
----------------------
* Full null support.
* Case sensitive structs.
* Merge url and form.
* Modern local scope mode.
* Strict cascading.
* Modern application listener.