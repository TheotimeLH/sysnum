## Prérequis :
- Nous utilisons `carotte.py`, ainsi pour le télécharger (au bon endroit), il faut faire : `git submodule init` puis `git submodule update`.
- De même pour utiliser `carotte.py`, il est parfois préférable de télécharger le module assignhooks avec `pip install assignhooks`.
- Pour les horloges nous utilisons le module Graphics de Ocaml, si vous l'avez déjà avec Ocaml, tout sera simple (pour vérifier vous pouvez ouvrir Ocaml en toplevel et essayer `open Graphics`). En revanche si vous ne l'avez pas par défaut, il faut faire `opam depext -i graphics`.

## Utilisation :
- `make mk_microproc` crée l'exécutable `microproc.exe` (en passant par `microproc.net` et `microproc.ml`).
- `make mk_get_real_time` compile le petit code pour récupérer l'heure de début du processus.
- `make` fait les deux précédentes.
- `make clock_real` et `make clock_quick` lancent le microprocesseur (en le créant si besoin) sur les horloges exemples. Si vous voulez activer l'affichage des étapes dans le terminal, précisez SILENCE=1, par exemple `make clock_real SILENCE=1`.
- Tout ce qui précède va marcher à condition que Graphics soit installé d'office. Sinon, vous devez précisez SIMPLE=1, par exemple `make SIMPLE=1` ou `make clock_quick SILENCE=1 SIMPLE=1`.
