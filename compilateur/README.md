#Compilateur de netlist

Principe : le compilateur de netlist transforme un fichier `.net` en fichier `.ml`.

Compilation : Pour compiler le compilateur, la commande 
`ocamlbuild compilateur_netlist.byte` exécutée dans le répertoire où est situé `compilateur_netlist.ml` devrait fonctionner.

Éxecution : Pour compiler un fichier `exemple.net`, on utilise la commande
`.\compilateur_netlist.byte exemple`. 
Le suffixe `.net` est automatiquement rajouté par le compilateur, il ne faut pas l’indiquer.

Éxécution de la netlist : il faut compiler le fichier produit au format executable voulu puis l’exécuter.

Options sur l’execution de la netlist :
`-n <int>` : n’exécuter que les `<int>` premiers tours d’horloge
`-muet` : ne pas afficher les sorties

Représentation des bus :
bus comme valeurs simples sont représentés par des entiers (vus comme des suites de bits).


Gestion des portes :
Le calcul de la valeur de chaque porte se fait s’il est nécessaire, quand il est nécessaire, donc toutes les entrées ne sont pas demandées à chaque tour d’horloge, et l’ordre peut varier.

Gestion des rom :
lors de l’exécution du compilateur sur le fichier `exemple`, pour chaque variable `var` qui est une lecture de la rom, le compilateur créée (ou écrase) un fichier `fichier_rom_var.txt` qui contient une suite de nombres correspondant aux données de la rom (un nombre par bus et par ligne). On peut modifier les fichiers `.txt` produits pour modifier la rom.


