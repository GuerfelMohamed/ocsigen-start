(* Ocsigen-start
 * http://www.ocsigen.org/ocsigen-start
 *
 * Copyright (C) Université Paris Diderot, CNRS, INRIA, Be Sport.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

open Os_types

module type S = sig
  include Eliom_notif.S
    with type identity = User.id option
  val unlisten_user :
    ?sitedata:Eliom_common.sitedata -> userid:User.id -> key -> unit
  val notify : ?notfor:[`Me | `User of User.id] -> key -> server_notif -> unit
end

module type MAKE = sig
  type key
  type server_notif
  type client_notif
  val prepare : User.id option -> server_notif -> client_notif option Lwt.t
  val equal_key : key -> key -> bool
end

module Make(A : MAKE) : S
  with type key = A.key
   and type server_notif = A.server_notif
   and type client_notif = A.client_notif
= struct
  include Eliom_notif.Make (struct
    type identity = User.id option
    type key = A.key
    type server_notif = A.server_notif
    type client_notif = A.client_notif
    let prepare = A.prepare
    let equal_key = A.equal_key
    let equal_identity = (=)
    let get_identity () = Lwt.return @@ Os_current_user.Opt.get_current_userid ()
    let max_resource = 1000
    let max_identity_per_resource = 10
  end)
  let unlisten_user ?sitedata ~userid (id : A.key) =
    let state =
      Eliom_state.Ext.volatile_data_group_state
        ~scope:Eliom_common.default_group_scope
        (Int64.to_string userid)
    in
    Ext.unlisten state id
  let notify ?notfor key notif =
    let notfor = match notfor with
      | None -> None
      | Some `Me -> Some `Me
      | Some (`User id) -> Some (`Id (Some id))
    in
    notify ?notfor key notif
end

module type SIMPLE = sig
  type key
  type notification
  val equal_key : key -> key -> bool
end

module Simple (A : SIMPLE) : S
  with type key = A.key
   and type server_notif = A.notification
   and type client_notif = A.notification
= Make (struct
  type key = A.key
  type server_notif = A.notification
  type client_notif = A.notification
  let prepare _ n = Lwt.return (Some n)
  let equal_key = A.equal_key
end)
