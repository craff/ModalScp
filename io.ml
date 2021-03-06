(**{3 Output functions, general and for debugging channels}*)

open Format

type fmts =
  { mutable out : formatter
  ; mutable err : formatter
  ; mutable log : formatter
  ; mutable tex : formatter
  ; mutable gml : formatter }

let fmts =
  { out = std_formatter
  ; err = err_formatter
  ; log = err_formatter
  ; tex = std_formatter
  ; gml = std_formatter }

let out ff = fprintf  fmts.out ff
let err ff = fprintf  fmts.err ff
let log ff = fprintf  fmts.log ff
let tex ff = fprintf  fmts.tex ff
let nul ff = ifprintf fmts.log ff

(*
let read_file : (string -> Input.buffer) ref =
  let read_file fn =
    let add_fn dir = Filename.concat dir fn in
    let fs = fn :: (List.map add_fn !Config.path) in
    let rec find = function
      | []     -> err "File %S not found.\n%!" fn; exit 1
      | fn::fs -> if Sys.file_exists fn then Input.from_file fn
                  else find fs
    in find fs
  in ref read_file

let file fn = !read_file fn
 *)

let ((fmt_of_file : string -> formatter), (close_files : unit -> unit)) =
  let channels = ref [] in
  let fmt_of_file fn =
    let ch = open_out fn in
    channels := ch :: !channels;
    formatter_of_out_channel ch
  in
  let close_files () =
    List.iter close_out !channels;
    channels := []
  in
  (fmt_of_file, close_files)

let set_tex_file : string -> unit =
  fun fn -> fmts.tex <- fmt_of_file fn
let set_gml_file : string -> unit =
  fun fn -> fmts.gml <- fmt_of_file fn

let debug = ref ""
let debug_cmp = 'c'
let debug_prg = 'p'
let debug_rec = 'r'
let debug_sat = 's'
let debug_tim = 't'
let debug_ver = 'v'
let debug_sct = 'y'
let debug_all = "cprstvy"

let log_cmp ff = if String.contains !debug debug_cmp then log ff else nul ff
let log_prg ff = if String.contains !debug debug_prg then log ff else nul ff
let log_rec ff = if String.contains !debug debug_rec then log ff else nul ff
let log_sat ff = if String.contains !debug debug_sat then log ff else nul ff
let log_tim ff = if String.contains !debug debug_tim then log ff else nul ff
let log_ver ff = if String.contains !debug debug_ver then log ff else nul ff
let log_sct ff = if String.contains !debug debug_sct then log ff else nul ff

let set_debug s =
  debug := if s = "all" then debug_all else s
