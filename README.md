# Projet de Système numérique

Simulateur de netlist, microprocesseur et langage assembleur sur ce microprocesseur (avec son compilateur) avec exécution d’horloges en guise d’exemples.

## Faire fonctionner le microprocesseur sur les horloges de démonstration

Se rendre dans le dossier `main` et suivre les instructions du README s’y trouvant.


### Simulateur de netlist

Le simulateur utilisé est fondé sur celui de Théotime, qui compile les netlists aux formats `.ml`. Vous le trouverez, ainsi que son README, dans le dossier `netlist_compiler`.

### Microprocesseur

Le microprocesseur a été créé avec l’outil `Carotte.py`, vous le trouverez, ainsi que son README, dans le dossier `netlist_python`.

### Langage assembleur

Notre assembleur, qui répond au doux prénom de « pomme » a été inventé par nous-mêmes. Tous les détails le concernant (parser, lexer, et transcription en binaire) sont disponibles dans le README du dossier `pomme`.

### Horloges

Le code des horloges est écrit en `.pomme` dans le dossier `pomme`. En particulier, le code de `clock_real.pomme` y est généreusement commenté.

# Auteurs : Samuel Coulomb, Théotime Le Hellard, Vincent Peth
