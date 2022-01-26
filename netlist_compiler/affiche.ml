
open Graphics

let print16 n0 n =
  let k0, k = ref n0, ref n in
  let b0, b = ref (n0 land 1), ref (n land 1) in
  let set_clr () =
    if !b=1 then set_color foreground
    else set_color background in
  let aux () =
    if !b = !b0 then rmoveto 0 (-100)
    else (set_clr () ; rlineto 0 (-100) ) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto 100 0
    else (set_clr () ; rlineto 100 0) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto 0 100
    else (set_clr () ; rlineto 0 100) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto (-100) 0
    else (set_clr () ; rlineto (-100) 0) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto 0 100
    else (set_clr () ; rlineto 0 100) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto 100 0
    else (set_clr () ; rlineto 100 0) ;
    k := !k lsr 1 ; k0 := !k0 lsr 1 ;
    b := !k land 1 ; b0 := !k0 land 1 ;
    if !b = !b0 then rmoveto 0 (-100)
    else (set_clr () ; rlineto 0 (-100) )
  in
  aux () ; 
  rmoveto 100 0 ;
  k := !k lsr 1 ; k0 := !k0 lsr 1 ;
  b := !k land 1 ; b0 := !k0 land 1 ;
  aux ()

let s0 = ref 0
let m1 = ref 0
let h0 = ref 0
let j0 = ref 0
let m0 = ref 0
let al0 = ref 0
let ar0 = ref 0

let affiche_sec = true

let affiche_batons
  s (* secondes *)
  mi (* minutes *)
  h (* heures *) 
  j (* jours *)
  mo (* mois *)
  al (* millénaire + centenaire *) 
  ar (* décennie + année *) =

  if h <> !h0 then (
  moveto 300 600 ;
  print16 !h0 h )
  else if mi <> !m1 then (
  moveto 800 600 ;
  print16 !m1 mi )
  else if s <> !s0 then (
  moveto 1300 600 ;
  if affiche_sec then print16 !s0 s )
  else if j <> !j0 then (
  moveto 100 250 ;
  print16 !j0 j )
  else if mo <> !m0 then (
  moveto 600 250 ;
  print16 !m0 mo )
  else if al <> !al0 then (
  moveto 1100 250 ;
  print16 !al0 al )
  else if ar <> !ar0 then (
  moveto 1500 250 ;
  print16 !ar0 ar ) ;

  s0 := s ;
  m1 := mi ;
  h0 := h ;
  j0 := j ;
  m0 := mo ;
  al0 := al ;
  ar0 := ar

