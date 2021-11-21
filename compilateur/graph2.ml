type graph = int list array

let has_cycle gr =
  let n = Array.length gr in
  let non_vis = Array.make n true in 
  let rec visite u =
    non_vis.(u) <- false;
    explore gr.(u)
  and explore = function
    |[] -> false
    |h::t -> if non_vis.(h) then (visite h) || (explore t) else true
  in if gr = [||] then true else visite 0

let diam gr =
  let n = Array.length gr in
  if has_cycle gr then failwith "graphe cyclique";
  let dist = Array.make n (-1) in
  let rec visite u =
    if dist.(u) = -1 then 
      dist.(u) <- List.fold_left (fun x n -> max x ((visite n)+1) ) 1 gr.(u);
    dist.(u) in
  let md = ref 0 in
  for i = 0 to (Array.length gr) - 1 do
    md := max !md (visite i)
  done;
  !md
