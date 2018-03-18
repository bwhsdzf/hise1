with HRM; use HRM;
with ImpulseGenerator; use ImpulseGenerator;
with Network; use Network;
with Measures;

package ICD is

   type ICDType is

      record
         IsOn : Boolean;

         Tachy : Measures.BPM;

         Joules : Measures.Joules;

         -- judge whether there are 5 tick before now
         IsFirstTick: Boolean;

         totalTick : Natural;

         Rate1 : Network.RateRecord;
         Rate2 : Network.RateRecord;
         Rate3 : Network.RateRecord;
         Rate4 : Network.RateRecord;
         Rate5 : Network.RateRecord;
         rateCurrent : Network.RateRecord;
         ResponseAvailable : Boolean;

         ResponseMessage : Network.NetworkMessage;

         Prins : access Network.PrincipalArray;

         --These numbers are used to calculate when to send sig to Gen for
         --tachy situation
         --NImpulse indicates how many signals we have sent for one tachy
         --AvgTick means how many ticks between every 2 signal
         --NTick means how many ticks passed since last signal
         NImpulse : Integer;
         AvgTick : Integer;
         NTick : Integer;

      end record;

   procedure Init(Icd : out ICDType; KnownPrins : access PrincipalArray);

   procedure On(Icd : in out ICDType);

   procedure Off(Icd : in out ICDType);

   function IsOn(Icd : in ICDType) return Boolean;

   procedure SetBound(Icd : in out ICDType; Bound:in Integer);

   procedure SetJoules(Icd: in out ICDType; J:in Integer);

   function GetHistory(Icd: in ICDType) return Network.RateHistory;

   function ProcessMessage(Msg: in out Network.NetworkMessage; Icd: in out ICDType)
                           return Network.NetworkMessage;

   procedure Tick(Icd1 : in out ICD.ICDType; Network1 : in out Network.Network;
                 Hrm1 : in HRM.HRMType; Gen1 : in out ImpulseGenerator.GeneratorType);

   procedure CheckMax(Icd: in out ICDType; Gen: out ImpulseGenerator.GeneratorType);

   procedure CheckAvg(Icd: in ICDType; Gen: in out ImpulseGenerator.GeneratorType);

   function CheckAuthority(Icd : ICDType; Msg: Network.NetworkMessage) return Boolean;


end ICD;
