open Lexing
open Format

let usage = "Usage: ./pomme file.pomme"

let options = []

let file = ref ""

let report (s,e) =
  let l = s.pos_lnum in
  let fc = s.pos_cnum - s.pos_bol + 1 in
  let lc = e.pos_cnum - s.pos_bol + 1 in
  eprintf "File \"%s\", line %d, characters %d-%d:\n" !file l fc lc

let () =
  Arg.parse options (fun s -> file:=s) usage ;
  if !file = "" then (eprintf "erreur entrée: aucun fichier renseigné " ; exit 1) ;
  if not (Filename.check_suffix !file ".pomme")
  then (eprintf "erreur entrée: pas d'extension .pomme " ; exit 1) ;
  let ch = open_in !file in
  let lb = Lexing.from_channel ch in
  let lignes = try Parser.fichier Lexer.token lb with
    | Lexer.Lexer_non_fini { loc=pos ; msg=s } ->
      report pos ;
      eprintf "erreur lexicale: %s@." s ;
      exit 1
    | Lexer.Lexer_error s ->
      report (lexeme_start_p lb,lexeme_end_p lb) ;
      eprintf "erreur lexicale: %s@." s ;
      exit 1
    | _ ->
      report (lexeme_start_p lb,lexeme_end_p lb) ;
      eprintf "erreur syntaxique: grammaire non reconnue@." ;
      exit 1
  in
  close_in ch ;
  try Production.produit (Filename.chop_suffix !file ".pomme") lignes
  with
    | Production.Prod_error { loc=pos ; msg=s } ->
      report pos ;
      eprintf "erreur à la production de code: %s@." s ;
      exit 1 
