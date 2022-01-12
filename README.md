# Projet de Système numérique

Simulateur de netlist, microprocesseur et langage assembleur sur ce microprocesseur

## Utilisation du compilateur : 
En théorie, se placer dans le fichier et utiliser `make fichier.byte` si on dispose de `fichier.net` suffit à compiler.

Si ça ne marche pas, il faut à la main compiler le compilateur, puis lancer `.\compilateur_netlist.byte fichier` pour compiler le fichier `fichier.net` (pas besoin de recopier le .net, cela provoquerait une erreur)

Ensuite, `fichier.byte` exécute la netliste, et prend comme option `-muet` pour ne rien afficher et `-n 10` pour ne réaliser que les 10 premières itérations (on peut évidemment changer le nombre en argument).

