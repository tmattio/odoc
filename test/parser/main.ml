
let process file lexbuf =
  match Doc_parser.parse lexbuf with
  | Doc_parser.Ok t ->
    Format.printf "%a@." Doc_parser.print t
  | Doc_parser.Error { error; location } ->
    let msg = Doc_parser.Error.message error in
    let loc =
      let { Doc_parser.Error. start ; finish } = location in
      let open Lexing in
      let loc_start = {
        pos_fname = file;
        pos_bol = 0;
        pos_lnum = start.line;
        pos_cnum = start.column;
      } in
      let loc_end = {
        pos_fname = file;
        pos_bol = 0;
        pos_lnum = finish.line;
        pos_cnum = finish.column;
      } in
      { Location. loc_start; loc_end; loc_ghost=false }
    in
    Location.(report_error Format.err_formatter (error ~loc msg));
    Format.fprintf Format.err_formatter "\n%!"

let () =
  if Array.length Sys.argv <> 2 then begin
    Format.eprintf "Usage: %s FILE@." Sys.argv.(0);
    exit 1
  end;
  let file = Sys.argv.(1) in
  if not (Sys.file_exists file) then begin
    Format.eprintf "File \"%s\" does not exist@." file;
    exit 1
  end;
  let ic = open_in file in
  let lexbuf = Lexing.from_channel ic in
  process file lexbuf;
  close_in ic
