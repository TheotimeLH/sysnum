all: clean mk_pomme

mk_pomme:
	rm -f pomme
	make pomme

tests: clk_real clk_quick

clk_real: pomme
	./pomme clock_real.pomme

clk_quick: pomme
	./pomme clock_quick.pomme

pomme:
	dune build main.exe
	cp _build/default/main.exe pomme

clean:
	dune clean
	rm -f pomme

.PHONY: mk_pomme clk_real clk_quick
