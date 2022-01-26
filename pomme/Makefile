all: clean pomme

mk_pomme:
	rm -f pomme
	make pomme

tests: clk_real clk_quick

clk_real: pomme
	./pomme clock_real.pomme

clk_quick: pomme
	./pomme clock_quick.pomme

clk_ultra_quick: pomme
	./pomme exemples/clock_ultra_fast_forward.pomme

pomme:
	dune build main.exe
	cp _build/default/main.exe pomme

clean:
	dune clean
	rm -f pomme *.txt exemples/*.txt

.PHONY: mk_pomme clk_real clk_quick
