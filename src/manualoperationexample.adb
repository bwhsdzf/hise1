with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Measures; use Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with Network; use Network;
with Principal;
with ICD;
with ClosedLoop;

-- This procedure demonstrates a simple composition of the network,
-- heart rate  monitor (HRM), heart, and impulse generator, with three
-- known principals (a cardiologist, clinical assistant and patient).
procedure ManualOperationExample is
   
begin
   ClosedLoop.Init;
   for I in Integer range 0..500 loop
      ClosedLoop.Tick;
   end loop;
   
end ManualOperationExample;
