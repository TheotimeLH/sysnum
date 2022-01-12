netlist_compiler:
	dune build netlist_compiler.exe
	rm -f $@
	cp _build/default/netlist_compiler.exe $@

.PRECIOUS: %.ml

%.exe: %.ml
	ocamlopt $< -o $@ && rm ${patsubst %.exe, %.o,$@} ${patsubst %.exe, %.cmx,$@}${patsubst %.exe, %.cmi,$@}

%.ml: %.net netlist_compiler 
	./netlist_compiler $<

netlist_simulator:
	dune build netlist_simulator.exe
	rm -f $@
	cp _build/default/netlist_simulator.exe $@

clean:
	dune clean
	rm -f ./*.native ./*.byte ./netlist_compiler

