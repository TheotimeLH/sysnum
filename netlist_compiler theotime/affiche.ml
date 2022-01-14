
open Graphics

let print16 x n = (* A COMPLETER *) ()

let affiche_batons
  s (* secondes *)
  mi (* minutes *)
  h (* heures *) 
  j (* jours *)
  mo (* mois *)
  al (* millénaire + centenaire *) 
  ar (* décennie + année *) =

  open_graph " 2300x400" ;
  print16 100 s ;
  print16 400 mi ;
  print16 500 h ;
  print16 1000 j
  print16 1300 mo ;
  print16 1600 al ;
  print16 1900 ar ;
  close_graph ()
