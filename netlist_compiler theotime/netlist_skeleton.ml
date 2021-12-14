#
(* Squelette des netlists compilées *)
(* $ : balise ; #...# commentaire non recopié *)
#
(* ========== Paramètres ========== *)

let number_steps = ref max_int
let print_sorties = ref true
let dossier_rom = ref "rom_test"

(* ========== Fonctions auxiliaires ========== *)

(* ==== Pour passer des strb aux int ==== *)

(* strb : chaine de caractères où est écrit un int en binaire, exemple : "0010"
  En lecture, si on attend n bits et qu'on en reçoit moins ou plus, on
	crie, si c'est un input on le redemande, si c'est dans la ROM le cri
	provoque une erreur.
  Rem : tout chiffre > 0 est pris pour un 1, exemple : "0502" -> "0101" 

	intv : nos values, de la forme (len,int) où les informations sont dans
	les len premiers bits de l'int.																					*)
exception Wrong_length

let strb_to_intv s k = (* k : le nb de bits voulus *)
	if String.length s <> k then raise Wrong_length
	else begin let n = ref 0 in
		for i = 0 to k-1 do
			n := (!n lsl 1) + (if int_of_char s.[i] > 48 then 1 else 0) done ;
		(k,!n) end

let intv_to_strb (len,n) =
	let s = ref "" and k = ref n in
	for _ = 1 to len do
		s := string_of_int (!k mod 2) ^ !s ;
		k := !k lsr 1 done;
	!s

(* ==== Strutures ==== *)

let step = ref 0 
$
let t_val = Array.init nb_vars (fun i -> (t_len.(i),0))
let t_fait = Array.make nb_vars 0 
let t_reg = Array.init nb_vars (fun i -> (t_len.(i),0))
$
let t_roms = Array.make nb_vars [||]
let t_rams = Array.init nb_vars 
	(fun i -> let a_s,w_s = info_rams.(i) in
	Array.make (1 lsl a_s) (w_s,0))

# (*
	Chaque variable est désormais identifié par un num
	t_nom : Array num -> le nom de sa variable
	t_len : Array num -> son nombre de bits, sa len
	
	t_val : Array num -> intv : (len * int), les len bits de poids faible de int 
	t_fait : Array num -> la dernière step où t_val.(num) fut calculée
		Attention : les portes REG conservent les anciennes valeurs d'autres
		variables. Leur comportement est singulier, on calcul toujours leurs
		nouvelles valeurs, mais seulement à la fin, on n'utilise pas t_fait.
	t_reg : Array num -> pour a = REG b, t_reg.(a) = l'ancienne de b
	t_roms : Array num -> sa rom (vide si la porte n'est pas une ROM)
	t_rams : idem
	
	l_roms : (num,a_size,w_size) List des portes ROM		*)
#

(* ==== Entrées : input / ROM  ==== *)

let rec ask_input num = 
	Printf.printf "%s = " t_nom.(num) ;
	try (t_len.(num),strb_to_intv (read_line ()) t_len.(num))
	with Wrong_length -> 
		Printf.printf "ERREUR : on demande %d bits" t_len.(num) ;
		ask_input num 

let recup_rom (num,a_size,w_size) = 
	let m = 1 lsl a_size in
	let lit_rom file = 
		let rom = Array.make m (w_size,0) in
		let k = ref 0 in
		let end_of_file = ref false in
    while !k < m && not !end_of_file do
      incr k ;
      try
        begin
					try rom.(!k-1) <- strb_to_intv (input_line file) w_size
					with Wrong_length ->
						Printf.printf "ERREUR : pour la ROM de %s on \
							voulait %d bits, on a mis des 0 par défaut" t_nom.(num) w_size ;
				end
      with
        |End_of_file -> end_of_file := true ;
          print_endline "Attention, il manque des données, 0 par défaut"
        |Failure _ ->
          print_endline "Attention, il a des caractères dans le fichier"
      done;
    t_roms.(num) <- rom in

  try
    lit_rom (open_in (!dossier_rom ^ "/" ^ t_nom.(num) ^ ".txt"))
  with
    Sys_error _ -> begin
      Printf.printf "Quelle est la ROM pour %s ? (on demande un .txt) \n\ 
				NB: Avec l'argument -rom vous pouvez indiquer un dossier \
				où chercher par défaut, actuellement %s) \n" t_nom.(num) !dossier_rom ;
      try lit_rom (open_in (read_line ()))
      with
        Sys_error _ ->
          print_endline "Fichier non trouvé, ROM initialisée avec des 0" ;
          t_roms.(num) <- Array.make m (w_size,0)
			end


(* ======== Les fonctions-variables ======== *)

$
# (* Du style :
let var_<nom> () =
	if t_fait.(<num>) = !step then t_val.(<num>)
	else begin
		val = <la porte>
		t_val.(<num>) <- val ;
		t_fait.(<num>) <- !step ;
		val
	end

Attention, pour les portes : a = REG b 
let var_a () = t_val.(<num de a>)
Car t_val d'un REG est tjr mis à jour à la fin du tour	*)
#

(* ========================================= *)

let simulator () =
	List.iter recup_rom l_roms ;
	while !step < !number_steps do
		incr step ;
		if !print_sorties then Printf.printf "Step %d : \n" !step ;
		(* === Calcul et affichage des sorties === *)
$
# (* De la forme
Printf.printf "=> <nom> = %s \n" (intv_to_strb (var_<nom> ()) ; *)
#

		(* === Mise à jour des REG et des RAM === *)
$ 
# (* De la forme :
t_reg.(<num a>) <- var_<b> ()) ;
. . . - pour tous les a = REG b
ET
if var_<w_enable> ()
then t_roms.(<num de a>).(var_<w_addr> () ) <- var_<w_data> () ;
. . . pour tous les a = RAM ...
PUIS
t_val.(<num a>) <- t_reg(<num a>)
. . . - pour tous les a = REG b		*)
#
		done

let () = Arg.parse 
	["-n", Arg.Set_int number_steps, "Number of steps to simulate";
	 "-s", Arg.Clear print_sorties, "Disable print outputs";
	 "-rom", Arg.Set_string dossier_rom, "Roms' directory"] 
	(fun _ -> ()) ""

let () = simulator () 