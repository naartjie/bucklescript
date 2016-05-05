(* Copyright (C) 2015-2016 Bloomberg Finance L.P.
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * In addition to the permissions granted to you by the LGPL, you may combine
 * or link a "work that uses the Library" with a publicly distributed version
 * of this file to produce a combined library or application, then distribute
 * that combined work under the terms of your choosing, with no requirement
 * to comply with the obligations normally placed on you by section 4 of the
 * LGPL version 3 (or the corresponding section of a later version of the LGPL
 * should you choose to use a later version).
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA. *)





type t = Lambda.lambda

type binop = t -> t -> t 

type triop = t -> t -> t -> t 

type unop = t -> t 

let if_ (a : t) (b : t) c = 
  match a with
  | Lconst v ->
    begin match v with
    | Const_pointer (x, _)  | Const_base(Const_int x)
      ->
      if x <> 0 then b else c
    | Const_base (Const_char x) ->
      if Char.code x <> 0 then b else c
    | Const_base (Const_int32 x) ->
      if x <> 0l then b else c
    | Const_base (Const_int64 x) ->
      if x <> 0L then b else c
    | Const_base (Const_nativeint x) ->
      if x <> 0n then b else c
    | Const_base (Const_string _ | Const_float _ ) -> b
    | Const_block _
    | Const_float_array _
    | Const_immstring _ -> b
    end
  | _ ->  Lifthenelse (a,b,c)

let switch lam lam_switch : t = 
  Lswitch(lam,lam_switch)

let stringswitch (lam : t) cases default : t = 
  match lam with
  | Lconst (Const_base (Const_string (a,_))) ->
    begin
      try List.assoc a cases with Not_found ->
        begin
          match default with
          | Some x -> x
          | None -> assert false
        end
    end
  | _ -> Lstringswitch(lam, cases, default)


let true_ : t =
  Lconst (Const_pointer ( 1, Pt_constructor "true")) 

let false_ : t =
  Lconst (Const_pointer( 0, Pt_constructor "false"))

let unit : t = 
  Lconst (Const_pointer( 0, Pt_constructor "()"))


(** [l || r ] *)
let sequor l r = if_ l true_ r 

(** [l && r ] *)
let sequand l r = if_ l r false_

let seq a b : t = 
  Lsequence (a, b)

let while_ a b : t  = 
  Lwhile(a,b)

let try_  body id  handler : t = 
  Ltrywith(body,id,handler)

let for_ v e1 e2 dir e3 : t  = 
  Lfor(v,e1,e2,dir,e3)

let event l (_event : Lambda.lambda_event) = l 

let ifused v l : t  = 
  Lifused (v,l)

let assign v l : t = Lassign(v,l)

let send u m o ll v : t = 
  Lsend(u, m, o, ll, v)

let staticcatch  a b c : t = Lstaticcatch(a,b,c)

let staticraise a b : t = Lstaticraise(a,b)

let prim prim ll : t = Lprim(prim,ll)

let not x : t = 
  prim Pnot [x]

module Prim = struct 
  type t = Lambda.primitive
  let js_is_nil : t = 
    Lambda.Pccall{ prim_name = "js_is_nil";
                   prim_arity = 1 ;
                   prim_alloc = false;
                   prim_native_name = "js_is_nil";
                   prim_native_float = false;
                   prim_attributes = [];
                   prim_ty = None
                 }

  let js_is_undef : t = 
    Lambda.Pccall{ prim_name = "js_is_undef";
                   prim_arity = 1 ;
                   prim_alloc = false;
                   prim_native_name = "js_is_undef";
                   prim_native_float = false;
                   prim_attributes = [];
                   prim_ty = None
                 }

  let js_is_nil_undef : t  = 
    Lambda.Pccall{ prim_name = "js_is_nil_undef";
                   prim_arity = 1 ;
                   prim_alloc = false;
                   prim_native_name = "js_is_nil_undef";
                   prim_native_float = false;
                   prim_attributes = [];
                   prim_ty = None
                 }

end
