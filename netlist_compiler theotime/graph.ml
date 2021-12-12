exception Cycle
type mark = NotVisited | InProgress | Visited

type 'a graph =
    { mutable g_nodes : 'a node list }
and 'a node = {
  n_label : 'a;
  mutable n_mark : mark;
  mutable n_link_to : 'a node list;
  mutable n_linked_by : 'a node list;
}

let mk_graph () = { g_nodes = [] }

let add_node g x =
  let n = { n_label = x; n_mark = NotVisited; n_link_to = []; n_linked_by = [] } in
  g.g_nodes <- n :: g.g_nodes

let node_of_label g x =
  List.find (fun n -> n.n_label = x) g.g_nodes

let add_edge g id1 id2 =
  try
    let n1 = node_of_label g id1 in
    let n2 = node_of_label g id2 in
    n1.n_link_to   <- n2 :: n1.n_link_to;
    n2.n_linked_by <- n1 :: n2.n_linked_by
  with Not_found -> Format.eprintf "Tried to add an edge between non-existing nodes"; raise Not_found

let clear_marks g =
  List.iter (fun n -> n.n_mark <- NotVisited) g.g_nodes

let has_cycle g =
    clear_marks g ;
    let rec parcours n = match n.n_mark with
        |NotVisited ->
                    n.n_mark <- InProgress ;
                    List.iter parcours n.n_link_to ;
                    n.n_mark <- Visited
        |InProgress -> raise Cycle
        |_ -> ()
    in
    let rec depart = function
        [] -> false
        |h::q -> try parcours h ; depart q
                 with Cycle -> true in
    depart g.g_nodes

let topological g =
    clear_marks g ;
    let sol = ref [] in
    let rec parcours n =
        if n.n_mark = NotVisited then begin
           n.n_mark <- Visited ;
           List.iter parcours n.n_linked_by ;
           sol := n.n_label :: !sol end
    in
    List.iter parcours g.g_nodes ;
    (* List.rev *) !sol 

(*
let graph_of_graph' a =
  let g = mk_graph () in
  for i = 0 to Array.length a - 1 do
    add_node g i
  done;
  Array.iteri (fun src -> List.iter (add_edge g src)) a;
  g
    
let _ =
    topological (graph_of_graph' [| [1]; [2]; [3]; [] |])       *)
