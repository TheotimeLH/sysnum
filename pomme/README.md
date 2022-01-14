# pomme
---
`pomme` est un langage assembleur très simple à utiliser avec son micro-processeur, il pensé pour faire des horloges. 
`make` crée le compilateur, ensuite il suffit d'utiliser `./pomme file.pomme` pour compiler vers du binaire.
Voir `clock_real.pomme` et `clock_quick.pomme` pour des exemples.
 
---
## Outils :
- Il y a 8 registres : `r1` , `r2` , `r3` , `r4` , `rax` , `rbx` , `rcx` et `rck`
- Le micro-processeur possède une ROM d'entrée pour récupérer des valeurs extérieurs : `ROM_input.txt`
*- Et une `RAM_output` uniquement utilisé pour l'affichage sept segments*

## Lexique :
- Le code est executé linéairement en commençant à la première ligne, les espaces, les tabulations et les sauts de ligne n'ont pas d'importance.
- On peut utiliser des labels pour faire référence à des lignes. Un label s'écrit en commençant par une majuscule, ensuite les caractères autorisés sont les lettres, les chiffres et les tirets. On attend un `:` juste après un label lors de sa définition.
- Dans la suite `<int>` indique qu'un entier est attendu, `<reg>` pour un registre et `<label>` pour un label.
- `$reg` fait référence à l'entier contenu dans le registre et est de type `<int>`.
- Une adresse `<addr>` de la RAM s'écrit entre parenthèses, on peut additionner un `<int>` avec un entier, par exemple `($r9 + 4)`. Attention la ROM comme la RAM sont écrites sur des lignes, chacune de 16 bits, ainsi la deuxième valeur est à l'adresse (1).
- Les commentaires sur une ligne s'indique avec `//`, tandis que `/*` et `*/` encadrent une zone commentée. Les commentaires imbriqués ne sont pas acceptés. 

## Les instructions :
Les instructions fonctionnent pour des valeurs 8 ou 16 bits, le micro-processeur transforme les valeurs ci-besoin, et infine c'est le lieu d'écriture qui importe. Un entier brute est sur 16 bits signés.
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
- `jump_neg <label>` Idem si strictement inférieur à 0.
- `jump_non_neg <label>` Idem si supérieur ou égal à 0.
- `move_real_clock <reg>` Charge la valeur de l'heure réelle (en secondes). 
- `sept_batons <reg> <addr>` transforme la valeur en format sept batons, avec 2 chiffres en batons donc au plus le nombre 99; puis la sauvegarde à l'adresse indiqué dans la `RAM_output`.  

---
# Code binaire
Voici comme le code est compilé. Je rappelle que nos RAMS/ROMS s'écrivent lignes par lignes. Une instruction peut mentionner au plus qu'un entier primitif et deux registres. Aisni chaque ligne instruction est écrite sur 32 bits :
- les premiers 8 bits encodent l'instruction
- les 16 suivants l'entier signé 
- les 4 suivants le premier registre 
- les 4 derniers le deuxième registre 
Si une instruction n'utilise pas d'entiers, ou qu'un seul registre, les bits vacants seront inutilisés par le micro-processeur, ils sont laissés à zero.
Précision, c'est toujours le premier registre qui est utilisé pour calculer les adresses. Sinon, le résultat est mis dans le registre 2.

### Précision sur l'encodage des instructions: 
Comme pour les registres, puisqu'il n'y a que 21 instructions différentes,
5 bits suffiraient pour les décrire, mais on préfère une puissance de deux. 
De plus `Add 5 r1` et `Add $r2 r1` ne se traitent pas de la même manière !
Il faut préciser si le `<int>` est en fait un registre (si oui le premier)
ou un entier primitif, j'utilise le dernier bit pour ça : 1 ssi $reg.
De même quand avec les adresses, 1 ssi un $reg est utilisé.

Pour se rapprocher d'un micro-processeur réel, il faudrait mettre une grande
distance de haming entre les codes binaires des instructions, mais ici j'ai
préféré utiliser les trois premiers pour la catégorie de l'instruction 
(010 si c'est une opération, 011 si c'est en rapport avec RAM/ROM etc), les
quatre suivants pour préciser et enfin le dernier bit cf paragraphe précédent.

* Catégorie 001: Move et Set
	- `move` 001 0001 0
	- `set` 001 0010 0 si on utilise un entier primitif, exemple `set 5 r2` ou 001 0010 1 si on utilise un registre, exemple `set $r1 r2`
* Catégorie 010: les opérations
	- `add` 010 0001 0/1
	- `mult` 010 0010 0/1
	- `sub` 010 0011 0/1
	- `neg` 010 0100 0
	- `not` 010 0101 0
	- `and` 010 0110 0/1
	- `or` 010 0111 0/1
	- `xor` 010 1000 0/1
	- `incrz` 010 1001 0/1
* Catégorie 011: ROM/RAM
	- `load` 011 0001 1 si on utilise un registre par exemple `load ($r1 + 2) r2`, 011 0001 0 sinon
	- `save` 011 0010 0/1
	- `load_rom` 011 0011 0/1
* Catégorie 100: les sauts
	- `jump` 100 0001 0
	- `jump_nul` 100 0010 0
	- `jump_non_nul` 100 0011 0
	- `jump_neg` 100 0100 0
	- `jump_non_neg` 100 0101 0
* Catégorie 101: pour les horloges
	- `move_real_clock` 101 0001 0
	- `sept_batons` 101 0010 0/1

Les registres sont codés ainsi : `r1` : 1000 , `r2` : 1001 , `r3` : 1010 , `r4` : 1011 , `rax` : 1100 , `rbx` : 1101 , `rcx` : 1110 et `rck` : 1111.

