--Authors: Zhongfan Dou 691889 zdou; Junjie Huang 751401 junjieh3
--Subject: SWEN90010
--Assignment 1
--This file is the specification of ICD unit, which indicates the attributs
--and procedures/functions of the type.

with HRM; use HRM;
with ImpulseGenerator; use ImpulseGenerator;
with Network; use Network;
with Measures;
with Heart; use Heart;

package ICD is


   type ICDType is

      record
         IsOn : Boolean;

         Tachy : Measures.BPM;

         Joules : Measures.Joules;

         --Indicate whether this is the first tick after the system is initialised
         IsFirstTick: Boolean;

         --Recording the current time
         totalTick : Integer;

         --The heart rate history, with 6 previous and one most recent reading
         Rate1 : Network.RateRecord;
         Rate2 : Network.RateRecord;
         Rate3 : Network.RateRecord;
         Rate4 : Network.RateRecord;
         Rate5 : Network.RateRecord;
         Rate6 : Network.RateRecord;
         rateCurrent : Network.RateRecord;

         --Indicates whether the ICD need to send message back to network
         --and the message it self
         ResponseAvailable : Boolean;
         ResponseMessage : Network.NetworkMessage;

         --List of authorised people of the system
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

   --Procedures for changing settings
   procedure SetBound(Icd : in out ICDType; Bound:in Integer);
   procedure SetJoules(Icd: in out ICDType; J:in Integer);

   --Function that return the reading history
   function GetHistory(Icd: in ICDType) return Network.RateHistory;

   --Function that gives the response according to comming message
   function ProcessMessage(Msg: in out Network.NetworkMessage; Icd: in out ICDType)
                           return Network.NetworkMessage;

   --SImulate one tick
   procedure Tick(Icd1 : in out ICD.ICDType; Network1 : in out Network.Network;
                  Hrm1 : in out HRM.HRMType; Gen1 : in out ImpulseGenerator.GeneratorType;
                 Hrt1 : in HeartType);

   --Procedure that checks for tachycardia
   procedure CheckMax(Icd: in out ICDType; Gen: out ImpulseGenerator.GeneratorType);

   --Procedure that checks for ventricle fibrillation
   procedure CheckAvg(Icd: in ICDType; Gen: in out ImpulseGenerator.GeneratorType);

   --Function that checks the authority of comming message
   function CheckAuthority(Icd : in ICDType; Msg: in out Network.NetworkMessage) return Boolean;


end ICD;
