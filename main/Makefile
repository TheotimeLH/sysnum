all: mk_get_real_time mk_microproc

mk_get_real_time: 
	rm -f get_real_time
	make get_real_time

get_real_time:
	ocamlopt -o get_real_time unix.cmxa get_real_time.ml 
	rm get_real_time.cmi get_real_time.cmx get_real_time.o
# Si on veut utiliser dune, il faut écrire ceci dans le dune :
# (executable
#	(name get_real_time)
#	(libraries unix) )

init_time: get_real_time
	./get_real_time


SIMPLE = "0"

mk_microproc:
	rm -f microproc.exe
	make microproc.exe

microproc.exe:
	cp -r ../netlist_python ../carotte.py/netlist_python
	cd ../carotte.py; \
		python3 carotte.py -o ../main/microproc.net netlist_python/microproc.py; \
		rm -r netlist_python/
ifeq ($(SIMPLE),"0")
	cd ../netlist_compiler\ theotime; \
		make ../main/microproc.exe; \
		make clean
else 
	cd ../netlist_compiler\ theotime; \
		make ../main/microproc.exe SIMPLEA="1"\
		make clean
endif


clean:
	rm -f get_real_time rom_input.txt

.PHONY: mk_get_real_time mk_microproc init_time

