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

.PHONY: mk_get_real_time init_time

