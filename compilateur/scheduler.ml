open Netlist_ast
open Graph2

exception Combinational_cycle

let read_exp eq = let id, ex = eq in
   let liste = ref [] in
   let traiterarg = function |Avar(ent) -> liste := ent::!liste |Aconst _ -> () in
   begin
   match ex with
   |Ereg(ent) -> (*liste := ent::!liste*) ()
   |Earg(ar) |Enot(ar) |Erom(_, _, ar) |Eslice(_, _, ar) |Eselect(_, ar) -> traiterarg ar
   |Ebinop(_, ar1, ar2)|Econcat(ar1, ar2) -> begin traiterarg ar1; traiterarg ar2 end
   |Emux(ar1, ar2, ar3) -> begin traiterarg ar1; traiterarg ar2; traiterarg ar3 end
   |Eram(_, _, ar1, ar2, ar3, _) -> traiterarg ar1
   end;
   !liste

let construit_graphe p =
  let taille = List.length p.p_eqs + List.length p.p_inputs in
  let gr = Array.make taille [] in
  let id_neux = Hashtbl.create taille in
  let nb = ref 0 in
  List.iter (fun id -> Hashtbl.add id_neux id !nb; incr nb) p.p_inputs;
  List.iter (fun (id, expr) -> Hashtbl.add id_neux id !nb; incr nb) p.p_eqs;
  let ajoute_noeud (id, expr) =
    gr.(Hashtbl.find id_neux id) <- 
            List.map (Hashtbl.find id_neux) (read_exp (id, expr)) in
  List.iter ajoute_noeud p.p_eqs;
  gr

let donne_diam p =
  let gr = construit_graphe p in
  if has_cycle gr then
    raise Combinational_cycle 
    else Format.printf "Longueur du chemin critique : %d@." (diam gr);;

(*let schedule p =
   let l = p.p_eqs in
   let g = Graph.mk_graph () in
   (*print_int (List.length l); (*debog*)*)
   let f x = Graph.add_node g (fst x) in List.iter f l;
   (*List.iter (Graph.add_node g) p.p_inputs;*)
   (*List.iter (Graph.add_node g) p.p_outputs;*)
   let f x = List.iter (fun id -> if (List.mem id p.p_inputs) then () else Graph.add_edge g id (fst x)) (read_exp x) in
   List.iter f l;
   let l2 =
   if (Graph.has_cycle g) then (raise Combinational_cycle) else (Graph.topological g) in
   let rec recherche id = function
      |[] -> failwith "vide"
      |eq::t when fst eq = id -> eq
      |h::t -> recherche id t
   and transforme = function
      |[] -> []
      |id::t -> let tt = transforme t in (recherche id l)::tt
   in  
   {p_inputs = p.p_inputs; p_eqs = (transforme l2); p_outputs = p.p_outputs; p_vars = p.p_vars};;
   (*let rec ident_list_to_expr_list lref = function
      |[] -> []
      |h::t -> let l = ident_list_to_expr_list t lref in (h, List.assoc h lref)::l
   in 
   {p_inputs = p.p_inputs; p_eqs = (ident_list_to_expr_list p.p_eqs l2); p_outputs = p.p_outputs; p_vars = p.p_vars}*)
*)      
