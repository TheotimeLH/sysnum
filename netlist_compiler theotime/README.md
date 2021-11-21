# Comment utiliser les simulateurs
---
Il y a deux simulateurs, `netlist_simulator` se concente d'exécuter la
netlist, tandis que `netlist_compiler` crée un nouveau prgm Ocaml (du
même nom, avec l'extension .ml) qui peut ensuite être exécuté.
---
## En exécutant directement :
### Pour compiler le simulateur
`ocamlbuild netlist_simulator.byte`

### Arguments possibles
- `-n number_steps` nombres d'étapes (infini par défaut)
- `-s` pour désactiver l'affichage des sorties
- `-rom dossier` Pour donner le dossier où chercher les ROM par défaut. Pour un identifiant `id` nécessitant une ROM, on commence par chercher par défaut si `dossier/id.txt` existe, si non on demande à l'utilisateur explicitement quel fichier prendre. Le dossier par défaut est `rom_test`.

### Les entrées
Les entrées sont à fournir écrit en gros-tête, des bits en tête en trop seront ignorés, si il en manque on considère les bits de poids forts à 0 par défaut (de même dans la lecture des ROMs).
### Pour tester
- `time ./netlist_simulator.byte -n 1000000 -s test/clock_div.net`
- `./netlist_simulator.byte -n 28 -rom rom_test test/clock_rom.net` (à noter que -rom rom_test est inutile ici)

---
## Pour utiliser le compilateur :
Commencer par compiler le compilateur de netlists, avec `ocamlbuild netlist_compiler.byte`. Puis vous pouvez l'appliquer à une netlist avec `./netlist_compiler.byte ma_netlist.net` pour créer le prgm OCaml adapté. Ensuite il ne reste plus qu'à compiler ce prgm avec `ocamlbuild ma_netlist.native`, et enfin on peut l'executer avec les mêmes arguments que précédemment, par exemple `./ma_netlist.native -s -n 18`. Un Makefile fait ces opérations.
