This is the INSTALL file for the osm_xml distribution.

This package uses dune to generate its build system.

Dependencies
============

In order to compile this package, you will need:

* ocaml for all
* findlib
* core for library osm_xml
* xmlm for library osm_xml
* ounit2 for executable test

Installing
==========

If you are using [OPAM](http://opam.ocaml.org/):

1. Run `opam install osm_xml`

In other case:

1. Uncompress the source archive and go to the root of the package
2. Run 'dune install'

Uninstalling
============

1. Go to the root of the package
2. Run 'dune uninstall'
