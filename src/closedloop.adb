--Authors: Zhongfan Dou 691889 zdou; Junjie Huang 751401 junjieh3
--Subject: SWEN90010
--Assignment 1
--This is the ClosedLoop package which initialise all component of the
--system and tick them

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures; use Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network; use Network;
with Principal;
with ICD;


package body ClosedLoop is

   Hrt : Heart.HeartType;                -- The simulated heart
   Monitor : HRM.HRMType;                -- The simulated heart rate monitor
   Generator : ImpulseGenerator.GeneratorType; -- The simulated generator
   ICDUnit : ICD.ICDType;                -- The simulated ICD unit
   Net : Network.Network;                -- The simulated network
   Card : Principal.PrincipalPtr := new Principal.Principal;  -- A cardiologist
   Clin : Principal.PrincipalPtr := new Principal.Principal;  -- A clinical assistant
   Patient : Principal.PrincipalPtr := new Principal.Principal; -- A patient
   KnownPrincipals : access Network.PrincipalArray := new Network.PrincipalArray(0..2);

   procedure Init is
   begin
      -- set up the principals with the correct roles
      Principal.InitPrincipalForRole(Card.all,Principal.Cardiologist);
      Principal.InitPrincipalForRole(Clin.all,Principal.ClinicalAssistant);
      Principal.InitPrincipalForRole(Patient.all,Principal.Patient);
      KnownPrincipals(0) := Card;
      KnownPrincipals(1) := Clin;
      KnownPrincipals(2) := Patient;

      --Initialise all components
      Heart.Init(Hrt);
      HRM.Init(Monitor);
      ImpulseGenerator.Init(Generator);
      Network.Init(Net,KnownPrincipals);
      ICD.Init(ICDUnit,KnownPrincipals);

      HRM.On(Monitor, Hrt);
      ImpulseGenerator.On(Generator);


      ImpulseGenerator.SetImpulse(Generator, 0);
   end Init;

   procedure Tick is
   begin
      Network.Tick(Net);
      ICD.Tick(ICDUnit,Net,Monitor,Generator,Hrt);
      ImpulseGenerator.Tick(Generator, Hrt);
      HRM.Tick(Monitor, Hrt);
      Heart.Tick(Hrt);
   end Tick;
end ClosedLoop;
