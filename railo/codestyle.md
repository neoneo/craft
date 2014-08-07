Style
=====
* No getters except for properties with accessors. Hardcoded getter functions have the name of the property, for instance: `parent()` instead of `getParent()`.
* Private members are treated private to the component that defines them. If a subclass needs access, a private getter is provided.
* For all functions containing 3 or more lines, the function starts with an empty line. The last line is a return statement, or an empty line if the returntype is void.

Naming
======
* Components Pascal cased.
* Methods camel cased.
* Builtin functions Pascal cased.
* Private members have names that start with _. This avoids name clashes with getters.

Railo specifics usage
=====================

Syntax
------
* No semicolons except where the parser needs them (basically, only after script tags such as `property` or `abort`).
* JSON style creation of structs (: instead of =).

Features
--------
* Member functions wherever possible.
* Break out of current and parent loops using `break [loop name]`.
* `===` operator to compare objects for equality (including null). For other comparisons this operator could be used too, but its meaning is less clear.
	For strings, the comparison is case sensitive, but this is not clear from the syntax (or the difference could be missed). Numeric comparisons may fail if the instances are not of the same type. Functions like Len return an integer, while all numerics are doubles. Therefore, `Len("a") === 1` fails.

Administrator settings
----------------------
* Case sensitive structs.
* Merge url and form.
* Strict cascading.
* Modern application listener.
* Null support

* Local scope mode: not supported. When this is enabled, closures can't see the outside scope.