open Affiche
open Netlist_ast

(* Pour des commentaires voir netlist_skeleton, 
   je suis à me demander si c'était bien utile de toujours
   transporter l'info de la longueur des bus. *)

let net_to_ml filename =
	String.sub filename 0 ((String.length filename) - 4) ^ ".ml"

let recopie ic oc =
	let b = ref true in
	let commentaire = ref false in
	while !b do
		let line = (input_line ic) ^ "\n" in
		if line.[0] = '#' then commentaire := not (!commentaire) 
		else if not (!commentaire) then 
		if line.[0] = '$' then b := false
		else output_string oc line done ; 
	()


let compiler filename p =
	let skel = open_in "netlist_skeleton.ml_modif" in
	let cfile = open_out (net_to_ml filename) in
	(* === Introduction === *)
	recopie skel cfile ;

	(* === Structures 1 === *)
	let nb_vars = (List.length p.p_eqs) + (List.length p.p_inputs) in
	let t_nom = Array.make nb_vars "" in
	let t_len = Array.make nb_vars 0 in
	let num = ref (-1) in
	let e_num = Env.mapi (fun id ty ->
		incr num ;
		let len = match ty with |TBit -> 1 |TBitArray n -> n in
		t_nom.(!num) <- "\"" ^ id ^ "\"" ;
		t_len.(!num) <- len ;
		!num	) p.p_vars in
	let num id = Env.find id e_num in
	let snum id = string_of_int (num id) in
  let len id = t_len.(num id) in
  let slen id = string_of_int (len id) in
	let str_nb_vars = "let nb_vars = " ^ (string_of_int nb_vars) ^ "\n" in
	let str_t_nom = "let t_nom = [|" ^ (String.concat ";" (Array.to_list t_nom)) ^ "|]\n" in
	output_string cfile (str_nb_vars ^ str_t_nom) ;	
  let doit_affiche_batons = ref false in
  let doit_stop = ref false in
  let output_condition = ref "" in
  let outputs' = List.filter (function
    | "maj_ecran" -> doit_affiche_batons := true ; false
    | "stop_prgm" -> doit_stop := true ; false
    | _ -> true) 
    p.p_outputs in
	recopie skel cfile ;

	(* === Structures 2 (ROM et RAM) === *)
	let list_roms = ref [] in 
	let as_rams = Array.make nb_vars 0 in
	let l_regs = ref [] in
	let l_rams = ref [] in
  let pour_init = function
    |(a,Ereg b) -> l_regs := (a,b) :: !l_regs
    |(x,Erom(a_size,w_size,_)) ->
      let xlen = t_len.(num x) in
      if xlen <> w_size then (
        Printf.eprintf "Problème avec la porte ROM %s : \n\
          %d bits attendus, mais ROM de w_size %d" x xlen w_size ;
        exit 1 ) ;
      list_roms := (x,a_size,w_size) :: !list_roms
    |(x,Eram(a_size,w_size,_,we,wa,data)) ->
      let xlen = t_len.(num x) in
      if xlen <> w_size then (
        Printf.eprintf "Problème avec la porte RAM %s : \n\
          %d bits attendus, mais ROM de w_size %d" x xlen w_size ;
        exit 1 ) ;
			as_rams.(num x) <- a_size ;
      l_rams := (x,we,wa,data) :: !l_rams
    |_ -> () in
  List.iter pour_init p.p_eqs ;
	
	let str_as_rams = "let as_rams = [|" ^ (String.concat ";"
		(List.map string_of_int	(Array.to_list as_rams))) ^ "|]\n" in
	let str_l_roms = "let l_roms = [" ^ (String.concat ";"
		(List.map (fun (x,a_s,w_s) -> string_of_int (num x) ^ "," ^
			string_of_int a_s ^ "," ^ string_of_int w_s) !list_roms)) ^ "]\n" in

	output_string cfile (str_as_rams ^ str_l_roms) ;
	recopie skel cfile ;
 
	(* === Les fonctions-variables === *)
	let debut id = 
		"let var_" ^ id ^ " () = \n\
		\tif t_fait.(" ^ (snum id) ^ ") = !step then t_val.(" ^ (snum id) ^ ") \n\
		\telse begin \n" in
	let fin id = 
		"\t\tt_val.(" ^ (snum id) ^ ") <- valeur ;\n\
		 \t\tt_fait.(" ^ (snum id) ^ ") <- !step ;\n\
		 \t\tvaleur\n\tend\n\n" in
	let sarg = function
		|	Avar id -> (len id , "(var_" ^ id ^ " () )")
		|	Aconst v -> begin match v with 
      |VBit b -> 1 , if b then "1" else "0"
      |VBitArray t -> 
        let n = Array.length t in
        let k = ref 0 in
        for i = 0 to n-1 do
          k := (!k lsl 1) + (if t.(i) then 1 else 0)
          done ;
        (n , string_of_int !k)
      end
		in 

  let pb_len id len len' =
    Printf.eprintf "Problème avec la porte %s, %d bits attendus, %d donnés" id len len' ;
    exit 1 in
  let pb_binop id len l1 l2 =
    Printf.eprintf "Problème avec la porte %s, %d bits demandés, %d et %d donnés" id len l1 l2 ;
    exit 1 in

  let uns len = string_of_int (1 lsl len - 1) in

	let mk_fct_var_input id = 
    (debut id) ^
    begin match id with
    | "real_clock" -> "\t\tlet valeur = int_of_float (Sys.time ()) mod 2 in \n"
    | _ -> "\t\tlet valeur = ask_input " ^ (snum id) ^ " " ^ (slen id)^ " in\n" 
    end
    ^ (fin id) in

	let mk_fct_var_porte (id,exp) = match exp with
		|	Ereg r -> "let var_" ^ id ^ " () = t_val.(" ^ (snum id) ^ ")\n\n"
		|	_ -> (* on traite juste les REG à part *) 
		(debut id) ^
		begin match exp with
			|	Earg a -> 
          let la,sa = sarg a in
          let len = len id in
          if la <> len then pb_len id len la ;
          "\t\tlet valeur = " ^sa^ " in\n"
      |	Enot a -> 
          let la,sa = sarg a in
          let len = len id in
          if la <> len then pb_len id len la ;
          "\t\tlet valeur = (lnot "^sa^") land "^(uns la)^" in \n"

			|	Ebinop (Xor,a1,a2) ->
          let l1,sa1 = sarg a1 in
          let l2,sa2 = sarg a2 in
          let len = len id in
          if len <> l1 || len <> l2 then pb_binop id len l1 l2 ;
					"\t\tlet valeur = "^sa1^" lxor "^sa2^" in\n"

			|	Ebinop (op,a1,a2) ->
          (* Je veux des opérations paresseuses y compris sur les opérations n bits,
             si a1 vaut 1111 alors a1 | _ = 1111. Ainsi on peut parfois se passer de calculer a2. *)
          let l1,sa1 = sarg a1 in
          let l2,sa2 = sarg a2 in
          let len = len id in
          if len <> l1 || len <> l2 then pb_binop id len l1 l2 ;
          
					"\t\tlet n1 = " ^sa1^ " in\n\
					\t\tlet valeur = " ^
					begin match op with
						|	Or -> "if n1 = "^(uns l1)^" then n1"
						|	And -> "if n1 = 0 then 0"
						|	_ (*Nand*) -> "if n1 = 0 then "^(uns l1) end ^
					" else " ^
          begin match op with
            | Or -> "n1 lor "^sa2
            | And -> "n1 land "^sa2
            | _ (*Nand*) -> " (lnot (n1 land "^sa2^")) land "^(uns l1) end ^" in \n"

			|	Emux (choice,a1,a2) ->
          if id = "output_prgm" then (match choice with
            | Avar idc -> output_condition := idc
            | _ -> failwith "wtf choice de l'output") ;
          let l1,sa1 = sarg a1 in
          let l2,sa2 = sarg a2 in
          let len = len id in
          if len <> l1 || len <> l2 then pb_binop id len l1 l2 ;
          let sc = snd (sarg choice) in
					"\t\tlet valeur = if "^sc^" > 0 then "^sa2^" else "^sa1^" in\n"

			|	Erom (_,_,a) -> 
					"\t\tlet valeur = t_roms.("^(snum id)^").("^(snd (sarg a))^") in\n"

			|	Eram (_,_,a,_,_,_) ->
					"\t\tlet valeur = t_rams.("^(snum id)^").("^(snd (sarg a))^") in\n"

			| Econcat (a1,a2) ->
          let l1,sa1 = sarg a1 in
          let l2,sa2 = sarg a2 in let sl2 = string_of_int l2 in
          let len = len id in
          if len <> l1 + l2 then pb_len id len (l1+l2) ;
					"\t\tlet valeur = ("^sa1^" lsl "^sl2^") + "^sa2^" in\n"

			|	Eselect (i,a) -> 
          let la,sa = sarg a in
          let len = len id in
          if len <>1 then pb_len id len 1 ;
          if i+1>la then (
            Printf.eprintf "Problème avec le Select %s, %d +1> %d" id i la ;
            exit 1) ;
					"\t\tlet valeur = ("^sa^" lsr "^(string_of_int (la-i-1))^") mod 2 in\n"

			|	Eslice (i1,i2,a) -> 
          let la,sa = sarg a in
          let len = len id in
          if len <> i2-i1+1 then pb_len id len (i2-i1+1) ;
          if i2+1>la || i2<i1 then (
            Printf.eprintf "Problème avec le Slice %s où i1=%d et i2=%d, sur %d" id i1 i2 la;
            exit 1) ;
          let _uns = string_of_int (1 lsl (i2-i1+1)) in
					"\t\tlet valeur = ("^sa^" lsr "^(string_of_int (la-i2-1))^") mod "^_uns^" in\n"
			|	Ereg _ -> failwith "deja fait"
		end
		^ (fin id) in
	
	output_string cfile (String.concat "(*=======*)\n\n" 
		(List.map mk_fct_var_input p.p_inputs)) ;
	output_string cfile "(*=============*)\n\n" ;
	output_string cfile (String.concat "(*=======*)\n\n" 
		(List.map mk_fct_var_porte p.p_eqs)) ;
	recopie skel cfile ;

	(* === Les sorties === *)
  if !doit_affiche_batons then output_string cfile 
    "\t\tlet ecran_open = ref false in \n" ;
  recopie skel cfile ;
    
	let mk_sortie = function
  | "output_prgm" -> 
    "\t\tif var_"^ !output_condition^" () <> 0 then Printf.printf \"=> %s \\n\" \
    (intv_to_strb (var_output_prgm ()) "^(slen "output_prgm")^") ;"
  | id ->
		"\t\tlet sortie = intv_to_strb (var_"^ id ^" ()) "^(slen id)^" in\n\
		\t\tif !print_sorties then Printf.printf \"=> "^ id ^" = %s \\n\" sortie ;" in
	output_string cfile (String.concat "\n" (List.map mk_sortie outputs')) ;
	recopie skel cfile ;

	(* === Les REG / RAM === *)
	let mk_reg (a,b) =
    let la = t_len.(num a) in 
    let lb = t_len.(num b) in 
    if la <> lb then pb_len a la lb ; 
		"\t\tt_reg.("^ (snum a) ^") <- var_"^ b ^" () ;\n" in
	output_string cfile (String.concat "" (List.map mk_reg !l_regs)) ;

  let num_ram_ecran = ref 0 in
	let mk_ram (id,w_e,w_a,w_d) =
    let lwa,swa = sarg w_a in
    let lwd,swd = sarg w_d in
    let len = len id in
    if len <> lwd then (
      Printf.eprintf "Problème avec la RAM associée à %s, \n\
        la taille de la w_data %d ne convient pas (%d attendu)" id lwd len ;
      exit 1) ;
    let asize = as_rams.(num id) in
    if lwa <> asize then (
      Printf.eprintf "Problème avec la RAM associée à %s, \n\
        adresse demandée sur %d bits, mais RAM avec adresses %d bits" id lwa asize ;
      exit 1) ;
    if w_e = Avar "maj_ecran" then num_ram_ecran := num id ;
		"\t\tif "^(snd (sarg w_e))^" > 0 then t_rams.("^ (snum id) ^").("
		^swa^") <- "^swd^ " ;\n" in
	output_string cfile (String.concat "" (List.map mk_ram !l_rams)) ;

	let mk_reg2 (a,_) =
		"\t\tt_val.("^ (snum a) ^") <- t_reg.("^ (snum a) ^") ;\n" in
	output_string cfile (String.concat "" (List.map mk_reg2 !l_regs)) ; 

  (* === La sortie spéciale Sept_batons === *)
  if !doit_affiche_batons then output_string cfile
    ("\n\t\t (* Cas spécial, où on a demandé à utiliser des sept_batons : *) \n\
    \t\tif var_maj_ecran () = 1 then (\n\
    \t\t\tif not !ecran_open then \n\
    \t\t\t (ecran_open := true ; \n\
    \t\t\tGraphics.open_graph \" 2000x1000\" ; \n \
    \t\t\t\tGraphics.set_line_width 10) ; \n \
    \t\t\tlet ram = t_rams.(" ^ (string_of_int !num_ram_ecran) ^ ") in \n\
    \t\t\tAffiche.affiche_batons ram.(0) ram.(1) ram.(2) \
      ram.(3) ram.(4) ram.(5) ram.(6) )  ;\n\n") ;

  if !doit_stop then output_string cfile 
    "\t\t (* Cas spécial où on veut pouvoir arrêter la machine *) \n\
    \t\tif var_stop_prgm () = 1 then number_steps := !step ;\n" ;

  output_string cfile 
    (if !doit_affiche_batons then 
      "\t\tdone ; \n\t\tGraphics.close_graph () \n"
     else "\t\tdone\n") ; 
	(* === Fin ===*)
	try recopie skel cfile
	with End_of_file -> close_in skel ; close_out cfile


let main filename =
	Printf.printf "ok" ;
  try
    let p = Netlist.read_file filename in
    begin try
        let p = Scheduler.schedule p in
        compiler filename p
      with
        | Scheduler.Combinational_cycle ->
            Format.eprintf "The netlist has a combinatory cycle.@.";
    end;
  with
    | Netlist.Parse_error s -> Format.eprintf "An error accurred: %s@." s; exit 2

;;

Arg.parse [] main ""
