# Microprocesseur


## Contenu du dossier

En plus de ce README, ce dossier contient le code carotte-compatible de notre microprocesseur.

Le microprocesseur est constitué des fichiers `microproc.py` (qui est le fihier principal), `batonneur.py`, `decodeur.py`, `registres.py`, et `alu.py`. Les trois derniers fichiers sont compilables par carotte sans fichier supplémentaires (dans l’optique de permettre de déboguer chaque composant à la main).

## Particularité du microprocesseur :

- Dans son mode de fonctionnement normal, le microprocesseur possède une entrée : `clock_real` et une sortie : `maj_ecran`. C’est au simulateur de netlist d’attraper ces entrées et sorties et de donner dans l’entrée la parité de la seconde de l’ordinateur qui simule le microprocesseur, et de déduire de la deuxième un indicateur que la ram d’affichage a été modifiée (pour mettre à jour l’écran)

- Le microprocesseur dispose d’un mode de débogage : en plançant à `True` la variable `DEBOGUE_MODE` initialisée en haut de `microproc.py`, la netlist construite le sera de telle sorte que le processeur s’éxécute pas à pas, et affiche à chaque étape différentes variables importantes de son exécution. (Remarque : Pour donner la seconde à `clock_real`, nous utilisons `Sys.time`, qui se met en pause lorsque le microprocesseur se met en pause entre chaque tour d’horloge, ainsi, il sera humainement difficile de voir une seconde s’écouler en mode débogue, on préférera tester sur le programme `clock_quick`). Pour simuler l’exécution pas à pas, une nouvelle entrée sera rajoutée, son utilité est simplement de mettre en pause le processeur, et sa valeur (sur un bit) n’a pas d’importance.

## Architecture :

Le microprocesseur s’éxécute techniquement sur 16 bits, et dispose de 8 registres en 16 bits, mais les lignes d’instructions sont encodées sur 32 bits (de telle sorte à pouvoir contenir un entier 16 bits).


Le microprocesseur est constitué des éléments suivants :

- Corps du microprocesseur (dans `microproc.py`)
- Lecteur de code (dans `microproc.py`)
- Décodeur de code (dans `decodeur.py`)
- Gestionnaire des registres (dans `registres.py`)
- Interface de l’alu (dans `microproc.py`)
- alu (dans `alu.py`)
- batonneur (dans `batonneur.py`)

Nous allons détailler le rôle de chacun de ces composants.

### Lecteur de code

- Entrées :
	- `jump_line` (la ligne à laquelle on pourrait devoir sauter)
	- `jump_flag` (indique si on doit sauter de ligne)
	- `curr_line` (la ligne à laquelle le processeur est)

- Sorties :	
	- `next_line` (la ligne à laquelle le processeur devra se rendre au prochain tour d’horloge)


Le lecteur de code réalise l’incrément de la ligne et gêre les sauts.


### Décodeur de code

- Entrées : 
	- `curr_code` (le code binaire sur 32 bits de la commande)

- Sorties :
	- `jump_line` ->                  indique la ligne de saut 
	- `jump_flag_inconditionnel` ->   vaut 1 si la commande est un saut incond.
	- `jump_flag_neg` ->              idem pour saut <0
	- `jump_flag_non_neg` ->          idem pour saut >=0
	- `jump_flag_non_nul` ->          idem pour saut !=0
	- `jump_flag_nul` ->              idem pour saut ==0
	- `operation_brute` ->            la partie de la commande qui concerne l'opération
	- `entier` ->                     l'entier stocké dans la commande
	- `read_addr1` ->                 1ere adresse de lecture des registres
	- `read_addr2` ->                 2eme
	- `write_addr_reg` ->             adresse d'ecriture des registres
	- `write_enable_reg` ->           indicateur sur 1 bit
	- `write_enable_ram` ->           indicateur sur 1 bit
	- `clock` ->                      indicateur sur 1 bit
	- `sauver_resultat_alu` ->        indicateur sur 1 bit
	- `batonnage` ->                  indicateur sur 1 bit
	- `lire_la_rom` ->                indicateur sur 1 bit
	- `operande_gauche` ->            vaut 1 si c’est r2, 0 si c’est r1
	- `operande_droit` ->             vaut 1 si c’est l’entier, et 0 si c’est r1


### Gestionnaire des registres




























