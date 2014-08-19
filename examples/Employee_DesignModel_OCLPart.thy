(*****************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.4
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * Employee_DesignModel_OCLPart.thy --- OCL Contracts and an Example.
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2012-2014 Université Paris-Sud, France
 *               2013-2014 IRT SystemX, France
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

theory
  Employee_DesignModel_OCLPart
imports
  Employee_DesignModel_UMLPart (* Testing *)
begin
text {* \label{ex:employee-design:ocl} *}
section{* OCL Part: Standard State Infrastructure *}
text{* Ideally, these definitions are automatically generated from the class model. *}

section{* Invariant *}
text{* These recursive predicates can be defined conservatively
by greatest fix-point
constructions---automatically. See~\cite{brucker.ea:hol-ocl-book:2006,brucker:interactive:2007}
for details. For the purpose of this example, we state them as axioms
here.

\begin{ocl}
context Person
  inv label : self .boss <> null implies (self .salary  \<le>  ((self .boss) .salary))
\end{ocl}
*}

definition Person_label\<^sub>i\<^sub>n\<^sub>v :: "Person \<Rightarrow> Boolean" 
where     "Person_label\<^sub>i\<^sub>n\<^sub>v (self) \<equiv>  
                 (self .boss <> null implies (self .salary  \<le>\<^sub>i\<^sub>n\<^sub>t  ((self .boss) .salary)))"
                                       

definition Person_label\<^sub>i\<^sub>n\<^sub>v\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e :: "Person \<Rightarrow> Boolean" 
where     "Person_label\<^sub>i\<^sub>n\<^sub>v\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e (self) \<equiv>  
                 (self .boss@pre <> null implies (self .salary@pre \<le>\<^sub>i\<^sub>n\<^sub>t ((self .boss@pre) .salary@pre)))"

definition Person_label\<^sub>g\<^sub>l\<^sub>o\<^sub>b\<^sub>a\<^sub>l\<^sub>i\<^sub>n\<^sub>v :: "Boolean"
where     "Person_label\<^sub>g\<^sub>l\<^sub>o\<^sub>b\<^sub>a\<^sub>l\<^sub>i\<^sub>n\<^sub>v \<equiv> (Person .allInstances()->forAll(x | Person_label\<^sub>i\<^sub>n\<^sub>v (x)) and 
                                  (Person .allInstances@pre()->forAll(x | Person_label\<^sub>i\<^sub>n\<^sub>v\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e (x))))"
                                  
                                  
lemma "\<tau> \<Turnstile> \<delta> (X .boss) \<Longrightarrow> \<tau> \<Turnstile> Person .allInstances()->includes(X .boss) \<and>
                            \<tau> \<Turnstile> Person .allInstances()->includes(X) "
sorry 
(* To be generated generically ... hard, but crucial lemma that should hold. 
   It means that X and it successor are object representation that actually
   occur in the state. *)

lemma REC_pre : "\<tau> \<Turnstile> Person_label\<^sub>g\<^sub>l\<^sub>o\<^sub>b\<^sub>a\<^sub>l\<^sub>i\<^sub>n\<^sub>v 
       \<Longrightarrow> \<tau> \<Turnstile> Person .allInstances()->includes(X) (* X represented object in state *)
       \<Longrightarrow> \<exists> REC.  \<tau> \<Turnstile> REC(X)  \<triangleq> (Person_label\<^sub>i\<^sub>n\<^sub>v (X) and (X .boss <> null implies REC(X .boss)))"
sorry (* Attempt to allegiate the burden of he following axiomatizations: could be
         a witness for a constant specification ...*)       

text{* This allows to state a predicate: *}
                                       
axiomatization inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l :: "Person \<Rightarrow> Boolean"
where inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l_def:
"(\<tau> \<Turnstile> Person .allInstances()->includes(self)) \<Longrightarrow> 
 (\<tau> \<Turnstile> (inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l(self) \<triangleq>  (self .boss <> null implies  
                                  (self .salary  \<le>\<^sub>i\<^sub>n\<^sub>t  ((self .boss) .salary)) and
                                   inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l(self .boss))))"

axiomatization inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e :: "Person \<Rightarrow> Boolean"
where inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e_def: 
"(\<tau> \<Turnstile> Person .allInstances@pre()->includes(self)) \<Longrightarrow>
 (\<tau> \<Turnstile> (inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e(self) \<triangleq> (self .boss@pre <> null implies 
                                   (self .salary@pre  \<le>\<^sub>i\<^sub>n\<^sub>t  ((self .boss@pre) .salary@pre)) and
                                    inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e(self .boss@pre))))"


lemma inv_1 : 
"(\<tau> \<Turnstile> Person .allInstances()->includes(self)) \<Longrightarrow>
    (\<tau> \<Turnstile> inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l(self) = ((\<tau> \<Turnstile> (self .boss \<doteq> null)) \<or>
                               ( \<tau> \<Turnstile> (self .boss <> null) \<and> 
                                 \<tau> \<Turnstile> ((self .salary)  \<le>\<^sub>i\<^sub>n\<^sub>t  (self .boss .salary))  \<and>
                                 \<tau> \<Turnstile> (inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l(self .boss))))) "
sorry (* Let's hope that this holds ... *)


lemma inv_2 : 
"(\<tau> \<Turnstile> Person .allInstances@pre()->includes(self)) \<Longrightarrow>
    (\<tau> \<Turnstile> inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e(self)) =  ((\<tau> \<Turnstile> (self .boss@pre \<doteq> null)) \<or>
                                     (\<tau> \<Turnstile> (self .boss@pre <> null) \<and>
                                     (\<tau> \<Turnstile> (self .boss@pre .salary@pre \<le>\<^sub>i\<^sub>n\<^sub>t self .salary@pre))  \<and>
                                     (\<tau> \<Turnstile> (inv\<^sub>P\<^sub>e\<^sub>r\<^sub>s\<^sub>o\<^sub>n\<^sub>_\<^sub>l\<^sub>a\<^sub>b\<^sub>e\<^sub>l\<^sub>A\<^sub>T\<^sub>p\<^sub>r\<^sub>e(self .boss@pre)))))"
sorry (* Let's hope that this holds ... *)

text{* A very first attempt to characterize the axiomatization by an inductive
definition - this can not be the last word since too weak (should be equality!) *}
coinductive inv :: "Person \<Rightarrow> (\<AA>)st \<Rightarrow> bool" where
 "(\<tau> \<Turnstile> (\<delta> self)) \<Longrightarrow> ((\<tau> \<Turnstile> (self .boss \<doteq> null)) \<or>
                      (\<tau> \<Turnstile> (self .boss <> null) \<and> (\<tau> \<Turnstile> (self .boss .salary \<le>\<^sub>i\<^sub>n\<^sub>t self .salary))  \<and>
                     ( (inv(self .boss))\<tau> )))
                     \<Longrightarrow> ( inv self \<tau>)"

section{* The Contract of a Recursive Query *}
text{* The original specification of a recursive query :
\begin{ocl}
context Person::contents():Set(Integer)
post:  result = if self.boss = null
                then Set{i}
                else self.boss.contents()->including(i)
                endif
\end{ocl} *}

(*
consts dot_contents :: "Person \<Rightarrow> Set_Integer"  ("(1(_).contents'('))" 50)
*)

text{* For a non-recursive operation contract of the form:
\begin{ocl}
context T::operation(arg1:T1,...,argn:Tn):ResultType
pre:   PRE (arg1,...,argn)
post:  POST(arg1,...,argn,result)
\end{ocl}

we can generate a conservative definition:
*}

definition PRE\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n :: "('\<AA>,'\<tau>0::null)val \<Rightarrow>
                             ('\<AA>,'\<alpha>1::null)val \<Rightarrow> ('\<AA>,'\<alpha>2::null)val \<Rightarrow> ('\<AA>,'\<alpha>n::null)val \<Rightarrow>
                             ('\<AA>, Boolean\<^sub>b\<^sub>a\<^sub>s\<^sub>e)val"
where     "PRE\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n self a1 a2 an = undefined"

definition POST\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n :: "('\<AA>,'\<tau>0::null)val \<Rightarrow>
                             ('\<AA>,'\<alpha>1::null)val \<Rightarrow> ('\<AA>,'\<alpha>2::null)val \<Rightarrow> ('\<AA>,'\<alpha>n::null)val \<Rightarrow>
                             ('\<AA>,'res::null)val \<Rightarrow>
                             ('\<AA>, Boolean\<^sub>b\<^sub>a\<^sub>s\<^sub>e)val"
where     "POST\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n self a1 a2 an result = undefined"


definition operation :: "('\<AA>,'\<tau>0::null)val \<Rightarrow>
                         ('\<AA>,'\<alpha>1::null)val \<Rightarrow> ('\<AA>,'\<alpha>2::null)val \<Rightarrow> ('\<AA>,'\<alpha>n::null)val \<Rightarrow> 
                         ('\<AA>,'res::null)val"
                  ("_ .operation'(_,_,_')" [50,50,50,50]55)
where "self .operation(a1,a2,an) \<equiv> 
            (\<lambda> \<tau>. if (\<tau> \<Turnstile> (\<delta> self)) \<and>  (\<tau> \<Turnstile> \<upsilon> a1) \<and>  (\<tau> \<Turnstile> \<upsilon> a2) \<and>  (\<tau> \<Turnstile> \<upsilon> an)
                  then SOME res. (\<tau> \<Turnstile> PRE\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n self a1 a2 an) \<and>  
                                 (\<tau> \<Turnstile> POST\<^sub>o\<^sub>p\<^sub>e\<^sub>r\<^sub>a\<^sub>t\<^sub>i\<^sub>o\<^sub>n self a1 a2 an (\<lambda> _. res))
                  else invalid \<tau>)"

text{* For the case of recursive queries, we use at present just axiomatizations: *}               
                  
axiomatization dot_contents :: "Person \<Rightarrow> Set_Integer"  ("(1(_).contents'('))" 50)
where dot_contents_def:
"(\<tau> \<Turnstile> ((self).contents() \<triangleq> result)) =
 (if (\<delta> self) \<tau> = true \<tau>
  then ((\<tau> \<Turnstile> true) \<and>
        (\<tau> \<Turnstile> (result \<triangleq> if (self .boss \<doteq> null)
                        then (Set{self .salary})
                        else (self .boss .contents()->including(self .salary))
                        endif)))
  else \<tau> \<Turnstile> result \<triangleq> invalid)"

text{* Since we have only one interpretation function, we need the corresponding
operation on the pre-state: *}               

consts dot_contents_AT_pre :: "Person \<Rightarrow> Set_Integer"  ("(1(_).contents@pre'('))" 50)

axiomatization where dot_contents_AT_pre_def:
"(\<tau> \<Turnstile> (self).contents@pre() \<triangleq> result) =
 (if (\<delta> self) \<tau> = true \<tau>
  then \<tau> \<Turnstile> true \<and>                                (* pre *)
        \<tau> \<Turnstile> (result \<triangleq> if (self).boss@pre \<doteq> null  (* post *)
                        then Set{(self).salary@pre}
                        else (self).boss@pre .contents@pre()->including(self .salary@pre)
                        endif)
  else \<tau> \<Turnstile> result \<triangleq> invalid)"

text{* These \inlineocl{@pre} variants on methods are only available on queries, \ie,
operations without side-effect. *}

(* Missing: Properties on Casts, type-tests, and equality vs. projections. *)

section{* The Contract of a Method *}
text{*
The specification in high-level OCL input syntax reads as follows:
\begin{ocl}
context Person::insert(x:Integer)
post: contents():Set(Integer)
contents() = contents@pre()->including(x)
\end{ocl}
*}


definition insert :: "Person \<Rightarrow>Integer \<Rightarrow> Void"  ("(1(_).insert'(_'))" 50)
where "self .insert(x) \<equiv> 
            (\<lambda> \<tau>. if (\<tau> \<Turnstile> (\<delta> self)) \<and>  (\<tau> \<Turnstile> \<upsilon> x)
                  then SOME res. (\<tau> \<Turnstile> true \<and>  
                                 (\<tau> \<Turnstile> ((self).contents() \<triangleq> (self).contents@pre()->including(x))))
                  else invalid \<tau>)"  

end
