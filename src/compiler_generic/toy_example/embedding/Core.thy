(*****************************************************************************
 * A Meta-Model for the Isabelle API
 *
 * Copyright (c) 2013-2015 Université Paris-Saclay, Univ Paris Sud, France
 *               2013-2015 IRT SystemX, France
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
(* $Id:$ *)

section{* General Environment for the Translation: Conclusion *}

theory  Core
imports "core/Floor1_infra"
        "core/Floor1_access"
        "core/Floor1_examp"
        "core/Floor2_examp"
        "core/Floor1_ctxt"
begin

subsection{* Preliminaries *}

datatype ('a, 'b) hol_theory = Hol_theory_ext "('a \<Rightarrow> 'b \<Rightarrow> META_Isabelle list \<times> 'b) list"
                             | Hol_theory_locale "'a \<Rightarrow> 'b \<Rightarrow> semi__locale \<times> 'b"
                                                 "('a \<Rightarrow> 'b \<Rightarrow> semi__t list \<times> 'b) list"

type_synonym 'a h_theory = "('a, compiler_env_config) hol_theory" (* polymorphism weakening needed by code_reflect *)

definition "L_fold f =
 (\<lambda> Hol_theory_ext l \<Rightarrow> List.fold f l
  | Hol_theory_locale loc_data l \<Rightarrow>
      f (\<lambda>a b.
          let (loc_data, b) = loc_data a b
            ; (l, b) = List.fold (\<lambda>f0. \<lambda>(l, b) \<Rightarrow> let (x, b) = f0 a b in (x # l, b)) l ([], b) in
          ([Isab_thy (H_thy_locale loc_data (rev l))], b)))"

subsection{* Assembling Translations *}

definition' thy_class ::
  (* polymorphism weakening needed by code_reflect *)
  "_ h_theory" where \<open>thy_class =
  Hol_theory_ext
          [ print_infra_datatype_class
          , print_infra_datatype_universe
          , print_infra_type_synonym_class_higher
          , print_access_oid_uniq
          , print_access_choose ]\<close>

definition "thy_enum_flat = Hol_theory_ext []"
definition "thy_enum = Hol_theory_ext []"
definition "thy_class_synonym = Hol_theory_ext []"
definition "thy_class_flat = Hol_theory_ext []"
definition "thy_association = Hol_theory_ext []"
definition "thy_instance = Hol_theory_ext 
                             [ print_examp_instance_defassoc
                             , print_examp_instance ]"
definition "thy_def_base_l = Hol_theory_ext []"
definition "thy_def_state = (\<lambda> Floor1 \<Rightarrow> Hol_theory_ext 
                                           [ Floor1_examp.print_examp_def_st1 ]
                             | Floor2 \<Rightarrow> Hol_theory_locale
                                           Floor2_examp.print_examp_def_st_locale
                                           [ Floor2_examp.print_examp_def_st2
                                           , Floor2_examp.print_examp_def_st_perm ])"
definition "thy_def_pre_post = (\<lambda> Floor1 \<Rightarrow> Hol_theory_ext 
                                              [ Floor1_examp.print_pre_post ]
                                | Floor2 \<Rightarrow> Hol_theory_locale
                                              Floor2_examp.print_pre_post_locale
                                              [ Floor2_examp.print_pre_post_interp ])"
definition "thy_ctxt = (\<lambda> Floor1 \<Rightarrow> Hol_theory_ext 
                                      [ Floor1_ctxt.print_ctxt ]
                        | Floor2 \<Rightarrow> Hol_theory_ext 
                                      [])"
definition "thy_flush_all = Hol_theory_ext []"
(* NOTE typechecking functions can be put at the end, however checking already defined constants can be done earlier *)

subsection{* Combinators Folding the Compiling Environment *}

definition "compiler_env_config_empty output_disable_thy output_header_thy oid_start design_analysis sorry_dirty =
  compiler_env_config.make
    output_disable_thy
    output_header_thy
    oid_start
    (0, 0)
    design_analysis
    None [] [] [] False False ([], []) []
    sorry_dirty"

definition "compiler_env_config_reset_no_env env =
  compiler_env_config_empty
    (D_output_disable_thy env)
    (D_output_header_thy env)
    (oidReinitAll (D_ocl_oid_start env))
    (D_ocl_semantics env)
    (D_output_sorry_dirty env)
    \<lparr> D_input_meta := D_input_meta env \<rparr>"

definition "compiler_env_config_reset_all env =
  (let env = compiler_env_config_reset_no_env env in
   ( env \<lparr> D_input_meta := [] \<rparr>
   , let (l_class, l_env) = find_class_ass env in
     L.flatten
       [ l_class
       , List.filter (\<lambda> META_flush_all _ \<Rightarrow> False | _ \<Rightarrow> True) l_env
       , [META_flush_all OclFlushAll] ] ))"

definition "compiler_env_config_update f env =
  (* WARNING The semantics of the meta-embedded language is not intended to be reset here (like oid_start), only syntactic configurations of the compiler (path, etc...) *)
  f env
    \<lparr> D_output_disable_thy := D_output_disable_thy env
    , D_output_header_thy := D_output_header_thy env
    , D_ocl_semantics := D_ocl_semantics env
    , D_output_sorry_dirty := D_output_sorry_dirty env \<rparr>"

definition "fold_thy0 meta thy_object0 f =
  L_fold (\<lambda>x (acc1, acc2).
    let (sorry, dirty) = D_output_sorry_dirty acc1
      ; (l, acc1) = x meta acc1 in
    (f (if sorry = Some Gen_sorry | sorry = None & dirty then
          L.map (hol_map_thy (hol_map_lemma (\<lambda> Lemma n spec _ _ \<Rightarrow> Lemma n spec [] C.sorry
                                                | Lemma_assumes n spec1 spec2 _ _ \<Rightarrow> Lemma_assumes n spec1 spec2 [] C.sorry))) l
        else
          l) acc1 acc2)) thy_object0"

definition "comp_env_input_class_rm f_fold f env_accu =
  (let (env, accu) = f_fold f env_accu in
   (env \<lparr> D_input_class := None \<rparr>, accu))"

definition "comp_env_save ast f_fold f env_accu =
  (let (env, accu) = f_fold f env_accu in
   (env \<lparr> D_input_meta := ast # D_input_meta env \<rparr>, accu))"

definition "comp_env_input_class_mk f_try f_accu_reset f_fold f =
  (\<lambda> (env, accu).
    f_fold f
      (case D_input_class env of Some _ \<Rightarrow> (env, accu) | None \<Rightarrow>
       let (l_class, l_env) = find_class_ass env
         ; (l_enum, l_env) = partition (\<lambda>META_enum _ \<Rightarrow> True | _ \<Rightarrow> False) l_env in
       (f_try (\<lambda> () \<Rightarrow>
         let D_input_meta0 = D_input_meta env
           ; (env, accu) =
               let meta = class_unflat (arrange_ass True (D_ocl_semantics env \<noteq> Gen_default) l_class (L.map (\<lambda> META_enum e \<Rightarrow> e) l_enum))
                 ; (env, accu) = List.fold (\<lambda> ast. comp_env_save ast (case ast of META_enum meta \<Rightarrow> fold_thy0 meta thy_enum) f)
                                           l_enum
                                           (let env = compiler_env_config_reset_no_env env in
                                            (env \<lparr> D_input_meta := List.filter (\<lambda> META_enum _ \<Rightarrow> False | _ \<Rightarrow> True) (D_input_meta env) \<rparr>, f_accu_reset env accu))
                 ; (env, accu) = fold_thy0 meta thy_class f (env, accu) in
               (env \<lparr> D_input_class := Some meta \<rparr>, accu)
           ; (env, accu) =
               List.fold
                 (\<lambda>ast. comp_env_save ast (case ast of
                     META_instance meta \<Rightarrow> fold_thy0 meta thy_instance
                   | META_def_base_l meta \<Rightarrow> fold_thy0 meta thy_def_base_l
                   | META_def_state floor meta \<Rightarrow> fold_thy0 meta (thy_def_state floor)
                   | META_def_pre_post floor meta \<Rightarrow> fold_thy0 meta (thy_def_pre_post floor)
                   | META_ctxt floor meta \<Rightarrow> fold_thy0 meta (thy_ctxt floor)
                   | META_flush_all meta \<Rightarrow> fold_thy0 meta thy_flush_all)
                        f)
                 l_env
                 (env \<lparr> D_input_meta := L.flatten [l_class, l_enum] \<rparr>, accu) in
          (env \<lparr> D_input_meta := D_input_meta0 \<rparr>, accu)))))"

definition "comp_env_input_class_bind l f =
  List.fold (\<lambda>x. x f) l"

definition "fold_thy' f_try f_accu_reset f =
 (let comp_env_input_class_mk = comp_env_input_class_mk f_try f_accu_reset in
  List.fold (\<lambda> ast.
    comp_env_save ast (case ast of
     META_enum meta \<Rightarrow> comp_env_input_class_rm (fold_thy0 meta thy_enum_flat)
   | META_class_raw Floor1 meta \<Rightarrow> comp_env_input_class_rm (fold_thy0 meta thy_class_flat)
   | META_association meta \<Rightarrow> comp_env_input_class_rm (fold_thy0 meta thy_association)
   | META_ass_class Floor1 (OclAssClass meta_ass meta_class) \<Rightarrow>
       comp_env_input_class_rm (comp_env_input_class_bind [ fold_thy0 meta_ass thy_association
                                                      , fold_thy0 meta_class thy_class_flat ])
   | META_class_synonym meta \<Rightarrow> comp_env_input_class_rm (fold_thy0 meta thy_class_synonym)
   | META_instance meta \<Rightarrow> comp_env_input_class_mk (fold_thy0 meta thy_instance)
   | META_def_base_l meta \<Rightarrow> fold_thy0 meta thy_def_base_l
   | META_def_state floor meta \<Rightarrow> comp_env_input_class_mk (fold_thy0 meta (thy_def_state floor))
   | META_def_pre_post floor meta \<Rightarrow> fold_thy0 meta (thy_def_pre_post floor)
   | META_ctxt floor meta \<Rightarrow> comp_env_input_class_mk (fold_thy0 meta (thy_ctxt floor))
   | META_flush_all meta \<Rightarrow> comp_env_input_class_mk (fold_thy0 meta thy_flush_all)) f))"

definition "fold_thy_shallow f_try f_accu_reset x = 
  fold_thy'
    f_try
    f_accu_reset
    (\<lambda>l acc1.
      map_prod (\<lambda> env. env \<lparr> D_input_meta := D_input_meta acc1 \<rparr>) id
      o List.fold x l
      o Pair acc1)"

definition "fold_thy_deep obj env =
  (case fold_thy'
          (\<lambda>f. f ())
          (\<lambda>env _. D_output_position env)
          (\<lambda>l acc1 (i, cpt). (acc1, (Succ i, natural_of_nat (List.length l) + cpt)))
          obj
          (env, D_output_position env) of
    (env, output_position) \<Rightarrow> env \<lparr> D_output_position := output_position \<rparr>)"

end
