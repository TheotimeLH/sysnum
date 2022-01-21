all: clean netlist_compiler netlist_simulator

netlist_compiler:
	dune build netlist_compiler.exe
	rm -f $@
	cp _build/default/netlist_compiler.exe $@

.PRECIOUS: %.ml affiche

affiche:
	ocamlfind ocamlopt -g -o affiche -linkpkg -package graphics graphics.cmxa affiche.ml


%.exe: %.ml affiche
	ocamlfind ocamlopt -g -c -linkpkg -package graphics graphics.cmxa $<
	ocamlfind ocamlopt -g -o $@ -linkpkg -package graphics graphics.cmxa affiche.cmx ${patsubst %.exe, %.cmx,$@}
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

