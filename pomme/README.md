# pomme
---
`pomme` est un langage assembleur très simple à utiliser avec son micro-processeur, il pensé pour faire des horloges. 
`make` crée le compilateur, ensuite il suffit d'utiliser `./pomme file.pomme` pour compiler vers du binaire.
Voir `clock_real.pomme` et `clock_quick.pomme` pour des exemples.
 
---
## Outils :
Il y a 8 registres :
- Quatre à 8 bits non-signés: `r1` , `r2` , `r3` et `r4`
- Quatre à 16 bits signés: `rax` , `rbx` , `rcx` et `rck`
- Le micro-processeur possède une ROM d'entrée pour récupérer des valeurs extérieurs : `ROM_input.txt`
- Une RAM 16 bits est disponible, mais pas de pile. 

## Lexique :
- Le code est executé linéairement en commençant à la première ligne, les espaces et les tabulations n'ont pas d'importance en revanche on attend un saut à la ligne entre chaque instruction.
- On peut utiliser des labels pour faire référence à des lignes. Un label s'écrit en commençant par une majuscule, ensuite les caractères autorisés sont les lettres, les chiffres et les tirets. On attend un `:` juste après un label lors de sa définition.
- Dans la suite `<int>` indique qu'un entier est attendu, `<reg>` pour un registre et `<label>` pour un label.
- `$reg` fait référence à l'entier contenu dans le registre et est de type `<int>`.
- Une adresse `<addr>` de la RAM s'écrit entre parenthèses, on peut additionner un `<int>` avec un entier, par exemple `($r9 + 4)`. Attention la ROM comme la RAM sont écrites sur des lignes, chacune de 16 bits, ainsi la deuxième valeur est à l'adresse (1).
- Les commentaires sur une ligne s'indique avec `//`, tandis que `/*` et `*/` encadrent une zone commentée. Les commentaires imbriqués ne sont pas acceptés. 

## Les instructions :
Les instructions fonctionnent pour des valeurs 8 ou 16 bits, le micro-processeur transforme les valeurs ci-besoin, et infine c'est le lieu d'écriture qui importe.
- `move <reg> <reg>` met le deuxième registre à la même valeur que le premier.
- `set <int> <reg>` définit la valeur du registre. Préférez `move r1 r2` à `set $r1 r2`.
- `mult <int> <reg>` multiplie la valeur du registre par l'int.
- `add <int> <reg>` de même avec l'addition.
- `sub <int> <reg>` la soustraction.
- `neg <reg>` la négation.
- `not <reg>` le non logique.
- `and <int> <reg>` le et logique bit à bit.
- `or <int> <reg>` le ou.
- `xor <int> <reg>` le ou exclusif.
- `incrz <int> <reg>`, incrémente le registre et si la valeur devient égale au int, elle est mise à zero.
- `load <addr> <reg>` le registre prend la valeur stockée dans la RAM à l'adresse. 
- `save <reg> <addr>` opération inverse. 
- `load_rom <addr> <reg>` de même mais en prenant la valeur dans la `ROM_imput`.
- `jump <label>` Saut inconditionnel au label.
- `jump_nul <label>` Saut à condition que le drapeau laissé par l'opération précédente soit nul. 
- `jump_non_nul <label>` Idem mais dans le cas où le drapeau est non nul. 
- `move_real_clock <reg>` Charge la valeur de l'heure réelle (en secondes). 
- `sept_batons <reg> <addr>` transforme la valeur en format sept batons, avec 2 chiffres en batons donc au plus le nombre 99; puis la sauvegarde à l'adresse indiqué dans la RAM.  
