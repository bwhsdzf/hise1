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
   HeartRate : BPM;
   ICDUnit : ICD.ICDType;
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
      -- Initialise the components and turn the machines on
      Heart.Init(Hrt);
      HRM.Init(Monitor);
      ImpulseGenerator.Init(Generator);
      Network.Init(Net,KnownPrincipals);
      ICD.Init(ICDUnit,KnownPrincipals);

      HRM.On(Monitor, Hrt);
      ImpulseGenerator.On(Generator);

      -- Set the new impulse to 0
      ImpulseGenerator.SetImpulse(Generator, 0);
   end Init;

   procedure Tick is
   begin
      ImpulseGenerator.Tick(Generator, Hrt);
      HRM.Tick(Monitor, Hrt);
      Heart.Tick(Hrt);
      Network.Tick(Net);
      ICD.Tick(ICDUnit,Net,Monitor,Generator,Hrt);
   end Tick;
end ClosedLoop;
