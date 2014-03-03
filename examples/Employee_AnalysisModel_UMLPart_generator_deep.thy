(*****************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.4
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * Employee_AnalysisModel_UMLPart_generator_deep.thy --- OCL Contracts and an Example.
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2014 Universite Paris-Sud, France
 *               2014 IRT SystemX, France
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

header{* Part ... *}

theory
  Employee_AnalysisModel_UMLPart_generator_deep
imports
  "../src/OCL_class_diagram_generator"
begin

generation_mode [ deep analysis
                    (*THEORY Employee_AnalysisModel_UMLPart_generated IMPORTS "../src/OCL_main"*)
                    SECTION
                    (*oid_start 10*)
                    (*thy_dir "../doc"*) ]

Class Person =
  attr_base salary :: int
  attr_object boss

Class Planet =
  attr_base weight :: nat
  child Person

Class Galaxy =
  attr_base sound :: unit
  attr_base moving :: bool
  child Planet

Class OclAny =
  child Galaxy

Class.end OclAny

Define_int [ 1000, 1200, 1300, 1800, 2600, 2900, 3200, 3500 ]

Instance X1 :: Person = [ salary = 1300 , boss = X2 ]
     and X2 :: Person = [ salary = 1800 , boss = X2 ]
     and X3 :: Person = []
     and X4 :: Person = [ salary = 2900 ]
     and X5 :: Person = [ salary = 3500 ]
     and X6 :: Person = [ salary = 2500 , boss = X7 ]
     and X7 :: OclAny = ([ salary = 3200 , boss = X7 ] :: Person)
     and X8 :: OclAny = []
     and X9 :: Person = [ salary = 0 ]

Define_state s1 =
  [ defines [ ([ salary = 1000 , boss = self 1 ] :: Person)
            , ([ salary = 1200 ] :: Person) ]
  , skip
  , defines [ ([ salary = 2600 , boss = self 4 ] :: Person)
            , X5
            , ([ salary = 2300 , boss = self 3 ] :: Person) ]
  , skip
  , skip
  , defines [ X9 ] ]

Define_state s2 =
  [ defines [ X1
            , X2
            , X3
            , X4 ]
  , skip
  , defines [ X6
            , X7
            , X8
            , X9 ] ]

Define_state s0 = []

end
