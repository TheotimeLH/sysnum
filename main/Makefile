all: mk_get_real_time mk_microproc

mk_get_real_time: clean_time get_real_time

get_real_time:
	ocamlopt -o get_real_time unix.cmxa get_real_time.ml 
	rm get_real_time.cmi get_real_time.cmx get_real_time.o
# Si on veut utiliser dune, il faut écrire ceci dans le dune :
# (executable
#	(name get_real_time)
#	(libraries unix) )

init_time: get_real_time
	./get_real_time

clean_time:
	rm -f get_real_time rom_input.txt 


SIMPLE = "0"
SILENCE = "1"

mk_microproc: clean_microproc microproc.exe

microproc.exe:
	cp -r ../netlist_python ../carotte.py/netlist_python
	cd ../carotte.py; \
		python3 carotte.py -o ../main/microproc.net netlist_python/microproc.py; \
		rm -r netlist_python/
ifeq ($(SIMPLE),"0")
	cd ../netlist_compiler; \
		make ../main/microproc.exe; \
		make clean
else 
	cd ../netlist_compiler; \
		make ../main/microproc.exe SIMPLEA="1";\
		make clean
endif

clean_microproc:
	rm -f microproc.exe microproc.ml microproc.net

clean: clean_microproc clean_time
	cd ../pomme; \
		make clean
	cd ../netlist_compiler; \
		make clean

pomme_real:
	cd ../pomme; \
		make clk_real  
clock_real: microproc.exe pomme_real init_time
  ifeq ($(SILENCE),"1")
		./microproc.exe -s -roms rom_input.txt ../pomme/clock_real.txt
  else
		./microproc.exe -roms rom_input.txt ../pomme/clock_real.txt
  endif

pomme_quick:
	cd ../pomme; \
		make clk_quick  
clock_quick: microproc.exe pomme_quick init_time
  ifeq ($(SILENCE),"1")
		./microproc.exe -s -roms rom_input.txt ../pomme/clock_quick.txt
  else
		./microproc.exe -roms rom_input.txt ../pomme/clock_quick.txt
  endif
	

.PHONY: mk_get_real_time mk_microproc pomme_real pomme_quick init_time

