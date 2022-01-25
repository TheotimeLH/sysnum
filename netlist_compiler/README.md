# Comment utiliser les simulateurs
---
Il y a deux simulateurs, `netlist_simulator` se contente d'exécuter la
netlist, tandis que `netlist_compiler` crée un nouveau prgm Ocaml (du
même nom, avec l'extension .ml) qui peut ensuite être executé.
---
## Pour utiliser le compilateur de netlists :
`make netlist_compiler` crée le compilateur. `./netlist_compiler file.net` crée le fichier `file.ml`, qui correspond à la netlist compilée en Ocaml. Ensuite vous pouvez compiler ce fichier Ocaml, typiquement avec ocamlopt, de manière à créer l'executable voulu.

En une seule commande : `make file.exe` crée le compilateur si besoin, puis le fichier `file.ml` et enfin l'executable `file.exe`.

## Pour executer :
Vous pouvez executer `file.exe` avec différentes options :
- `-n number_steps` nombres d'étapes (infini par défaut)
- `-s` pour désactiver l'affichage des sorties
- `-romdir dossier` Pour donner le dossier où chercher les ROM par défaut. Pour un identifiant `id` nécessitant une ROM, on commence par chercher par défaut si `dossier/id.txt` existe, si non on demande à l'utilisateur explicitement quel fichier prendre. Le dossier par défaut est `rom_test`.
- `-roms ...` Tous les mots suivants feront office de roms par défaut, dans l'ordre dans lequel elles seront demandées (il est préférable de ne l'utiliser que lorsqu'on est sûr de cet ordre).

## Pour utiliser le simulateur :
`make netlist_simulator` crée le simulateur de netlist, qui peut directement être executé, avec les mêmes options que précedemment, en lui précisant la netlist en plus. 
## Exemples :
- `make test/clock_rom.exe` puis `test/clock_rom.exe -n 1000000 -s`
- `make netlist_simulator` puis `./netlist_simulator -n 1000000 -s -rom rom_test2 test/clock_rom.net`
- `make microproc.exe` puis `./microproc.exe -s -roms rom_input.txt ../pomme/clock_quick.txt`

(On peut rajouter le mot clé `time` devant l'instruction pour les comparer.)

## Présision sur l'affichage 7 bâtons
Si dans les outputs de la netlist se trouve une variable nommée "maj_ecran". Le compilateur rajoute des instructions pour ouvrir une fenêtre avec Graphics et des appels à une fonction d'affichage quand voulu.
Cette fonction demande 7 arguments (secondes, minutes, heures, jours, mois et années x2) sous format 7 bâtons (cf. netlist_python/batonneur). Le programme mémorise les dernières valeurs données c'est-à-dire ce qui est affiché à l'écran. En comparant avec les nouvelles, on peut trouver l'argument qui a été modifié (toujours un unique) et mettre à jour uniquement les bâtons nécessaires.	Néanmoins, on donne à Graphics des coordonnées de pixels donc certaines machines ne peuvent pas afficher l'horloge en entier par manque de pixel.


