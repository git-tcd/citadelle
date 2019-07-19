(******************************************************************************
 * HOL-OCL
 *
 * Copyright (c) 2011-2018 Université Paris-Saclay, Univ. Paris-Sud, France
 *               2013-2017 IRT SystemX, France
 *               2011-2015 Achim D. Brucker, Germany
 *               2016-2018 The University of Sheffield, UK
 *               2016-2017 Nanyang Technological University, Singapore
 *               2017-2018 Virginia Tech, USA
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of the copyright holders nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************)

section\<open>OCL Meta-Model aka. AST definition of OCL (I)\<close>

theory  Meta_UML
imports "../../compiler_generic/meta_isabelle/Meta_Pure"
        "../Init_rbt"
begin

subsection\<open>Type Definition\<close>

datatype ocl_collection = Set
                        | Sequence
                        | Ordered0 \<comment> \<open>ordered set\<close>
                        | Subsets0 \<^cancel>\<open>binding\<close>
                        | Union0
                        | Redefines0 \<^cancel>\<open>binding\<close>
                        | Derived0 \<^cancel>\<open>string\<close>
                        | Qualifier0 \<^cancel>\<open>binding \<times> use_oclty\<close>
                        | Nonunique0 \<^cancel>\<open>bag\<close>

datatype ocl_multiplicity_single = Mult_nat nat
                                 | Mult_star
                                 | Mult_infinity

record ocl_multiplicity = TyMult :: "(ocl_multiplicity_single \<times> ocl_multiplicity_single option) list"
                          TyRole :: "string option"
                          TyCollect :: "ocl_collection list" \<comment> \<open>return type of the accessor (constrained by the above multiplicity)\<close>

record ocl_ty_class_node =  TyObjN_ass_switch :: nat
                            TyObjN_role_multip :: ocl_multiplicity
                            TyObjN_role_ty :: string
record ocl_ty_class =       TyObj_name :: string
                            TyObj_ass_id :: nat
                            TyObj_ass_arity :: nat
                            TyObj_from :: ocl_ty_class_node
                            TyObj_to :: ocl_ty_class_node
datatype ocl_ty_obj_core =  OclTyCore_pre string \<comment> \<open>class name, untyped\<close> (* FIXME perform the typing separately *)
                          | OclTyCore ocl_ty_class \<comment> \<open>class name, typed\<close>
datatype ocl_ty_obj =       OclTyObj  ocl_ty_obj_core
                                     "ocl_ty_obj_core list \<comment> \<open>the \<^theory_text>\<open>and\<close> semantics\<close>
                                                           list \<comment> \<open>\<open>x # \<dots>\<close> means \<open>x < \<dots>\<close>\<close>" \<comment> \<open>superclass\<close>
datatype ocl_ty =           OclTy_base_void (* NOTE can be merged in a generic tuple *)
                          | OclTy_base_boolean
                          | OclTy_base_integer
                          | OclTy_base_unlimitednatural
                          | OclTy_base_real
                          | OclTy_base_string
                          | OclTy_object ocl_ty_obj
                          | OclTy_collection ocl_multiplicity ocl_ty
                          | OclTy_pair ocl_ty ocl_ty (* NOTE can be merged in a generic tuple *)
                          | OclTy_binding "string option \<comment> \<open>name\<close> \<times> ocl_ty" (* NOTE can be merged in a generic tuple *)
                          | OclTy_arrow ocl_ty ocl_ty
                          | OclTy_class_syn string
                          | OclTy_enum string
                          | OclTy_raw string \<comment> \<open>denoting raw HOL-type\<close> (* FIXME to be removed *)


datatype ocl_association_type = OclAssTy_native_attribute
                              | OclAssTy_association
                              | OclAssTy_composition
                              | OclAssTy_aggregation
datatype ocl_association_relation = OclAssRel "(ocl_ty_obj \<times> ocl_multiplicity) list"
record ocl_association =        OclAss_type     :: ocl_association_type
                                OclAss_relation :: ocl_association_relation

datatype ocl_ctxt_prefix = OclCtxtPre | OclCtxtPost

datatype ocl_ctxt_term = T_pure "term"
                                "string option" \<comment> \<open>represents the unparsed version of the term\<close>
                       | T_to_be_parsed string \<comment> \<open>raw, it includes extra quoting characters like DEL (char 127)\<close>
                                        string \<comment> \<open>same string but escaped without those quoting characters\<close>
                       | T_lambda string ocl_ctxt_term
datatype ocl_prop = OclProp_ctxt "string option" \<comment> \<open>name\<close> ocl_ctxt_term
                  \<^cancel>\<open>| OclProp_rel ocl_ty_obj \<comment> \<open>states that the constraint should be true\<close>
                  | OclProp_ass ocl_association_relation \<comment> \<open>states the relation as true\<close>\<close>
datatype ocl_ctxt_term_inv = T_inv bool \<comment> \<open>True: existential\<close> ocl_prop
datatype ocl_ctxt_term_pp = T_pp ocl_ctxt_prefix ocl_prop
                          | T_invariant ocl_ctxt_term_inv

record ocl_ctxt_pre_post = Ctxt_fun_name :: string \<comment> \<open>function name\<close>
                           Ctxt_fun_ty :: ocl_ty
                           Ctxt_expr :: "ocl_ctxt_term_pp list"

datatype ocl_ctxt_clause = Ctxt_pp ocl_ctxt_pre_post
                         | Ctxt_inv ocl_ctxt_term_inv
record ocl_ctxt = Ctxt_param :: "string list" \<comment> \<open>param\<close>
                  Ctxt_ty :: ocl_ty_obj
                  Ctxt_clause :: "ocl_ctxt_clause list"

datatype ocl_class =   OclClass
                         string \<comment> \<open>name of the class\<close>
                         "(string \<comment> \<open>name\<close> \<times> ocl_ty) list" \<comment> \<open>attribute\<close>
                         "ocl_class list" \<comment> \<open>link to subclasses\<close>

record ocl_class_raw = ClassRaw_name :: ocl_ty_obj
                       ClassRaw_own :: "(string \<comment> \<open>name\<close> \<times> ocl_ty) list" \<comment> \<open>attribute\<close>
                       ClassRaw_clause :: "ocl_ctxt_clause list"
                       ClassRaw_abstract :: bool \<comment> \<open>True: abstract\<close>

datatype ocl_ass_class = OclAssClass ocl_association
                                     ocl_class_raw

datatype ocl_class_synonym = OclClassSynonym string \<comment> \<open>name alias\<close> ocl_ty

datatype ocl_enum = OclEnum string \<comment> \<open>name\<close> "string \<comment> \<open>constructor name\<close> list"

subsection\<open>Extending the Meta-Model\<close>

definition "T_lambdas = List.fold T_lambda"
definition "TyObjN_role_name = TyRole o TyObjN_role_multip"
definition "OclTy_class c = OclTy_object (OclTyObj (OclTyCore c) [])"
definition "OclTy_class_pre c = OclTy_object (OclTyObj (OclTyCore_pre c) [])"
definition "OclAss_relation' l = (case OclAss_relation l of OclAssRel l \<Rightarrow> l)"

fun fold_pair_var where
   "fold_pair_var f t accu = (case t of
    OclTy_pair t1 t2 \<Rightarrow> Option.bind (fold_pair_var f t1 accu) (fold_pair_var f t2)
  | OclTy_binding (Some v, t) \<Rightarrow> fold_pair_var f t (f (v, t) accu)
  | OclTy_binding (None, t) \<Rightarrow> fold_pair_var f t accu
  | OclTy_collection _ t \<Rightarrow> fold_pair_var f t accu
  | OclTy_arrow _ _ \<Rightarrow> None
  | _ \<Rightarrow> Some accu)"

definition "Ctxt_fun_ty_arg ctxt =
 (case
    fold_pair_var
      Cons
      (case Ctxt_fun_ty ctxt of OclTy_arrow t _ \<Rightarrow> t
                              | t \<Rightarrow> t)
      []
  of Some l \<Rightarrow> rev l)"

definition "Ctxt_fun_ty_out ctxt =
 (case Ctxt_fun_ty ctxt of OclTy_arrow _ t \<Rightarrow> Some t
                         | _ \<Rightarrow> None)"

definition "map_pre_post f =
             Ctxt_clause_update
               (L.map
                  (\<lambda> Ctxt_pp ctxt \<Rightarrow>
                     Ctxt_pp (Ctxt_expr_update
                               (L.map
                                  (\<lambda> T_pp pref (OclProp_ctxt n e) \<Rightarrow>
                                     T_pp pref (OclProp_ctxt n (f pref ctxt e))
                                   | x \<Rightarrow> x))
                               ctxt)
                   | x \<Rightarrow> x))"

definition "fold_pre_post f ctxt =
              List.fold
                (\<lambda> Ctxt_pp ctxt \<Rightarrow>
                     f (rev (List.fold
                       (\<lambda> T_pp pref (OclProp_ctxt n e) \<Rightarrow> Cons (pref, n, e)
                        | _ \<Rightarrow> id)
                       (Ctxt_expr ctxt) [])) ctxt
                 | _ \<Rightarrow> id)
                (Ctxt_clause ctxt)"

definition "map_invariant f_inv =
             Ctxt_clause_update
               (L.map
                  (\<lambda> Ctxt_pp ctxt \<Rightarrow>
                     Ctxt_pp (Ctxt_expr_update
                               (L.map
                                 (\<lambda> T_invariant ctxt \<Rightarrow> T_invariant (f_inv ctxt)
                                  | x \<Rightarrow> x))
                               ctxt)
                   | Ctxt_inv ctxt \<Rightarrow> Ctxt_inv (f_inv ctxt)))"

definition "fold_invariant f_inv ctxt =
              List.fold
                (\<lambda> Ctxt_pp ctxt \<Rightarrow>
                             List.fold
                               (\<lambda> T_invariant ctxt \<Rightarrow> f_inv ctxt
                                | _ \<Rightarrow> id)
                              (Ctxt_expr ctxt)
                 | Ctxt_inv ctxt \<Rightarrow> f_inv ctxt)
                (Ctxt_clause ctxt)"

definition "fold_invariant' inva =
  rev (fst (fold_invariant (\<lambda>(T_inv _ (OclProp_ctxt tit inva)) \<Rightarrow> \<lambda> (accu, n).
                               ( (let tit = case tit of None \<Rightarrow> String.nat_to_digit10 n
                                                          | Some tit \<Rightarrow> tit in
                                  (tit, inva))
                                 # accu
                               , Suc n))
                           inva
                           ([], 0)))"

fun remove_binding where
   "remove_binding e = (\<lambda> OclTy_collection m ty \<Rightarrow> OclTy_collection m (remove_binding ty)
                        | OclTy_pair ty1 ty2 \<Rightarrow> OclTy_pair (remove_binding ty1) (remove_binding ty2)
                        | OclTy_binding (_, ty) \<Rightarrow> remove_binding ty
                        | OclTy_arrow ty1 ty2 \<Rightarrow> OclTy_arrow (remove_binding ty1) (remove_binding ty2)
                        | x \<Rightarrow> x) e"

subsection\<open>Class Translation Preliminaries\<close>

definition "const_oid = \<open>oid\<close>"
definition "var_ty_list = \<open>list\<close>"
definition "var_ty_prod = \<open>prod\<close>"
definition "const_oclany = \<open>OclAny\<close>"

definition "single_multip =
  List.list_all (\<lambda> (_, Some (Mult_nat n)) \<Rightarrow> n \<le> 1
                 | (Mult_nat n, None) \<Rightarrow> n \<le> 1
                 | _ \<Rightarrow> False) o TyMult"

fun fold_max_aux where
   "fold_max_aux f l l_acc accu = (case l of
      [] \<Rightarrow> accu
    | x # xs \<Rightarrow> fold_max_aux f xs (x # l_acc) (f x (L.flatten [rev l_acc, xs]) accu))"

definition "fold_max f l = fold_max_aux f (L.mapi Pair l) []"

locale RBTS
begin
definition "lookup m k = RBT.lookup m (String.to_list k)"
definition insert where "insert k = RBT.insert (String.to_list k)"
definition "map_entry k = RBT.map_entry (String.to_list k)"
definition "modify_def v k = RBT.modify_def v (String.to_list k)"
definition "keys m = L.map (\<lambda>s. \<lless>s\<ggreater>) (RBT.keys m)"
definition "lookup2 m = (\<lambda>(k1, k2). RBT.lookup2 m (String.to_list k1, String.to_list k2))"
definition "insert2 = (\<lambda>(k1, k2). RBT.insert2 (String.to_list k1, String.to_list k2))"
definition fold where "fold f = RBT.fold (\<lambda>c. f \<lless>c\<ggreater>)"
definition "entries m = L.map (map_prod (\<lambda>c. \<lless>c\<ggreater>) id) (RBT.entries m)"
end
lemmas [code] =
  \<comment> \<open>def\<close>
  RBTS.lookup_def
  RBTS.insert_def
  RBTS.map_entry_def
  RBTS.modify_def_def
  RBTS.keys_def
  RBTS.lookup2_def
  RBTS.insert2_def
  RBTS.fold_def
  RBTS.entries_def

syntax "_rbt_lookup" :: "_ \<Rightarrow> _" ("lookup") translations "lookup" \<rightleftharpoons> "CONST RBTS.lookup"
syntax "_rbt_insert" :: "_ \<Rightarrow> _" ("insert") translations "insert" \<rightleftharpoons> "CONST RBTS.insert"
syntax "_rbt_map_entry" :: "_ \<Rightarrow> _" ("map'_entry") translations "map_entry" \<rightleftharpoons> "CONST RBTS.map_entry"
syntax "_rbt_modify_def" :: "_ \<Rightarrow> _" ("modify'_def") translations "modify_def" \<rightleftharpoons> "CONST RBTS.modify_def"
syntax "_rbt_keys" :: "_ \<Rightarrow> _" ("keys") translations "keys" \<rightleftharpoons> "CONST RBTS.keys"
syntax "_rbt_lookup2" :: "_ \<Rightarrow> _" ("lookup2") translations "lookup2" \<rightleftharpoons> "CONST RBTS.lookup2"
syntax "_rbt_insert2" :: "_ \<Rightarrow> _" ("insert2") translations "insert2" \<rightleftharpoons> "CONST RBTS.insert2"
syntax "_rbt_fold" :: "_ \<Rightarrow> _" ("fold") translations "fold" \<rightleftharpoons> "CONST RBTS.fold"
syntax "_rbt_entries" :: "_ \<Rightarrow> _" ("entries") translations "entries" \<rightleftharpoons> "CONST RBTS.entries"

function (sequential) class_unflat_aux where
(* FIXME replace with this simplified form *) \<^cancel>\<open>
   "class_unflat_aux rbt rbt_inv rbt_cycle r =
   (case lookup rbt_cycle r of None \<comment> \<open>cycle detection\<close> \<Rightarrow>
      map_option
        (OclClass
          r
          (case lookup rbt r of Some l \<Rightarrow> l))
        (L.bind (class_unflat_aux rbt rbt_inv (insert r () rbt_cycle))
                id
                (case lookup rbt_inv r of None \<Rightarrow> [] | Some l \<Rightarrow> l))
    | _ \<Rightarrow> None)"
\<close>
   "class_unflat_aux rbt rbt_inv rbt_cycle r =
   (case lookup rbt_inv r of None \<Rightarrow>
      (case lookup rbt_cycle r of None \<comment> \<open>cycle detection\<close> \<Rightarrow>
            map_option
              (OclClass
                r
                (case lookup rbt r of Some l \<Rightarrow> l))
              ((\<lambda>f0 f l.
          let l = List.map f0 l in
            if list_ex (\<lambda> None \<Rightarrow> True | _ \<Rightarrow> False) l then
              None
            else
              Some (f (List.map_filter id l))) (class_unflat_aux rbt rbt_inv (insert r () rbt_cycle))
                      id
                      ([]))
          | _ \<Rightarrow> None)
    | Some l \<Rightarrow>
      (case lookup rbt_cycle r of None \<comment> \<open>cycle detection\<close> \<Rightarrow>
            map_option
              (OclClass
                r
                (case lookup rbt r of Some l \<Rightarrow> l))
              ((\<lambda>f0 f l.
          let l = List.map f0 l in
            if list_ex (\<lambda> None \<Rightarrow> True | _ \<Rightarrow> False) l then
              None
            else
              Some (f (List.map_filter id l))) (class_unflat_aux rbt rbt_inv (insert r () rbt_cycle))
                      id
                      (l))
          | _ \<Rightarrow> None))"
by pat_completeness auto

termination
proof -
 have arith_diff: "\<And>a1 a2 (b :: Nat.nat). a1 = a2 \<Longrightarrow> a1 > b \<Longrightarrow> a1 - (b + 1) < a2 - b"
 by arith

 have arith_less: "\<And>(a:: Nat.nat) b c. b \<ge> max (a + 1) c \<Longrightarrow> a < b"
 by arith

 have rbt_length: "\<And>rbt_cycle r v. RBT.lookup rbt_cycle r = None \<Longrightarrow>
     length (RBT.keys (RBT.insert r v rbt_cycle)) = length (RBT.keys rbt_cycle) + 1"
  apply(subst (1 2) distinct_card[symmetric], (rule distinct_keys)+)
  apply(simp only: lookup_keys[symmetric], simp)
 by (metis card_insert_if domIff finite_dom_lookup)

 have rbt_fold_union'': "\<And>ab a x k. dom (\<lambda>b. if b = ab then Some a else k b) = {ab} \<union> dom k"
 by(auto)

 have rbt_fold_union': "\<And>l rbt_inv a.
       dom (RBT.lookup (List.fold (\<lambda>(k, _). RBT.insert k a) l rbt_inv)) =
       dom (map_of l) \<union> dom (RBT.lookup rbt_inv)"
  apply(rule_tac P = "\<lambda>rbt_inv . dom (RBT.lookup (List.fold (\<lambda>(k, _). RBT.insert k a) l rbt_inv)) =
       dom (map_of l) \<union> dom (RBT.lookup rbt_inv)" in allE, simp_all)
  apply(induct_tac l, simp, rule allI)
  apply(case_tac aa, simp)
  apply(simp add: rbt_fold_union'')
 done

 have rbt_fold_union: "\<And>rbt_cycle rbt_inv a.
   dom (RBT.lookup (RBT.fold (\<lambda>k _. RBT.insert k a) rbt_cycle rbt_inv)) =
   dom (RBT.lookup rbt_cycle) \<union> dom (RBT.lookup rbt_inv)"
  apply(simp add: fold_fold)
  apply(subst (2) map_of_entries[symmetric])
  apply(rule rbt_fold_union')
 done

 have rbt_fold_eq: "\<And>rbt_cycle rbt_inv a b.
   dom (RBT.lookup (RBT.fold (\<lambda>k _. RBT.insert k a) rbt_cycle rbt_inv)) =
   dom (RBT.lookup (RBT.fold (\<lambda>k _. RBT.insert k b) rbt_inv rbt_cycle))"
 by(simp add: rbt_fold_union Un_commute)

 let ?len = "\<lambda>x. length (RBT.keys x)"
 let ?len_merge = "\<lambda>rbt_cycle rbt_inv. ?len (RBT.fold (\<lambda>k _. RBT.insert k []) rbt_cycle rbt_inv)"

 have rbt_fold_large: "\<And>rbt_cycle rbt_inv. ?len_merge rbt_cycle rbt_inv \<ge> max (?len rbt_cycle) (?len rbt_inv)"
  apply(subst (1 2 3) distinct_card[symmetric], (rule distinct_keys)+)
  apply(simp only: lookup_keys[symmetric], simp)
  apply(subst (1 2) card_mono, simp_all)
  apply(simp add: rbt_fold_union)+
 done

 have rbt_fold_eq: "\<And>rbt_cycle rbt_inv r a.
     RBT.lookup rbt_inv r = Some a \<Longrightarrow>
     ?len_merge (RBT.insert r () rbt_cycle) rbt_inv = ?len_merge rbt_cycle rbt_inv"
  apply(subst (1 2) distinct_card[symmetric], (rule distinct_keys)+)
  apply(simp only: lookup_keys[symmetric])
  apply(simp add: rbt_fold_union)
 by (metis Un_insert_right insert_dom)

 show ?thesis
  apply(relation "measure (\<lambda>(_, rbt_inv, rbt_cycle, _).
                           ?len_merge rbt_cycle rbt_inv - ?len rbt_cycle)"
       , simp+)
  unfolding RBTS.lookup_def RBTS.insert_def
  apply(subst rbt_length, simp)
  apply(rule arith_diff)
  apply(rule rbt_fold_eq, simp)
  apply(rule arith_less)
  apply(subst rbt_length[symmetric], simp)
  apply(rule rbt_fold_large)
 done
qed
definition "ty_obj_to_string = (\<lambda>OclTyObj (OclTyCore_pre s) _ \<Rightarrow> s)"
definition "cl_name_to_string = ty_obj_to_string o ClassRaw_name"

definition "normalize0 f l =
  rev (snd (List.fold (\<lambda>x (rbt, l).
                        let x0 = f x in
                        case RBT.lookup rbt x0 of
                          None \<Rightarrow> (RBT.insert x0 () rbt, x # l)
                        | Some _ \<Rightarrow> (rbt, l))
                      l
                      (RBT.empty, [])))"

definition "class_unflat = (\<lambda> (l_class, l_ass).
  let l =
    let const_oclany' = OclTyCore_pre const_oclany
      ; rbt = \<comment> \<open>fold classes:\<close>
              \<comment> \<open>set \<open>OclAny\<close> as default inherited class (for all classes linking to zero inherited classes)\<close>
              insert
                const_oclany
                (ocl_class_raw.make (OclTyObj const_oclany' []) [] [] False)
                (List.fold
                  (\<lambda> cflat \<Rightarrow>
                    insert (cl_name_to_string cflat) (cflat \<lparr> ClassRaw_name := case ClassRaw_name cflat of OclTyObj n [] \<Rightarrow> OclTyObj n [[const_oclany']] | x \<Rightarrow> x \<rparr>))
                  l_class
                  RBT.empty) in
    \<comment> \<open>fold associations:\<close>
    \<comment> \<open>add remaining 'object' attributes\<close>
    L.map snd (entries (List.fold (\<lambda> (ass_oid, ass) \<Rightarrow>
      case let (l_none, l_some) = List.partition (\<lambda>(_, m). TyRole m = None) (OclAss_relation' ass ) in
           L.flatten [l_none, normalize0 (\<lambda>(_, m). case TyRole m of Some s \<Rightarrow> String.to_list s) l_some] of
        [] \<Rightarrow> id
      | [_] \<Rightarrow> id
      | l_rel \<Rightarrow>
        fold_max
          (let n_rel = natural_of_nat (List.length l_rel) in
           (\<lambda> (cpt_to, (name_to, category_to)).
             case TyRole category_to of
               Some role_to \<Rightarrow>
                 List.fold (\<lambda> (cpt_from, (name_from, mult_from)).
                   let name_from = ty_obj_to_string name_from in
                   map_entry name_from (\<lambda>cflat. cflat \<lparr> ClassRaw_own := (role_to,
                     OclTy_class (ocl_ty_class_ext const_oid ass_oid n_rel
                       (ocl_ty_class_node_ext cpt_from mult_from name_from ())
                       (ocl_ty_class_node_ext cpt_to category_to (ty_obj_to_string name_to) ())
                       ())) # ClassRaw_own cflat \<rparr>))
             | _ \<Rightarrow> \<lambda>_. id))
        l_rel) (L.mapi Pair l_ass) rbt)) in
  class_unflat_aux
    (List.fold (\<lambda> cflat. insert (cl_name_to_string cflat)
                                (normalize0 (String.to_list o fst) (L.map (map_prod id remove_binding) (ClassRaw_own cflat))))
               l
               RBT.empty)
    (List.fold
      (\<lambda> cflat.
        case ClassRaw_name cflat of
          OclTyObj n [] \<Rightarrow> id
        | OclTyObj n l \<Rightarrow> case rev ([n] # l) of x0 # xs \<Rightarrow> \<lambda>rbt.
            snd (List.fold
                  (\<lambda> x (x0, rbt).
                    (x, List.fold (\<lambda> OclTyCore_pre k \<Rightarrow> modify_def [] k (\<lambda>l. L.flatten [L.map (\<lambda>OclTyCore_pre s \<Rightarrow> s) x, l]))
                                  x0
                                  rbt))
                  xs
                  (x0, rbt)))
      l
      RBT.empty)
    RBT.empty
    const_oclany)"

definition "class_unflat' x =
 (case class_unflat x of None \<Rightarrow> OclClass const_oclany [] []
                       | Some tree \<Rightarrow> tree)"

fun nb_class where
   "nb_class e = (\<lambda> OclClass _ _ l \<Rightarrow> Suc (List.fold ((+) o nb_class) l 0)) e"

definition "apply_optim_ass_arity ty_obj v =
  (if TyObj_ass_arity ty_obj \<le> 2 then None
   else Some v)"

definition "is_higher_order = (\<lambda> OclTy_collection _ _ \<Rightarrow> True | OclTy_pair _ _ \<Rightarrow> True | _ \<Rightarrow> False)"

definition "parse_ty_raw = (\<lambda> OclTy_raw s \<Rightarrow> if s = \<open>int\<close> then OclTy_base_integer else OclTy_raw s
                            | x \<Rightarrow> x)"

definition "is_sequence = list_ex (\<lambda> Sequence \<Rightarrow> True | _ \<Rightarrow> False) o TyCollect"

fun str_of_ty where "str_of_ty e =
 (\<lambda> OclTy_base_void \<Rightarrow> \<open>Void\<close>
  | OclTy_base_boolean \<Rightarrow> \<open>Boolean\<close>
  | OclTy_base_integer \<Rightarrow> \<open>Integer\<close>
  | OclTy_base_unlimitednatural \<Rightarrow> \<open>UnlimitedNatural\<close>
  | OclTy_base_real \<Rightarrow> \<open>Real\<close>
  | OclTy_base_string \<Rightarrow> \<open>String\<close>
  | OclTy_object (OclTyObj (OclTyCore_pre s) _) \<Rightarrow> s
  \<^cancel>\<open>| OclTy_object (OclTyObj (OclTyCore ty_obj) _)\<close>
  | OclTy_collection t ocl_ty \<Rightarrow> (if is_sequence t then
                                    S.flatten [\<open>Sequence(\<close>, str_of_ty ocl_ty,\<open>)\<close>]
                                  else
                                    S.flatten [\<open>Set(\<close>, str_of_ty ocl_ty,\<open>)\<close>])
  | OclTy_pair ocl_ty1 ocl_ty2 \<Rightarrow> S.flatten [\<open>Pair(\<close>, str_of_ty ocl_ty1, \<open>,\<close>, str_of_ty ocl_ty2,\<open>)\<close>]
  | OclTy_binding (_, ocl_ty) \<Rightarrow> str_of_ty ocl_ty
  | OclTy_class_syn s \<Rightarrow> s
  | OclTy_enum s \<Rightarrow> s
  | OclTy_raw s \<Rightarrow> S.flatten [\<open>\<acute>\<close>, s, \<open>\<acute>\<close>]) e"

definition "ty_void = str_of_ty OclTy_base_void"
definition "ty_boolean = str_of_ty OclTy_base_boolean"
definition "ty_integer = str_of_ty OclTy_base_integer"
definition "ty_unlimitednatural = str_of_ty OclTy_base_unlimitednatural"
definition "ty_real = str_of_ty OclTy_base_real"
definition "ty_string = str_of_ty OclTy_base_string"

definition "pref_ty_enum s = \<open>ty_enum\<close> @@ String.isub s"
definition "pref_ty_syn s = \<open>ty_syn\<close> @@ String.isub s"
definition "pref_constr_enum s = \<open>constr\<close> @@ String.isub s"

fun str_hol_of_ty_all where "str_hol_of_ty_all f b e =
 (\<lambda> OclTy_base_void \<Rightarrow> b \<open>unit\<close>
  | OclTy_base_boolean \<Rightarrow> b \<open>bool\<close>
  | OclTy_base_integer \<Rightarrow> b \<open>int\<close>
  | OclTy_base_unlimitednatural \<Rightarrow> b \<open>nat\<close>
  | OclTy_base_real \<Rightarrow> b \<open>real\<close>
  | OclTy_base_string \<Rightarrow> b \<open>string\<close>
  | OclTy_object (OclTyObj (OclTyCore_pre s) _) \<Rightarrow> b const_oid
  | OclTy_object (OclTyObj (OclTyCore ty_obj) _) \<Rightarrow> f (b var_ty_list) [b (TyObj_name ty_obj)]
  | OclTy_collection _ ty \<Rightarrow> f (b var_ty_list) [str_hol_of_ty_all f b ty]
  | OclTy_pair ty1 ty2 \<Rightarrow> f (b var_ty_prod) [str_hol_of_ty_all f b ty1, str_hol_of_ty_all f b ty2]
  | OclTy_binding (_, t) \<Rightarrow> str_hol_of_ty_all f b t
  | OclTy_class_syn s \<Rightarrow> b (pref_ty_syn s)
  | OclTy_enum s \<Rightarrow> b (pref_ty_enum s)
  | OclTy_raw s \<Rightarrow> b s) e"

definition "print_infra_type_synonym_class_set_name name = \<open>Set_\<close> @@ name"
definition "print_infra_type_synonym_class_sequence_name name = \<open>Sequence_\<close> @@ name"

fun get_class_hierarchy_strict_aux where
   "get_class_hierarchy_strict_aux dataty l_res =
   (List.fold
     (\<lambda> OclClass name l_attr dataty \<Rightarrow> \<lambda> l_res.
       get_class_hierarchy_strict_aux dataty (OclClass name l_attr dataty # l_res))
     dataty
     l_res)"
definition "get_class_hierarchy_strict d = get_class_hierarchy_strict_aux d []"

fun get_class_hierarchy'_aux where
   "get_class_hierarchy'_aux l_res (OclClass name l_attr dataty) =
   (let l_res = OclClass name l_attr dataty # l_res in
    case dataty of [] \<Rightarrow> rev l_res
                 | dataty \<Rightarrow> List.fold (\<lambda>x acc. get_class_hierarchy'_aux acc x) dataty l_res)"
definition "get_class_hierarchy' = get_class_hierarchy'_aux []"

definition "get_class_hierarchy e = L.map (\<lambda> OclClass n l _ \<Rightarrow> (n, l)) (get_class_hierarchy' e)"
definition "get_class_hierarchy_sub = (\<lambda> None \<Rightarrow> []
                                       | Some next_dataty \<Rightarrow> get_class_hierarchy next_dataty)"
definition "get_class_hierarchy_sub' = (\<lambda> None \<Rightarrow> []
                                        | Some next_dataty \<Rightarrow> get_class_hierarchy' next_dataty)"

datatype position = EQ \<comment> \<open>equal\<close> | LT \<comment> \<open>less\<close> | GT \<comment> \<open>greater\<close> | UN' \<comment> \<open>uncomparable\<close>

fun fold_less_gen where "fold_less_gen f_gen f_jump f l = (case l of
    x # xs \<Rightarrow> \<lambda>acc. fold_less_gen f_gen f_jump f xs (f_gen (f x) xs (f_jump acc))
  | [] \<Rightarrow> id)"

definition "fold_less2 = fold_less_gen List.fold"

section\<open>Translation of AST\<close>

definition "var_in_pre_state = \<open>in_pre_state\<close>"
definition "var_in_post_state = \<open>in_post_state\<close>"
definition "var_at_when_hol_post = \<open>\<close>"
definition "var_at_when_hol_pre = \<open>at_pre\<close>"
definition "var_at_when_ocl_post = \<open>\<close>"
definition "var_at_when_ocl_pre = \<open>@pre\<close>"

datatype 'a tmp_sub = Tsub 'a
record 'a inheritance =
  Inh :: 'a
  Inh_sib :: "('a \<times> 'a list \<comment> \<open>flat version of the 1st component\<close>) list" \<comment> \<open>sibling\<close>
  Inh_sib_unflat :: "'a list" \<comment> \<open>sibling\<close>
datatype 'a tmp_inh = Tinh 'a
datatype 'a tmp_univ = Tuniv 'a
definition "of_inh = (\<lambda>Tinh l \<Rightarrow> l)"
definition "of_linh = L.map Inh"
definition "of_linh_sib l = L.flatten (L.map snd (L.flatten (L.map Inh_sib l)))"
definition "of_sub = (\<lambda>Tsub l \<Rightarrow> l)"
definition "of_univ = (\<lambda>Tuniv l \<Rightarrow> l)"
definition "map_inh f = (\<lambda>Tinh l \<Rightarrow> Tinh (f l))"
definition "map_linh f cl = \<lparr> Inh = f (Inh cl)
                            , Inh_sib = L.map (map_prod f (L.map f)) (Inh_sib cl)
                            , Inh_sib_unflat = L.map f (Inh_sib_unflat cl) \<rparr>"

fun fold_class_gen_aux where
   "fold_class_gen_aux l_inh f accu (OclClass name l_attr dataty) =
 (let accu = f (\<lambda>s. s @@ String.isub name)
               name
               l_attr
               (Tinh l_inh)
               (Tsub (get_class_hierarchy_strict dataty)) \<comment> \<open>order: bfs or dfs (modulo reversing)\<close>
               dataty
               accu in
  case dataty of [] \<Rightarrow> accu
               | _ \<Rightarrow>
    fst (List.fold
       (\<lambda> node (accu, l_inh_l, l_inh_r).
         ( fold_class_gen_aux
             ( \<lparr> Inh = OclClass name l_attr dataty
               , Inh_sib = L.flatten (L.map (L.map (\<lambda>l. (l, get_class_hierarchy' l))) [l_inh_l, tl l_inh_r])
               , Inh_sib_unflat = L.flatten [l_inh_l, tl l_inh_r] \<rparr>
             # l_inh)
             f accu node
         , hd l_inh_r # l_inh_l
         , tl l_inh_r))
      dataty
      (accu, [], dataty)))"

definition "fold_class_gen f accu expr =
 (let (l_res, accu) =
    fold_class_gen_aux
      []
      (\<lambda> isub_name name l_attr l_inh l_subtree next_dataty (l_res, accu).
        let (r, accu) = f isub_name name l_attr l_inh l_subtree next_dataty accu in
        (r # l_res, accu))
      ([], accu)
      expr in
  (L.flatten l_res, accu))"

definition "map_class_gen f = fst o fold_class_gen
  (\<lambda> isub_name name l_attr l_inh l_subtree last_d. \<lambda> () \<Rightarrow>
    (f isub_name name l_attr l_inh l_subtree last_d, ())) ()"

definition "add_hierarchy f x = (\<lambda>isub_name name _ _ _ _. f isub_name name (Tuniv (L.map fst (get_class_hierarchy x))))"
definition "add_hierarchy' f x = (\<lambda>isub_name name _ _ _ _. f isub_name name (Tuniv (get_class_hierarchy x)))"
definition "add_hierarchy'' f x = (\<lambda>isub_name name l_attr _ _ _. f isub_name name (Tuniv (get_class_hierarchy x)) l_attr)"
definition "add_hierarchy''' f x = (\<lambda>isub_name name l_attr l_inh _ next_dataty. f isub_name name (Tuniv (get_class_hierarchy x)) l_attr (map_inh (L.map (\<lambda> OclClass _ l _ \<Rightarrow> l) o of_linh) l_inh) next_dataty)"
definition "add_hierarchy'''' f x = (\<lambda>isub_name name l_attr l_inh l_subtree _. f isub_name name (Tuniv (get_class_hierarchy x)) l_attr (map_inh (L.map (\<lambda> OclClass _ l _ \<Rightarrow> l) o of_linh) l_inh) l_subtree)"
definition "add_hierarchy''''' f = (\<lambda>isub_name name l_attr l_inh l_subtree. f isub_name name l_attr (of_inh l_inh) (of_sub l_subtree))"
definition "map_class f = map_class_gen (\<lambda>isub_name name l_attr l_inh l_subtree next_dataty. [f isub_name name l_attr l_inh (Tsub (L.map (\<lambda> OclClass n _ _ \<Rightarrow> n) (of_sub l_subtree))) next_dataty])"
definition "map_class' f = map_class_gen (\<lambda>isub_name name l_attr l_inh l_subtree next_dataty. [f isub_name name l_attr l_inh l_subtree next_dataty])"
definition "fold_class f = fold_class_gen (\<lambda>isub_name name l_attr l_inh l_subtree next_dataty accu. let (x, accu) = f isub_name name l_attr (map_inh of_linh l_inh) (Tsub (L.map (\<lambda> OclClass n _ _ \<Rightarrow> n) (of_sub l_subtree))) next_dataty accu in ([x], accu))"
definition "map_class_gen_h f x = map_class_gen (add_hierarchy f x) x"
definition "map_class_gen_h' f x = map_class_gen (add_hierarchy' f x) x"
definition "map_class_gen_h'' f x = map_class_gen (add_hierarchy'' f x) x"
definition "map_class_gen_h''' f x = map_class_gen (add_hierarchy''' f x) x"
definition "map_class_gen_h'''' f x = map_class_gen (add_hierarchy'''' (\<lambda>isub_name name l_inherited l_attr l_inh l_subtree. f isub_name name l_inherited l_attr l_inh (Tsub (L.map (\<lambda> OclClass n _ _ \<Rightarrow> n) (of_sub l_subtree)))) x) x"
definition "map_class_gen_h''''' f x = map_class_gen (add_hierarchy''''' f) x"
definition "map_class_h f x = map_class (add_hierarchy f x) x"
definition "map_class_h' f x = map_class (add_hierarchy' f x) x"
definition "map_class_h'' f x = map_class (add_hierarchy'' f x) x"
definition "map_class_h''' f x = map_class (add_hierarchy''' f x) x"
definition "map_class_h'''' f x = map_class (add_hierarchy'''' f x) x"
definition "map_class_h''''' f x = map_class' (add_hierarchy''''' f) x"
definition "map_class_arg_only f = map_class_gen (\<lambda> isub_name name l_attr _ _ _. case l_attr of [] \<Rightarrow> [] | l \<Rightarrow> f isub_name name l)"
definition "map_class_arg_only' f = map_class_gen (\<lambda> isub_name name l_attr l_inh l_subtree _.
  case filter (\<lambda> OclClass _ [] _ \<Rightarrow> False | _ \<Rightarrow> True) (of_linh (of_inh l_inh)) of
    [] \<Rightarrow> []
  | l \<Rightarrow> f isub_name name (l_attr, Tinh l, l_subtree))"
definition "map_class_arg_only0 f1 f2 u = map_class_arg_only f1 u @@@@ map_class_arg_only' f2 u"
definition "map_class_arg_only_var0 = (\<lambda>f_expr f_app f_lattr isub_name name l_attr.
  L.flatten (L.flatten (
    L.map (\<lambda>(var_in_when_state, dot_at_when, attr_when).
      L.flatten (L.map (\<lambda> l_attr. L.map (\<lambda>(attr_name, attr_ty).
        f_app
          isub_name
          name
          (var_in_when_state, dot_at_when)
          attr_ty
          (\<lambda>s. s @@ String.isup attr_name)
          (\<lambda>s. f_expr s
            [ case case attr_ty of
                     OclTy_object (OclTyObj (OclTyCore ty_obj) _) \<Rightarrow>
                       apply_optim_ass_arity ty_obj
                       (let ty_obj = TyObj_from ty_obj in
                       case TyObjN_role_name ty_obj of
                          None => String.natural_to_digit10 (TyObjN_ass_switch ty_obj)
                        | Some s => s)
                   | _ \<Rightarrow> None of
                None \<Rightarrow> mk_dot attr_name attr_when
              | Some s2 \<Rightarrow> mk_dot_comment attr_name attr_when s2 ])) l_attr)
     (f_lattr l_attr)))
   [ (var_in_post_state, var_at_when_hol_post, var_at_when_ocl_post)
   , (var_in_pre_state, var_at_when_hol_pre, var_at_when_ocl_pre)])))"
definition "map_class_arg_only_var_gen f_expr f1 f2 = map_class_arg_only0 (map_class_arg_only_var0 f_expr f1 (\<lambda>l. [l])) (map_class_arg_only_var0 f_expr f2 (\<lambda> (_, Tinh l, _) \<Rightarrow> L.map (\<lambda> OclClass _ l _ \<Rightarrow> l) l))"
definition "map_class_arg_only_var'_gen f_expr f = map_class_arg_only0 (map_class_arg_only_var0 f_expr f (\<lambda>l. [l])) (map_class_arg_only_var0 f_expr f (\<lambda> (_, Tinh l, _) \<Rightarrow> L.map (\<lambda> OclClass _ l _ \<Rightarrow> l) l))"
definition "map_class_arg_only_var''_gen f_expr f = map_class_arg_only (map_class_arg_only_var0 f_expr f (\<lambda>l. [l]))"
definition "map_class_one f_l f expr =
  (case f_l (fst (fold_class (\<lambda>isub_name name l_attr l_inh l_inh_sib next_dataty _. ((isub_name, name, l_attr, l_inh, l_inh_sib, next_dataty), ())) () expr)) of
     (isub_name, name, l_attr, l_inh, l_inh_sib, next_dataty) # _ \<Rightarrow>
     f isub_name name l_attr l_inh l_inh_sib next_dataty)"
definition "map_class_top = map_class_one rev"
definition "get_hierarchy_map f f_l x = L.flatten (L.flatten (
  let (l1, l2, l3) = f_l (L.map fst (get_class_hierarchy x)) in
  L.map (\<lambda>name1. L.map (\<lambda>name2. L.map (f name1 name2) l3) l2) l1))"

definition "class_arity = RBT.keys o (\<lambda>l. List.fold (\<lambda>x. RBT.insert x ()) l RBT.empty) o
  L.flatten o L.flatten o map_class (\<lambda> _ _ l_attr _ _ _.
    L.map (\<lambda> (_, OclTy_object (OclTyObj (OclTyCore ty_obj) _)) \<Rightarrow> [TyObj_ass_arity ty_obj]
              | _ \<Rightarrow> []) l_attr)"

definition "map_class_gen_h'_inh f =
  map_class_gen_h''''' (\<lambda>isub_name name _ l_inh l_subtree _.
    let l_mem = \<lambda>l. List.member (L.map (\<lambda> OclClass n _ _ \<Rightarrow> String.to_list n) l) in
    f isub_name
      name
      (\<lambda>n. let n = String.to_list n in
           if \<comment> \<open>TODO use \<^term>\<open>(\<triangleq>)\<close>\<close> n = String.to_list name then EQ else
           if l_mem (of_linh l_inh) n then GT else
           if l_mem l_subtree n then LT else
           UN'))"

definition "m_class_gen2 base_attr f print =
 (let m_base_attr = \<lambda> OclClass n l b \<Rightarrow> OclClass n (base_attr l) b
    ; f_base_attr = L.map m_base_attr in
  map_class_gen_h''''' (\<lambda>isub_name name nl_attr l_inh l_subtree next_dataty.
    f name
      l_inh
      l_subtree
      (L.flatten (L.flatten (L.map (
        let print_astype =
              print
                (L.map (map_linh m_base_attr) l_inh)
                (f_base_attr l_subtree)
                next_dataty
          ; nl_attr = base_attr nl_attr in
        (\<lambda>(l_hierarchy, l).
          L.map
            (print_astype l_hierarchy (isub_name, name, nl_attr) o m_base_attr)
            l))
        [ (EQ, [OclClass name nl_attr next_dataty])
        , (GT, of_linh l_inh)
        , (LT, l_subtree)
        , (UN', of_linh_sib l_inh) ])))))"

definition "f_less2 =
  (\<lambda>f l. rev (fst (fold_less2 (\<lambda>(l, _). (l, None)) (\<lambda>x y (l, acc). (f x y acc # l, Some y)) l ([], None))))
    (\<lambda>a b _. (a,b))"

definition "m_class_gen3_GE base_attr f print =
 (let m_base_attr = \<lambda> OclClass n l b \<Rightarrow> OclClass n (base_attr l) b
    ; f_base_attr = L.map m_base_attr in
  map_class_gen_h''''' (\<lambda>isub_name name nl_attr l_inh l_subtree next_dataty.
    let print_astype =
         print
           (L.map (map_linh m_base_attr) l_inh)
           (f_base_attr l_subtree)
           next_dataty in
    L.flatten
      [ f (L.flatten (L.map (\<lambda> (l_hierarchy, l).
          L.map (\<lambda> OclClass h_name _ _ \<Rightarrow> print_astype name h_name h_name) l)
          [ (GT, of_linh l_inh) ]))
      , f (L.flatten (L.map (\<lambda> (l_hierarchy, l).
          L.map (\<lambda> (h_name, hh_name). print_astype name h_name hh_name) (f_less2 (L.map (\<lambda> OclClass n _ _ \<Rightarrow> n) l)))
          [ (GT, of_linh l_inh) ]))
      , f (L.flatten (L.map (\<lambda> (l_hierarchy, l).
          L.flatten (L.map (\<lambda> OclClass h_name _ _ \<Rightarrow>
            L.map (\<lambda> OclClass sib_name _ _ \<Rightarrow> print_astype name sib_name h_name) (of_linh_sib l_inh)) l))
          [ (GT, of_linh l_inh) ])) ]))"

definition "m_class_gen3 base_attr f print =
 (let m_base_attr = \<lambda> OclClass n l b \<Rightarrow> OclClass n (base_attr l) b
    ; f_base_attr = L.map m_base_attr in
  map_class_gen_h''''' (\<lambda>isub_name name nl_attr l_inh l_subtree next_dataty.
    let print_astype =
         print
           (L.map (map_linh m_base_attr) l_inh)
           (f_base_attr l_subtree)
           next_dataty in
    f (L.flatten (
        let l_tree = L.map (\<lambda>(cmp,l). (cmp, f_base_attr l))
          [ (EQ, [OclClass name nl_attr next_dataty])
          , (GT, of_linh l_inh)
          , (LT, l_subtree)
          , (UN', of_linh_sib l_inh) ] in
        (\<lambda>f. L.flatten (L.map (\<lambda> (l_hierarchy, l). L.map (f l_hierarchy) l) l_tree))
        (\<lambda> l_hierarchy1. \<lambda> OclClass h_name hl_attr hb \<Rightarrow>
        (\<lambda>f. L.flatten (L.map (\<lambda> (l_hierarchy, l). L.map (f l_hierarchy) l) l_tree))
        (\<lambda> l_hierarchy2. \<lambda> OclClass hh_name hhl_attr hhb \<Rightarrow>
          print_astype
            name
            h_name
            hh_name))))))"

definition "m_class_default = (\<lambda>_ _ _. id)"
definition "m_class base_attr f print = m_class_gen2 base_attr f (\<lambda>_ _ _. print)"
definition "m_class3_GE base_attr f print = m_class_gen3_GE base_attr f (\<lambda>_ _ _. print)"
definition "m_class' base_attr print =
  m_class base_attr m_class_default (\<lambda> l_hierarchy x0 x1. [ print l_hierarchy x0 x1 ])"

definition "map_class_nupl2'_inh f = List.map_filter id o
 (m_class' id (\<lambda>compare (_, name, _). \<lambda> OclClass h_name _ _ \<Rightarrow>
    if compare = GT then Some (f name h_name) else None))"

definition "map_class_nupl2'_inh_large f = List.map_filter id o
 (m_class' id (\<lambda>compare (_, name, _). \<lambda> OclClass h_name _ _ \<Rightarrow>
    if compare = GT
     | compare = UN' then Some (f name h_name) else None))"

definition "map_class_nupl2''_inh f = List.map_filter id o
 (m_class_gen2 id m_class_default (\<lambda> l_inh _ _ compare (_, name, _). \<lambda> OclClass h_name _ h_subtree \<Rightarrow>
    [ if compare = GT then
        Some (f name h_name (L.map (\<lambda>x. (x, List.member (of_linh l_inh) x)) h_subtree))
      else
        None]))"

definition "map_class_nupl2l'_inh_gen f = List.map_filter id o
 (m_class_gen2 id m_class_default (\<lambda> l_inh l_subtree _ compare (_, name, _). \<lambda> OclClass h_name _ _ \<Rightarrow>
    [ if compare = GT then
        Some (f l_subtree name (fst (List.fold (\<lambda>x. \<lambda> (l, True, prev_x) \<Rightarrow> (l, True, prev_x)
                                          | (l, False, prev_x) \<Rightarrow>
                                              case Inh x of OclClass n _ next_d \<Rightarrow>
                                              ( (x, L.map (\<lambda> OclClass n l next_d \<Rightarrow>
                                                               (OclClass n l next_d, n = prev_x))
                                                             next_d)
                                                # l
                                              , n = h_name
                                              , n))
                                     l_inh
                                     ([], False, name))))
      else
        None]))"

definition "map_class_nupl2l'_inh f = map_class_nupl2l'_inh_gen (\<lambda>_ x l. f x l)"

definition "map_class_nupl3'_LE'_inh f = L.flatten o map_class_nupl2l'_inh_gen (\<lambda>l_subtree x l.
  L.map
    (\<lambda>name_bot. f name_bot x l)
    (x # L.map (\<lambda> OclClass n _ _ \<Rightarrow> n) l_subtree))"

definition "map_class_nupl3'_GE_inh = m_class3_GE id id"

definition "map_class_inh l_inherited = L.map (\<lambda> OclClass _ l _ \<Rightarrow> l) (of_inh (map_inh of_linh l_inherited))"

definition "find_inh name class =
 (case fold_class
    (\<lambda>_ name0 _ l_inh _ _ accu.
      Pair () (if accu = None & name \<triangleq> name0 then
                 Some (L.map (\<lambda>OclClass n _ _ \<Rightarrow> n) (of_inh l_inh))
               else
                 accu))
    None
    class
  of (_, Some l) \<Rightarrow> l)"

end
