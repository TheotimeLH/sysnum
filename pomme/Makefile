all: clean pomme

tests: clk_real clk_quick

clk_real:
	./pomme clock_real.pomme

clk_quick:
	./pomme clock_quick.pomme

pomme:
	dune build main.exe
	cp _build/default/main.exe pomme

clean:
	dune clean
	rm -f pomme

.PHONY: all clean pomme
