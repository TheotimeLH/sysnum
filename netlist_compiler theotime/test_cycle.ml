open Netlist_ast
open Graph

exception Combinational_cycle

let read_exp (_,e)  =
    let rec arg_to_ident = function
        [] -> []
        |(Avar x)::q -> x :: arg_to_ident q
        |_::q -> arg_to_ident q in
    let recup e =
        match e with
        |Earg a | Enot a -> [a]
        |Ebinop(_,a1,a2) -> [a1 ; a2]
        |Emux(a1,a2,a3) -> [a1 ; a2 ; a3]
        |Erom(_,_,a) -> [a]
        |Eram(_,_,a,_,_,_) -> [a]
        |Econcat(a1,a2) -> [a1 ; a2]
        |Eslice(_,_,a) -> [a]
        |Eselect(_,a) -> [a] 
        |Ereg(_) -> [] in
    arg_to_ident (recup e)

let test_cycle p =
    let g = mk_graph () in
    (*  List.iter  (add_node g) p.p_inputs ; *)
    List.iter  (fun (i,_) -> add_node g i) p.p_eqs ;
    let add_edge' i inp =
        if not (List.mem inp p.p_inputs)
           then add_edge g i inp in
    let eq (i,e) =  
        let inp = read_exp (i,e) in
        List.iter (add_edge' i) inp in
    List.iter eq p.p_eqs ;
    if has_cycle g then raise Combinational_cycle
