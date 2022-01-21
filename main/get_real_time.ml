open Unix
(* But : écrire l'heure et la date exacte au début du programme,
   pour donner le point de départ. Le microprocesseur a un rom_input
   sur 16 bits, et c'est celle ci qu'on définit / utilise. 
   À l'adresse 0 : les secondes ; 1 : les minutes ; 2 : les heures ;
   3 : jour ; 4 : mois ; 5 et 6 l'année. *)

(* On reprend la fonction du netlist_skeleton intv_to_strb :
   qui transforme un int en une chaine de caractères de sa
   décomposition en base 2. *)

let intv_to_strb n =
  let s = ref "" and k = ref n in
	for _ = 1 to 16 do
		s := string_of_int (!k mod 2) ^ !s ;
		k := !k lsr 1 done;
	!s

let () =
  let cfile = open_out "rom_input.txt" in
  let tm = Unix.localtime (Unix.time ()) in
  let aux n = output_string cfile ((intv_to_strb n) ^ "\n") in
  aux (tm.tm_sec mod 60) ;
  aux tm.tm_min ;
  aux tm.tm_hour ;
  aux (tm.tm_mday -1) ;
  aux tm.tm_mon ;
  let year = tm.tm_year + 1900 in
  aux (year / 100) ;
  aux (year mod 100) ;
  close_out cfile
