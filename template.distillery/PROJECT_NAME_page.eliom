(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
    open Eliom_content.Html.F
]

[%%client
    module Ocsigen_config = struct
      let get_debugmode () = false
    end
]

(* FIXME MOBILE *)
let%server css_name = !%%%MODULE_NAME%%%_config.css_name
let%client css_name = try Js.to_string (Js.Unsafe.global##.___css_name_)
  with _ -> ""

let%server css_name_script =
  [script (cdata_script (Printf.sprintf "var __css_name = '%s';" css_name))]
let%client css_name_script = []

(* FIXME MOBILE *)
let%server app_js = [%%%MODULE_NAME%%%_base.App.application_script ~defer:true ()]
let%client app_js = []
(* VVV Warning: either we use exactly the same global node
   (and make sure global nodes work properly on client side),
   or we do not add the script on client side.
   I chose the second solution. *)

let%server the_local_js = [
  ["onload.js"]
]

let%client the_local_js = [] (* in index.html *)

let%shared the_local_css = [
  ["font-awesome.css"];
  ["ot_defaults.css"];
  ["ot_carousel.css"];
  ["ot_drawer.css"];
  ["ot_icons.css"];
  ["ot_picture_uploader.css"];
  ["ot_popup.css"];
  ["ot_spinner.css"];
  ["eba_otdemo.css"];
  ["eba.css"]
]

[%%shared.start]

module Page_config = struct

  include Os_page.Default_config

  let title = "%%%PROJECT_NAME%%%"

  let local_js = the_local_js
  let local_css = the_local_css

  let other_head = css_name_script@app_js

  let default_predicate _ _ = Lwt.return true

  let default_connected_predicate _ _ _ = Lwt.return true

  let default_error_page _ _ exn =
    %%%MODULE_NAME%%%_container.page None
      (if Ocsigen_config.get_debugmode ()
       then [p [pcdata (Printexc.to_string exn)]]
       else [p [pcdata "Error"]])

  let default_connected_error_page userid_o _ _ exn =
    %%%MODULE_NAME%%%_container.page userid_o
      (if Ocsigen_config.get_debugmode ()
       then [p [pcdata (Printexc.to_string exn)]]
       else [p [pcdata "Error"]])

end


include Os_page.Make(Page_config)
