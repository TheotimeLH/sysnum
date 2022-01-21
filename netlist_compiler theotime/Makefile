all: clean netlist_compiler netlist_simulator

netlist_compiler:
	dune build netlist_compiler.exe
	rm -f $@
	cp _build/default/netlist_compiler.exe $@

.PRECIOUS: %.ml

# Pour la compilation avec Graphics, j'ai deux méthodes différentes
# Si Graphics est un module connu par défaut c'est facile
# Sinon il faut le chercher avec ocamlfind

SIMPLEA = "0"

%.exe: %.ml
  ifeq ($(SIMPLEA),"0")
		ocamlopt -o affiche graphics.cmxa affiche.ml
		ocamlopt -o $@ graphics.cmxa affiche.cmx $<
  else
		ocamlfind ocamlopt -g -o affiche -linkpkg -package graphics graphics.cmxa affiche.ml
		ocamlfind ocamlopt -g -c -linkpkg -package graphics graphics.cmxa $<
		ocamlfind ocamlopt -g -o $@ -linkpkg -package graphics graphics.cmxa affiche.cmx ${patsubst %.exe, %.cmx,$@}
  endif
	rm affiche affiche.cmi affiche.cmx affiche.o
	rm ${patsubst %.exe, %.o,$@} ${patsubst %.exe, %.cmx,$@}${patsubst %.exe, %.cmi,$@}

%.ml: %.net netlist_compiler 
	./netlist_compiler $<
		
netlist_simulator:
	dune build netlist_simulator.exe
	rm -f $@
	cp _build/default/netlist_simulator.exe $@

clean:
	dune clean
	rm -f ./*.native ./*.byte ./netlist_compiler ./netlist_simulator

.PHONY: %.exe
