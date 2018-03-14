OCAMLBUILD ?= ocamlbuild

all: pretty_of_error
clean:
	$(OCAMLBUILD) -clean
	test ! -e pretty_of_error || rm pretty_of_error

pretty_of_error: pretty_of_error.native
	cp -L $< $@

pretty_of_error.native: pretty_of_error.ml message.ml
	$(OCAMLBUILD) -use-ocamlfind $@
