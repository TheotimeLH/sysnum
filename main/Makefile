all: mk_get_real_time

mk_get_real_time: 
	rm -f get_real_time
	make get_real_time

get_real_time:
	ocamlopt -c get_real_time.ml
	ocamlopt unix.cmxa get_real_time.cmx -o get_real_time
	rm get_real_time.cmi get_real_time.cmx get_real_time.o
# Si on veut utiliser dune, il faut écrire ceci dans le dune :
# (executable
#	(name get_real_time)
#	(libraries unix) )

init_time: get_real_time
	./get_real_time

microproc.exe:
	cp -r ../netlist_python ../carotte.py/netlist_python
	cd ../carotte.py; \
		python3 carotte.py -o ../main/microproc.net netlist_python/microproc.py; \
		rm -r netlist_python/
	cd ../netlist_compiler\ theotime; \
		make ../main/microproc.exe; \
		make clean


clean:
	rm -f get_real_time rom_input.txt

.PHONY: mk_get_real_time init_time

