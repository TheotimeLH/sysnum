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
	let str_nb_vars = "let nb_vars = " ^ (string_of_int nb_vars) ^ "\n" in
	let str_t_nom = "let t_nom = [|" ^ (String.concat ";" (Array.to_list t_nom)) ^ "|]\n" in
	let str_t_len = "let t_len = [|" ^ (String.concat ";" 
		(List.map string_of_int (Array.to_list t_len))) ^ "|]\n" in
	output_string cfile (str_nb_vars ^ str_t_nom ^ str_t_len) ;	
  let doit_affiche_batons = ref false in
  let outputs' = List.filter 
    (fun id -> if id = "maj_ecran" then 
      (doit_affiche_batons := true ; false) else true)
    p.p_outputs in
	recopie skel cfile ;

	(* === Structures 2 (ROM et RAM) === *)
	let list_roms = ref [] in 
	let info_rams = Array.make nb_vars (0,0) in
	let l_regs = ref [] in
	let l_rams = ref [] in
  let pour_init = function
    |(a,Ereg b) -> l_regs := (a,b) :: !l_regs
    |(x,Erom(a_size,w_size,_)) ->
      list_roms := (x,a_size,w_size) :: !list_roms
    |(x,Eram(a_size,w_size,_,we,wa,data)) ->
			info_rams.(num x) <- (a_size,w_size) ;
      l_rams := (x,we,wa,data) :: !l_rams
    |_ -> () in
  List.iter pour_init p.p_eqs ;
	
	let str_info_rams = "let info_rams = [|" ^ (String.concat ";"
		(List.map (fun (a_s,w_s) -> string_of_int a_s ^ "," ^ string_of_int w_s)
		(Array.to_list info_rams))) ^ "|]\n" in
	let str_l_roms = "let l_roms = [" ^ (String.concat ";"
		(List.map (fun (x,a_s,w_s) -> string_of_int (num x) ^ "," ^
			string_of_int a_s ^ "," ^ string_of_int w_s) !list_roms)) ^ "]\n" in

	output_string cfile (str_info_rams ^ str_l_roms) ;
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
		|	Avar id -> "var_" ^ id ^ " () "
		|	Aconst v -> begin match v with 
				|VBit b -> if b then "(1,1) " else "(1,0) "
				|VBitArray t -> 
					let n = Array.length t in
					let k = ref 0 in
					for i = 0 to n-1 do
						k := (!k lsl 1) + (if t.(i) then 1 else 0)
						done ;
					"(" ^ (string_of_int n) ^ "," ^ (string_of_int !k) ^ ") "
				end
		in 
	let pb_binop id = 
     "(Printf.eprintf \"Problème avec la porte d'opération n bits " ^ id ^ 
     ", %d != %d\ \" len1 len2 ; exit 1)" in

	let mk_fct_var_input id = 
    (debut id) ^
    begin match id with
    | "real_clock" -> "\t\tlet valeur = (1,(int_of_float (Sys.time ())) mod 2) in \n"
    | _ -> "\t\tlet valeur = ask_input " ^ (snum id) ^ " in\n" 
    end
    ^ (fin id) in


	let mk_fct_var_porte (id,exp) = match exp with
		|	Ereg r -> "let var_" ^ id ^ " () = t_val.(" ^ (snum id) ^ ")\n\n"
		|	_ -> (* on traite juste les REG à part *) 
		(debut id) ^
		begin match exp with
			|	Earg a -> "\t\tlet valeur = " ^ (sarg a) ^ " in\n"
			|	Enot a -> 
					"\t\tlet (len,n) = " ^ (sarg a) ^ " in\n\
          \t\tlet valeur = (len,(lnot n) land ((1 lsl len) -1)) in \n"
          (* Version à la main :
					\t\tlet n = ref n and k = ref 0 in\n\
					\t\tfor i = 0 to len -1 do\n\
					\t\t\tk := !k + ((1-(!n mod 2)) lsl i) ; n := !n lsr 1 done ;\n\
					\t\tlet valeur = (len,!k) in \n *)

			|	Ebinop (Xor,a1,a2) ->
					"\t\tlet (len1,n1) = " ^ (sarg a1) ^ " and (len2,n2) = " ^ (sarg a2) ^ " in\n\
					\t\tlet valeur = if len1 = len2 then (len1, n1 lxor n2)\n\
					\t\telse "^ (pb_binop id) ^" in\n\n"

			|	Ebinop (op,a1,a2) ->
          (* Je veux des opérations paresseuses, si a1 vaut 1 alors a1 & _ = 1
             ainsi on peut parfois se passer de calculer a2. Mais du coup on 
             peut laisser passer des opérations avec len1 != len2.
             Je me demande si c'était une bonne idée de stocker la len des buss
             dans le prgm compilé. J'aurai pu la garder en donné dans le skeleton
             et le compiler. Tant pis.    *)
					"\t\tlet (len1,n1) = " ^ (sarg a1) ^ " in\n\
					\t\tlet valeur = " ^
					begin match op with
						|	Or -> " if n1 = (1 lsl len1 - 1) then (len1,n1) \n"
						|	And -> " if n1 = 0 then (len1,0) \n"
						|	_ (*Nand*) -> " if n1 = 0 then (len1,1 lsl len1 - 1) \n" end ^
					"\t\t\telse ( let (len2,n2) = " ^ (sarg a2) ^ " in \n\
					\t\t\t\tif len1 <> len2 then \n\t\t\t\t"^ (pb_binop id) ^ "\n\
					\t\t\t\telse " ^
          begin match op with
            | Or -> "(len1,n1 lor n2) ) in \n"
            | And -> "(len1,n1 land n2) ) in \n"
            | _ (*Nand*) -> " (len1, (lnot (n1 land n2)) land (1 lsl len1 -1)) ) in \n" end

			|	Emux (choice,a1,a2) ->
					"\t\tlet valeur = if snd ("^ (sarg choice) ^ ") > 0 then "^ (sarg a2) ^
					"else " ^ (sarg a1) ^ " in\n"

			|	Erom (_,_,a) -> 
					"\t\tlet valeur = t_roms.("^ (snum id) ^").(snd ("^ (sarg a) ^")) in\n"

			|	Eram (_,_,a,_,_,_) ->
					"\t\tlet valeur = t_rams.("^ (snum id) ^").(snd ("^ (sarg a) ^")) in\n"

			| Econcat (a1,a2) ->
					"\t\tlet (len1,n1) = " ^ (sarg a1) ^ " and (len2,n2) = " ^ (sarg a2) ^ " in\n\
					\t\tlet valeur = (len1+len2,(n1 lsl len2) + n2) in\n"

			|	Eselect (i,a) -> 
					"\t\tlet (len,n) = "^ (sarg a) ^" and i = "^ (string_of_int i) ^" in \n\
					\t\tlet valeur = if i+1>len then failwith \" i-eme bit avec i>len\" \n\
					\t\telse (1,(n lsr (len-i-1)) mod 2) in\n"

			|	Eslice (i1,i2,a) -> 
					"\t\tlet (len,n) = "^ (sarg a) ^" in \n\
					\t\tlet i1 = "^ (string_of_int i1) ^" and i2 = "^ (string_of_int i2) ^" in\n\
					\t\tlet valeur = if i2+1>len || i2 < i1 then failwith \"pb slice\"\n\
					\t\telse (i2-i1+1,( (n lsr (len-i2-1)) mod (1 lsl (i2-i1+1)))) in\n"
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
    "\t\tGraphics.open_graph \" 2000x1000\" ; \n" ;
  recopie skel cfile ;
	let mk_sortie id =
		  "\t\tlet sortie = (intv_to_strb (var_"^ id ^" ())) in\n\
		  \t\tif !print_sorties then Printf.printf \"=> "^ id ^" = %s \\n\" sortie ;" in
	output_string cfile (String.concat "\n" (List.map mk_sortie outputs')) ;
	recopie skel cfile ;

	(* === Les REG / RAM === *)
	let mk_reg (a,b) =
		"\t\tt_reg.("^ (snum a) ^") <- var_"^ b ^" () ;\n" in
	output_string cfile (String.concat "" (List.map mk_reg !l_regs)) ;

	let mk_ram (id,w_e,w_a,w_d) =
		"\t\tif snd ("^ (sarg w_e) ^") > 0 then t_rams.("^ (snum id) ^").(snd("
		^ (sarg w_a) ^")) <- "^ (sarg w_d) ^ " ;\n" in
	output_string cfile (String.concat "" (List.map mk_ram !l_rams)) ;

	let mk_reg2 (a,_) =
		"\t\tt_val.("^ (snum a) ^") <- t_reg.("^ (snum a) ^") ;\n" in
	output_string cfile (String.concat "" (List.map mk_reg2 !l_regs)) ; 

  (* === La sortie spéciale Sept_batons === *)
  if !doit_affiche_batons then output_string cfile
    ("\n\t\t (* Cas spécial, où on a demandé à utiliser des sept_batons : *) \n\
    \t\tif snd (var_maj_ecran ()) = 1 then (\n\
    \t\tlet ram = t_rams.(" ^ "2422" ^ ") in \n\
    \t\t\tAffiche.affiche_batons (snd ram.(0)) (snd ram.(1)) (snd ram.(2)) \n\
    \t\t\t\t(snd ram.(3)) (snd ram.(4)) (snd ram.(5)) (snd ram.(6)) )  ;\n") ;

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
