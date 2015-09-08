(*****************************************************************************
 * A Meta-Model for the Isabelle API
 *
 * Copyright (c) 2013-2015 Université Paris-Sud, France
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

section{* Instantiating the Printer for Isabelle *}

theory  Printer_Isabelle
imports Meta_Isabelle
        Printer_Pure
        Printer_SML
begin

context s_of
begin
fun s_of_rawty where "s_of_rawty e = (\<lambda>
    Ty_base s \<Rightarrow> To_string s
  | Ty_apply name l \<Rightarrow> sprint2 \<open>%s %s\<close>\<acute> (let s = String_concat \<open>, \<close> (List.map s_of_rawty l) in
                                                 case l of [_] \<Rightarrow> s | _ \<Rightarrow> sprint1 \<open>(%s)\<close>\<acute> s)
                                                (s_of_rawty name)
  | Ty_apply_bin s ty1 ty2 \<Rightarrow> sprint3 \<open>%s %s %s\<close>\<acute> (s_of_rawty ty1) (To_string s) (s_of_rawty ty2)
  | Ty_apply_paren s1 s2 ty \<Rightarrow> sprint3 \<open>%s%s%s\<close>\<acute> (To_string s1) (s_of_rawty ty) (To_string s2)) e"

definition "s_of_dataty _ = (\<lambda> Datatype n l \<Rightarrow>
  sprint2 \<open>datatype %s = %s\<close>\<acute>
    (To_string n)
    (String_concat \<open>
                        | \<close>
      (L.map
        (\<lambda>(n,l).
         sprint2 \<open>%s %s\<close>\<acute>
           (To_string n)
           (String_concat \<open> \<close> (L.map (\<lambda>x. sprint1 \<open>\"%s\"\<close>\<acute> (s_of_rawty x)) l))) l) ))"

definition "s_of_ty_synonym _ = (\<lambda> Type_synonym n v l \<Rightarrow>
    sprint2 \<open>type_synonym %s = \"%s\"\<close>\<acute> (if v = [] then 
                                           To_string n
                                         else
                                           s_of_rawty (Ty_apply (Ty_base n) (L.map Ty_base v)))
                                        (s_of_rawty l))"

fun s_of_expr where "s_of_expr e = (\<lambda>
    Expr_rewrite e1 symb e2 \<Rightarrow> sprint3 \<open>%s %s %s\<close>\<acute> (s_of_expr e1) (To_string symb) (s_of_expr e2)
  | Expr_basic l \<Rightarrow> sprint1 \<open>%s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
  | Expr_oid tit s \<Rightarrow> sprint2 \<open>%s%d\<close>\<acute> (To_string tit) (To_oid s)
  | Expr_annot e s \<Rightarrow> sprint2 \<open>(%s::%s)\<close>\<acute> (s_of_expr e) (s_of_rawty s)
  | Expr_bind symb e1 e2 \<Rightarrow> sprint3 \<open>(%s%s. %s)\<close>\<acute> (To_string symb) (s_of_expr e1) (s_of_expr e2)
  | Expr_fun_case e_case l \<Rightarrow> sprint2 \<open>(%s %s)\<close>\<acute>
      (case e_case of None \<Rightarrow> \<open>\<lambda>\<close>
                    | Some e \<Rightarrow> sprint1 \<open>case %s of\<close>\<acute> (s_of_expr e))
      (String_concat \<open>
    | \<close> (List.map (\<lambda> (s1, s2) \<Rightarrow> sprint2 \<open>%s \<Rightarrow> %s\<close>\<acute> (s_of_expr s1) (s_of_expr s2)) l))
  | Expr_apply e l \<Rightarrow> sprint2 \<open>%s %s\<close>\<acute> (s_of_expr e) (String_concat \<open> \<close> (List.map (\<lambda> e \<Rightarrow> sprint1 \<open>%s\<close>\<acute> (s_of_expr e)) l))
  | Expr_paren p_left p_right e \<Rightarrow> sprint3 \<open>%s%s%s\<close>\<acute> (To_string p_left) (s_of_expr e) (To_string p_right)
  | Expr_if_then_else e_if e_then e_else \<Rightarrow> sprint3 \<open>if %s then %s else %s\<close>\<acute> (s_of_expr e_if) (s_of_expr e_then) (s_of_expr e_else)
  | Expr_pure l pure \<Rightarrow> s_of_pure_term (L.map To_string l) pure) e"

definition "s_of_ty_notation _ = (\<lambda> Type_notation n e \<Rightarrow>
    sprint2 \<open>type_notation %s (\"%s\")\<close>\<acute> (To_string n) (To_string e))"

definition "s_of_instantiation_class _ = (\<lambda> Instantiation n n_def expr \<Rightarrow>
    let name = To_string n in
    sprint4 \<open>instantiation %s :: object
begin
  definition %s_%s_def : \"%s\"
  instance ..
end\<close>\<acute>
      name
      (To_string n_def)
      name
      (s_of_expr expr))"

definition "s_of_defs_overloaded _ = (\<lambda> Defs_overloaded n e \<Rightarrow>
    sprint2 \<open>defs(overloaded) %s : \"%s\"\<close>\<acute> (To_string n) (s_of_expr e))"

definition "s_of_consts_class _ = (\<lambda> Consts n ty symb \<Rightarrow>
    sprint4 \<open>consts %s :: \"%s\" (\"%s %s\")\<close>\<acute> (To_string n) (s_of_rawty ty) (To_string Consts_value) (To_string symb))"

definition "s_of_definition_hol _ = (\<lambda>
    Definition e \<Rightarrow> sprint1 \<open>definition \"%s\"\<close>\<acute> (s_of_expr e)
  | Definition_where1 name (abbrev, prio) e \<Rightarrow> sprint4 \<open>definition %s (\"(1%s)\" %d)
  where \"%s\"\<close>\<acute> (To_string name) (s_of_expr abbrev) (To_nat prio) (s_of_expr e)
  | Definition_where2 name abbrev e \<Rightarrow> sprint3 \<open>definition %s (\"%s\")
  where \"%s\"\<close>\<acute> (To_string name) (s_of_expr abbrev) (s_of_expr e))"

definition "(s_of_ntheorem_aux_gen :: String.literal \<times> String.literal \<Rightarrow> _ \<Rightarrow> _ \<Rightarrow> _) m lacc s = 
 (let s_base = (\<lambda>s lacc. sprint2 \<open>%s[%s]\<close>\<acute> (To_string s) (String_concat \<open>, \<close> (L.map (\<lambda>(s, x). sprint2 \<open>%s %s\<close>\<acute> s x) lacc))) in
  s_base s (m # lacc))"

definition "s_of_ntheorem_aux_gen_where l = 
 (\<open>where\<close>, String_concat \<open> and \<close> (L.map (\<lambda>(var, expr). sprint2 \<open>%s = \"%s\"\<close>\<acute>
                                                            (To_string var)
                                                            (s_of_expr expr)) l))"

definition "s_of_ntheorem_aux_gen_of l =
 (\<open>of\<close>, String_concat \<open> \<close> (L.map (\<lambda>expr. sprint1 \<open>\"%s\"\<close>\<acute> (s_of_expr expr)) l))"

fun s_of_ntheorem_aux where "s_of_ntheorem_aux lacc e =
  ((* FIXME regroup all the 'let' declarations at the beginning *)
   (*let f_where = (\<lambda>l. (\<open>where\<close>, String_concat \<open> and \<close>
                                        (L.map (\<lambda>(var, expr). sprint2 \<open>%s = \"%s\"\<close>\<acute>
                                                        (To_string var)
                                                        (s_of_expr expr)) l)))
     ; f_of = (\<lambda>l. (\<open>of\<close>, String_concat \<open> \<close>
                                  (L.map (\<lambda>expr. sprint1 \<open>\"%s\"\<close>\<acute>
                                                        (s_of_expr expr)) l)))
     ; f_symmetric = (\<open>symmetric\<close>, \<open>\<close>)
     ; s_base = (\<lambda>s lacc. sprint2 \<open>%s[%s]\<close>\<acute> (To_string s) (String_concat \<open>, \<close> (L.map (\<lambda>(s, x). sprint2 \<open>%s %s\<close>\<acute> s x) lacc))) in
   *)\<lambda> Thm_thm s \<Rightarrow> To_string s
   | Thm_thms s \<Rightarrow> To_string s

   | Thm_THEN (Thm_thm s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>THEN\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_THEN (Thm_thms s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>THEN\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_THEN e1 e2 \<Rightarrow> s_of_ntheorem_aux ((\<open>THEN\<close>, s_of_ntheorem_aux [] e2) # lacc) e1

   | Thm_simplified (Thm_thm s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>simplified\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_simplified (Thm_thms s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>simplified\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_simplified e1 e2 \<Rightarrow> s_of_ntheorem_aux ((\<open>simplified\<close>, s_of_ntheorem_aux [] e2) # lacc) e1

   | Thm_symmetric (Thm_thm s) \<Rightarrow> s_of_ntheorem_aux_gen (\<open>symmetric\<close>, \<open>\<close>) lacc s 
   | Thm_symmetric (Thm_thms s) \<Rightarrow> s_of_ntheorem_aux_gen (\<open>symmetric\<close>, \<open>\<close>) lacc s
   | Thm_symmetric e1 \<Rightarrow> s_of_ntheorem_aux ((\<open>symmetric\<close>, \<open>\<close>) # lacc) e1

   | Thm_where (Thm_thm s) l \<Rightarrow> s_of_ntheorem_aux_gen (s_of_ntheorem_aux_gen_where l) lacc s
   | Thm_where (Thm_thms s) l \<Rightarrow> s_of_ntheorem_aux_gen (s_of_ntheorem_aux_gen_where l) lacc s
   | Thm_where e1 l \<Rightarrow> s_of_ntheorem_aux (s_of_ntheorem_aux_gen_where l # lacc) e1

   | Thm_of (Thm_thm s) l \<Rightarrow> s_of_ntheorem_aux_gen (s_of_ntheorem_aux_gen_of l) lacc s
   | Thm_of (Thm_thms s) l \<Rightarrow> s_of_ntheorem_aux_gen (s_of_ntheorem_aux_gen_of l) lacc s
   | Thm_of e1 l \<Rightarrow> s_of_ntheorem_aux (s_of_ntheorem_aux_gen_of l # lacc) e1

   | Thm_OF (Thm_thm s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>OF\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_OF (Thm_thms s) e2 \<Rightarrow> s_of_ntheorem_aux_gen (\<open>OF\<close>, s_of_ntheorem_aux [] e2) lacc s
   | Thm_OF e1 e2 \<Rightarrow> s_of_ntheorem_aux ((\<open>OF\<close>, s_of_ntheorem_aux [] e2) # lacc) e1) e"

definition "s_of_ntheorem = s_of_ntheorem_aux []"

definition "s_of_ntheorems = (\<lambda> Thms_single thy \<Rightarrow> s_of_ntheorem thy
                              | Thms_mult thy \<Rightarrow> s_of_ntheorem thy)"

definition "s_of_ntheorem_l l = String_concat \<open>
                            \<close> (L.map s_of_ntheorem l)"
definition "s_of_ntheorem_l1 l = String_concat \<open> \<close> (L.map s_of_ntheorem l)"

definition "s_of_ntheorems_l l = String_concat \<open> \<close> (L.map s_of_ntheorems l)"

definition "s_of_lemmas_simp _ = (\<lambda> Lemmas_simp_thm simp s l \<Rightarrow>
    sprint3 \<open>lemmas%s%s = %s\<close>\<acute>
      (if String.is_empty s then \<open>\<close> else sprint1 \<open> %s\<close>\<acute> (To_string s))
      (if simp then \<open>[simp,code_unfold]\<close> else \<open>\<close>)
      (s_of_ntheorem_l l)
                                  | Lemmas_simp_thms s l \<Rightarrow>
    sprint2 \<open>lemmas%s [simp,code_unfold] = %s\<close>\<acute>
      (if String.is_empty s then \<open>\<close> else sprint1 \<open> %s\<close>\<acute> (To_string s))
      (String_concat \<open>
                            \<close> (L.map To_string l)))"

definition "(s_of_attrib_genA :: (hol__thm list \<Rightarrow> String.literal)
   \<Rightarrow> String.literal \<Rightarrow> hol__thm list \<Rightarrow> String.literal) f attr l = (* error reflection: to be merged *)
 (if l = [] then
    \<open>\<close>
  else
    sprint2 \<open> %s: %s\<close>\<acute> attr (f l))"

definition "(s_of_attrib_genB :: (string list \<Rightarrow> String.literal)
   \<Rightarrow> String.literal \<Rightarrow> string list \<Rightarrow> String.literal) f attr l = (* error reflection: to be merged *)
 (if l = [] then
    \<open>\<close>
  else
    sprint2 \<open> %s: %s\<close>\<acute> attr (f l))"

definition "s_of_attrib = s_of_attrib_genA s_of_ntheorems_l"
definition "s_of_attrib1 = s_of_attrib_genB (\<lambda>l. String_concat \<open> \<close> (L.map To_string l))"

fun s_of_tactic where "s_of_tactic expr = (\<lambda>
    Method_rule o_s \<Rightarrow> sprint1 \<open>rule%s\<close>\<acute> (case o_s of None \<Rightarrow> \<open>\<close>
                                                           | Some s \<Rightarrow> sprint1 \<open> %s\<close>\<acute> (s_of_ntheorem s))
  | Method_drule s \<Rightarrow> sprint1 \<open>drule %s\<close>\<acute> (s_of_ntheorem s)
  | Method_erule s \<Rightarrow> sprint1 \<open>erule %s\<close>\<acute> (s_of_ntheorem s)
  | Method_intro l \<Rightarrow> sprint1 \<open>intro %s\<close>\<acute> (s_of_ntheorem_l1 l)
  | Method_elim s \<Rightarrow> sprint1 \<open>elim %s\<close>\<acute> (s_of_ntheorem s)
  | Method_subst asm l s =>
      let s_asm = if asm then \<open>(asm) \<close> else \<open>\<close> in
      if L.map String.to_list l = [''0''] then
        sprint2 \<open>subst %s%s\<close>\<acute> s_asm (s_of_ntheorem s)
      else
        sprint3 \<open>subst %s(%s) %s\<close>\<acute> s_asm (String_concat \<open> \<close> (L.map To_string l)) (s_of_ntheorem s)
  | Method_insert l => sprint1 \<open>insert %s\<close>\<acute> (s_of_ntheorems_l l)
  | Method_plus t \<Rightarrow> sprint1 \<open>(%s)+\<close>\<acute> (String_concat \<open>, \<close> (List.map s_of_tactic t))
  | Method_option t \<Rightarrow> sprint1 \<open>(%s)?\<close>\<acute> (String_concat \<open>, \<close> (List.map s_of_tactic t))
  | Method_or t \<Rightarrow> sprint1 \<open>(%s)\<close>\<acute> (String_concat \<open> | \<close> (List.map s_of_tactic t))
  | Method_one (Method_simp_only l) \<Rightarrow> sprint1 \<open>simp only: %s\<close>\<acute> (s_of_ntheorems_l l)
  | Method_one (Method_simp_add_del_split l1 l2 []) \<Rightarrow> sprint2 \<open>simp%s%s\<close>\<acute>
      (s_of_attrib \<open>add\<close> l1)
      (s_of_attrib \<open>del\<close> l2)
  | Method_one (Method_simp_add_del_split l1 l2 l3) \<Rightarrow> sprint3 \<open>simp%s%s%s\<close>\<acute>
      (s_of_attrib \<open>add\<close> l1)
      (s_of_attrib \<open>del\<close> l2)
      (s_of_attrib \<open>split\<close> l3)
  | Method_all (Method_simp_only l) \<Rightarrow> sprint1 \<open>simp_all only: %s\<close>\<acute> (s_of_ntheorems_l l)
  | Method_all (Method_simp_add_del_split l1 l2 []) \<Rightarrow> sprint2 \<open>simp_all%s%s\<close>\<acute>
      (s_of_attrib \<open>add\<close> l1)
      (s_of_attrib \<open>del\<close> l2)
  | Method_all (Method_simp_add_del_split l1 l2 l3) \<Rightarrow> sprint3 \<open>simp_all%s%s%s\<close>\<acute>
      (s_of_attrib \<open>add\<close> l1)
      (s_of_attrib \<open>del\<close> l2)
      (s_of_attrib \<open>split\<close> l3)
  | Method_auto_simp_add_split l_simp l_split \<Rightarrow> sprint2 \<open>auto%s%s\<close>\<acute>
      (s_of_attrib \<open>simp\<close> l_simp)
      (s_of_attrib1 \<open>split\<close> l_split)
  | Method_rename_tac l \<Rightarrow> sprint1 \<open>rename_tac %s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
  | Method_case_tac e \<Rightarrow> sprint1 \<open>case_tac \"%s\"\<close>\<acute> (s_of_expr e)
  | Method_blast None \<Rightarrow> sprint0 \<open>blast\<close>\<acute>
  | Method_blast (Some n) \<Rightarrow> sprint1 \<open>blast %d\<close>\<acute> (To_nat n)
  | Method_clarify \<Rightarrow> sprint0 \<open>clarify\<close>\<acute>
  | Method_metis l_opt l \<Rightarrow> sprint2 \<open>metis %s%s\<close>\<acute> (if l_opt = [] then \<open>\<close>
                                                   else
                                                     sprint1 \<open>(%s) \<close>\<acute> (String_concat \<open>, \<close> (L.map To_string l_opt))) (s_of_ntheorem_l1 l)) expr"

definition "s_of_tactic_last = (\<lambda> Command_done \<Rightarrow> \<open>done\<close>
                                | Command_by l_apply \<Rightarrow> sprint1 \<open>by(%s)\<close>\<acute> (String_concat \<open>, \<close> (L.map s_of_tactic l_apply))
                                | Command_sorry \<Rightarrow> \<open>sorry\<close>)"

definition "s_of_meth_apply_end = (
  \<lambda> Command_apply_end [] \<Rightarrow> \<open>\<close>
  | Command_apply_end l_apply \<Rightarrow> sprint1 \<open>  apply_end(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map s_of_tactic l_apply)))"

definition' \<open>s_of_meth_apply = (
  let thesis = \<open>?thesis\<close>
    ; scope_thesis_gen = sprint2 \<open>  proof - %s show %s
\<close>\<acute>
    ; scope_thesis = \<lambda>s. scope_thesis_gen s thesis in
  \<lambda> Command_apply [] \<Rightarrow> \<open>\<close>
  | Command_apply l_apply \<Rightarrow> sprint1 \<open>  apply(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map s_of_tactic l_apply))
  | Command_using l \<Rightarrow> sprint1 \<open>  using %s
\<close>\<acute> (s_of_ntheorems_l l)
  | Command_unfolding l \<Rightarrow> sprint1 \<open>  unfolding %s
\<close>\<acute> (s_of_ntheorems_l l)
  | Command_let e_name e_body \<Rightarrow> scope_thesis (sprint2 \<open>let %s = "%s"\<close>\<acute> (s_of_expr e_name) (s_of_expr e_body))
  | Command_have n b e e_last \<Rightarrow> scope_thesis (sprint4 \<open>have %s%s: "%s" %s\<close>\<acute> (To_string n) (if b then \<open>[simp]\<close> else \<open>\<close>) (s_of_expr e) (s_of_tactic_last e_last))
  | Command_fix_let l l_let o_show _ \<Rightarrow>
      scope_thesis_gen
        (sprint2 \<open>fix %s%s\<close>\<acute> (String_concat \<open> \<close> (L.map To_string l))
                                     (String_concat
                                       (\<open>
\<close>                                        )
                                       (L.map
                                         (\<lambda>(e_name, e_body).
                                           sprint2 \<open>          let %s = "%s"\<close>\<acute> (s_of_expr e_name) (s_of_expr e_body))
                                         l_let)))
        (case o_show of None \<Rightarrow> thesis
                      | Some l_show \<Rightarrow> sprint1 \<open>"%s"\<close>\<acute> (String_concat \<open> \<Longrightarrow> \<close> (L.map s_of_expr l_show))))\<close>

definition "s_of_lemma_by _ =
 (\<lambda> Lemma n l_spec l_apply tactic_last \<Rightarrow>
    sprint4 \<open>lemma %s : \"%s\"
%s%s\<close>\<acute>
      (To_string n)
      (String_concat \<open> \<Longrightarrow> \<close> (L.map s_of_expr l_spec))
      (String_concat \<open>\<close> (L.map (\<lambda> [] \<Rightarrow> \<open>\<close> | l_apply \<Rightarrow> sprint1 \<open>  apply(%s)
\<close>\<acute> (String_concat \<open>, \<close> (L.map s_of_tactic l_apply))) l_apply))
      (s_of_tactic_last tactic_last)
  | Lemma_assumes n l_spec concl l_apply tactic_last \<Rightarrow>
    sprint5 \<open>lemma %s : %s
%s%s %s\<close>\<acute>
      (To_string n)
      (String_concat \<open>\<close> (L.map (\<lambda>(n, b, e).
          sprint2 \<open>
assumes %s\"%s\"\<close>\<acute>
            (let (n, b) = if b then (sprint1 \<open>%s[simp]\<close>\<acute> (To_string n), False) else (To_string n, String.is_empty n) in
             if b then \<open>\<close> else sprint1 \<open>%s: \<close>\<acute> n)
            (s_of_expr e)) l_spec
       @@@@
       [sprint1 \<open>
shows \"%s\"\<close>\<acute> (s_of_expr concl)]))
      (String_concat \<open>\<close> (L.map s_of_meth_apply l_apply))
      (s_of_tactic_last tactic_last)
      (String_concat \<open> \<close>
        (L.map
          (\<lambda>l_apply_e.
            sprint1 \<open>%sqed\<close>\<acute>
              (if l_apply_e = [] then
                 \<open>\<close>
               else
                 sprint1 \<open>
%s \<close>\<acute> (String_concat \<open>\<close> (L.map s_of_meth_apply_end l_apply_e))))
          (List.map_filter
            (\<lambda> Command_let _ _ \<Rightarrow> Some [] | Command_have _ _ _ _ \<Rightarrow> Some [] | Command_fix_let _ _ _ l \<Rightarrow> Some l | _ \<Rightarrow> None)
            (rev l_apply)))))"


definition "s_of_axiom _ = (\<lambda> Axiomatization n e \<Rightarrow> sprint2 \<open>axiomatization where %s:
\"%s\"\<close>\<acute> (To_string n) (s_of_expr e))"


definition "s_of_text _ = (\<lambda> Text s \<Rightarrow> sprint1 \<open>text{* %s *}\<close>\<acute> (To_string s))"

definition "s_of_ml _ = (\<lambda> SML e \<Rightarrow> sprint1 \<open>ML{* %s *}\<close>\<acute> (s_of_sexpr e))"

definition "s_of_thm _ = (\<lambda> Thm thm \<Rightarrow> sprint1 \<open>thm %s\<close>\<acute> (s_of_ntheorem_l1 thm))"

definition' \<open>s_of_interpretation _ = (\<lambda> Interpretation n loc_n loc_param tac \<Rightarrow>
  sprint4 \<open>interpretation %s: %s%s
%s\<close>\<acute> (To_string n)
     (To_string loc_n)
     (String_concat \<open>\<close> (L.map (\<lambda>s. sprint1 \<open> "%s"\<close>\<acute> (s_of_expr s)) loc_param))
     (s_of_tactic_last tac))\<close>

end

lemmas [code] =
  (* def *)
  s_of.s_of_dataty_def
  s_of.s_of_ty_synonym_def
  s_of.s_of_ty_notation_def
  s_of.s_of_instantiation_class_def
  s_of.s_of_defs_overloaded_def
  s_of.s_of_consts_class_def
  s_of.s_of_definition_hol_def
  s_of.s_of_ntheorem_aux_gen_def
  s_of.s_of_ntheorem_aux_gen_where_def
  s_of.s_of_ntheorem_aux_gen_of_def
  s_of.s_of_ntheorem_def
  s_of.s_of_ntheorems_def
  s_of.s_of_ntheorem_l_def
  s_of.s_of_ntheorem_l1_def
  s_of.s_of_ntheorems_l_def
  s_of.s_of_lemmas_simp_def
  s_of.s_of_attrib_genA_def
  s_of.s_of_attrib_genB_def
  s_of.s_of_attrib_def
  s_of.s_of_attrib1_def
  s_of.s_of_tactic_last_def
  s_of.s_of_meth_apply_end_def
  s_of.s_of_meth_apply_def
  s_of.s_of_lemma_by_def
  s_of.s_of_axiom_def
  s_of.s_of_text_def
  s_of.s_of_ml_def
  s_of.s_of_thm_def
  s_of.s_of_interpretation_def

  (* fun *)
  s_of.s_of_rawty.simps
  s_of.s_of_expr.simps
  s_of.s_of_ntheorem_aux.simps
  s_of.s_of_tactic.simps

end
