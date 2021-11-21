
all:
	ocamlbuild netlist_compiler.byte
	./netlist_compiler.byte test/clock_div.net
	ocamlbuild test/clock_div.native  
