compilateur :
	ocamlbuild compilateur/compilateur_netlist.byte

%.byte : compilateur 
	./compilateur_netlist.byte $*
	ocamlbuild $*_simu.byte

%.net :
	python3 carotte.py -o $*.net $*.py
