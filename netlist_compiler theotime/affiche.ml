
open Graphics

let print16 n0 n =
  let k0, k = ref n0, ref n in
  let b0, b = ref (n0 mod 2), ref (n mod 2) in
  let set_clr () =
    if !b=1 then set_color foreground
    else set_color background in
  let aux () =
    if !b = !b0 then rmoveto 0 (-100)
    else (set_clr () ; rlineto 0 (-100) ) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto 100 0
    else (set_clr () ; rlineto 100 0) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto 0 100
    else (set_clr () ; rlineto 0 100) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto (-100) 0
    else (set_clr () ; rlineto (-100) 0) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto 0 100
    else (set_clr () ; rlineto 0 100) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto 100 0
    else (set_clr () ; rlineto 100 0) ;
    k := !k/2 ; k0 := !k0/2 ;
    b := !k mod 2 ; b0 := !k0 mod 2 ;
    if !b = !b0 then rmoveto 0 (-100)
    else (set_clr () ; rlineto 0 (-100) )
  in
  aux () ; 
  rmoveto 100 0 ;
  aux ()

let s0 = ref 0
let m1 = ref 0
let h0 = ref 0
let j0 = ref 0
let m0 = ref 0
let al0 = ref 0
let ar0 = ref 0

let affiche_batons
  s (* secondes *)
  mi (* minutes *)
  h (* heures *) 
  j (* jours *)
  mo (* mois *)
  al (* millénaire + centenaire *) 
  ar (* décennie + année *) =

  if s <> !s0 then begin
  moveto 350 700 ;
  print16 !s0 s ;
  if mi <> !m1 then begin
  rmoveto 200 0 ;
  print16 !m1 mi ;
  if h <> !h0 then begin
  rmoveto 200 0 ;
  print16 !h0 h ;
  if j <> !j0 then begin
  moveto 150 300 ;
  print16 !j0 j ;
  if mo <> !m0 then begin
  rmoveto 200 0 ;
  print16 !m0 mo ;
  if al <> !al0 then begin
  rmoveto 200 0 ;
  print16 !al0 al ;
  if ar <> !ar0 then begin
  rmoveto 100 0 ;
  print16 !ar0 ar 
  end end end end end end end ;

  s0 := s ;
  m1 := mi ;
  h0 := h ;
  j0 := j ;
  m0 := mo ;
  al0 := al ;
  ar0 := ar
  

