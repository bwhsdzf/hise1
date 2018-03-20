--Authors: Zhongfan Dou 691889 zdou; Junjie Huang 751401 junjieh3
--Subject: SWEN90010
--Assignment 1
--This is the package body of the ICD unit, which is responsible to handling
--message from network, checking heart rate status, and changing setting of the
--system, etc.

with HRM; use HRM;
with ImpulseGenerator; use ImpulseGenerator;
with Measures;
with Network; use Network;
with Heart; use Heart;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Assertions;
with Principal; use type Principal.PrincipalPtr;

package body ICD is

   --The impulse for tachycardia
   TachyImpulse : constant Measures.Joules := 2;

   --Number of decisecond in one min
   MinToDeci : constant Integer := 600;

   --The BMP added to current heart rate for tachycardia
   TachyBMP : constant Measures.BPM := 15;

   --The average change of detecting ventricle fibrillation
   VentriChange : constant Measures.BPM := 10;


   procedure Init(Icd : out ICDType; KnownPrins : access PrincipalArray) is
   begin
      --initial mode is off
      Icd.IsOn := False;
      --initial upper bound is 100
      Icd.Tachy := 100;
      --initial Joules
      Icd.Joules := 30;

      --Initialising for the first tick
      Icd.IsFirstTick :=True;
      Icd.rate1.Rate := Measures.BPM(0);
      Icd.rate2.Rate := Measures.BPM(0);
      Icd.rate3.Rate := Measures.BPM(0);
      Icd.rate4.Rate := Measures.BPM(0);
      Icd.rate5.Rate := Measures.BPM(0);
      Icd.Rate6.Rate := Measures.BPM(0);
      Icd.rateCurrent.Rate := Measures.BPM(0);

      Icd.totalTick := 0;

      --Recording the known principles
      Icd.Prins := new PrincipalArray(KnownPrins'First..KnownPrins'Last);
      for i in KnownPrins'Range loop
         Icd.Prins(i) := KnownPrins(i);
      end loop;

      Icd.NImpulse := 0;
      Icd.AvgTick := 0;
      Icd.NTick := 0;
   end Init;


   procedure On(Icd : in out ICDType) is
   begin
      Icd.IsOn := True;
   end On;

   procedure Off(Icd : in out ICDType) is
   begin
      Icd.IsOn := False;
   end Off;

   function IsOn(Icd : in ICDType) return Boolean is
   begin
      return Icd.IsOn;
   end IsOn;

   --Change the upper bound of tachycardia, between range of -1 to 300
   procedure SetBound(Icd : in out ICDType; Bound:in Integer) is
      newBound : Measures.BPM;
   begin
      newBound := Measures.LimitBPM(Bound);
      Icd.Tachy := newBound;
      --Put("Setting bound to");
      --Put(Item => newBound);
      --New_Line;
   end SetBound;

   --Change the jules to deliver for ventricle fibrillation
   procedure SetJoules(Icd: in out ICDType; J:in Integer) is
      newJ : Measures.Joules;
   begin
      newJ := Measures.LimitJoules(J);
      Icd.Joules := newJ;
      --Put("Setting J to");Put(Item => newJ);
      --New_Line;
   end SetJoules;

   --Return 5 most recent reading of heart rate
   function GetHistory(Icd: in ICDType) return Network.RateHistory is
      RH : Network.RateHistory;
   begin
      RH(1) := Icd.Rate3;
      RH(2) := Icd.Rate4;
      RH(3) := Icd.Rate5;
      RH(4) := Icd.Rate6;
      RH(5) := Icd.rateCurrent;
      return RH;
   end GetHistory;

   --Return the response message
   function ProcessMessage(Msg: in out Network.NetworkMessage; Icd: in out ICDType)
                           return Network.NetworkMessage is
   begin
      case Msg.MessageType is
         --For on and off, just return the message itself
         when ModeOn =>
            return (MessageType => ModeOn,
                    MOnSource => Msg.MOnSource);

         when ModeOff =>
            return (MessageType => ModeOff,
                    MOffSource => Msg.MOffSource);

         --Return the history for reading request
         when ReadRateHistoryRequest =>
            return (MessageType => ReadRateHistoryResponse,
                    HDestination => Msg.HSource,
                    History => GetHistory(Icd));

         --Return the settings
         when ReadSettingsRequest =>
            return (MessageType => ReadSettingsResponse,
                    RDestination => Msg.RSource,
                    RTachyBound => Icd.Tachy,
                    RJoulesToDeliver => Icd.Joules);

         --Just reply to the setting changing request
         when ChangeSettingsRequest =>
            SetBound(Icd, Msg.CTachyBound);
            SetJoules(Icd,Msg.CJoulesToDeliver);
            return (MessageType => ChangeSettingsResponse,
                    CDestination => Msg.CSource);

         when others =>
            raise Ada.Assertions.Assertion_Error;
      end case;

   end ProcessMessage;

   --Simulate the tick
   procedure Tick (Icd1: in out ICDType; Network1: in out Network.Network;
                   Hrm1: in out HRMType; Gen1: in out GeneratorType; Hrt1 :HeartType)
   is
      ComingMessage : Network.NetworkMessage;

      NewMessageAvailable : Boolean;
   begin

      Icd1.totalTick := Icd1.totalTick+1;

      --Always set impluse generator to 0 to prevent it from sending impulse when
      --no need
      ImpulseGenerator.SetImpulse(Gen1,0);

      --At the beginning the response is unavailable
      Icd1.ResponseAvailable := False;
      --Judge whether it is the first tick, do this to prevent ventricle fibrillation
      --if first reading is too high.
      If Icd1.IsOn then
         if Icd1.IsFirstTick then
            Icd1.rateCurrent.Time := Measures.TickCount(Icd1.totalTick);
            GetRate(Hrm1,Icd1.rateCurrent.Rate);
            Icd1.Rate6 := Icd1.rateCurrent;
            Icd1.Rate5 := Icd1.rateCurrent;
            Icd1.Rate4 := Icd1.rateCurrent;
            Icd1.Rate3 := Icd1.rateCurrent;
            Icd1.Rate2 := Icd1.rateCurrent;
            Icd1.Rate1 := Icd1.rateCurrent;
            Icd1.IsFirstTick := False;

         --Not first reading, then simply update history
         else
            Icd1.Rate1 := Icd1.Rate2;
            Icd1.Rate2 := Icd1.Rate3;
            Icd1.Rate3 := Icd1.Rate4;
            Icd1.Rate4 := Icd1.Rate5;
            Icd1.Rate5 := Icd1.Rate6;
            Icd1.Rate6 := Icd1.rateCurrent;
            Icd1.rateCurrent.Time := Measures.TickCount(Icd1.totalTick);
            GetRate(Hrm1,Icd1.rateCurrent.Rate);
         end if;

      end if;

      --Handle the message
      Network.GetNewMessage(Network1, NewMessageAvailable, ComingMessage);
      if NewMessageAvailable then
         if CheckAuthority(Icd1, ComingMessage) then
            case ComingMessage.MessageType is
            when ModeOn =>
               On(Icd1);
               ImpulseGenerator.On(Gen1);
               HRM.On(Hrm1,Hrt1);
               Icd1.ResponseMessage := ProcessMessage(ComingMessage, Icd1);
            when ModeOff =>
               Off(Icd1);
               ImpulseGenerator.Off(Gen1);
               HRM.Off(Hrm1);
               Icd1.ResponseMessage := ProcessMessage(ComingMessage, Icd1);

            --Only return reading when the system is on
            when ReadRateHistoryRequest =>
               if Icd1.IsOn = true  then
                  Icd1.ResponseAvailable := True;
                  Icd1.ResponseMessage := ProcessMessage(ComingMessage, Icd1);
               end if;

            when ReadSettingsRequest =>
               if Icd1.IsOn = False  then
                  Icd1.ResponseAvailable := True;
                  Icd1.ResponseMessage := ProcessMessage(ComingMessage, Icd1);
               end if;

            --Only change setting when the system is off
            when ChangeSettingsRequest =>
               if Icd1.IsOn = False  then
                  Icd1.ResponseAvailable :=true;
                  Icd1.ResponseMessage := ProcessMessage(ComingMessage,Icd1);
               end if;

               when others =>
            raise Ada.Assertions.Assertion_Error;
            end case;
         end if;

         --Send the message to network, if necessary
         if Icd1.ResponseAvailable then
            Network.SendMessage(Network1,Icd1.ResponseMessage);
         end if;
      end if;

      --Now see if impulse generator need to deliver impulse
      if Icd1.IsOn then
         if Icd1.NImpulse /= 0 then
            --Put_Line("Need more impulse");

            --If this is not the tick that we should send impluse signal, just pass
            if Icd1.NTick /= Icd1.AvgTick then
               Icd1.NTick := Icd1.NTick +1;

               --Else send the signal and signal counter +1, reset tick counter
            else
               ImpulseGenerator.SetImpulse(Gen1,TachyImpulse);
               Icd1.NImpulse := Icd1.NImpulse +1;
               Icd1.NTick := 0;
            end if;

            --Was that the last signal I need to send?
            if Icd1.NImpulse = 10 then
               Icd1.NImpulse := 0;
            end if;

         --Else othing special so just check the status
         else
            --Put("passing tick");New_Line;
            CheckAvg(Icd1,Gen1);
            CheckMax(Icd1,Gen1);
         end if;
      end if;
   end Tick;

   --Check if the most recent heart rate is higher than setting upper bound
   procedure CheckMax(Icd: in out ICDType; Gen: out ImpulseGenerator.GeneratorType) is
   begin
      --If Higher, then send first impulse, and starting count impulse and ticks
      if Icd.rateCurrent.Rate >= Icd.Tachy then
         Icd.AvgTick := MinToDeci / (Icd.rateCurrent.Rate + TachyBMP);
         ImpulseGenerator.SetImpulse(Gen,TachyImpulse);
         Icd.NImpulse := 1;
      end if;

   end CheckMax;

   --Check if ventricle fibrillation has happended
   procedure CheckAvg(Icd: ICDType; Gen: in out ImpulseGenerator.GeneratorType) is
      AvgChange : Integer;
   begin
      AvgChange := abs (Icd.Rate2.Rate - Icd.Rate1.Rate) +
      abs (Icd.Rate3.Rate - Icd.Rate2.Rate) +
      abs (Icd.Rate4.Rate - Icd.Rate3.Rate) +
      abs (Icd.Rate5.Rate - Icd.Rate4.Rate) +
      abs (Icd.Rate6.Rate - Icd.Rate5.Rate) +
      abs (Icd.rateCurrent.Rate - Icd.Rate5.Rate);
      AvgChange := AvgChange/6;
      if AvgChange >= VentriChange then
         --Put("avgchng reached");New_Line;
         ImpulseGenerator.SetImpulse(Gen,Icd.Joules);
      end if;
   end CheckAvg;

   --Check the authority of comming message
   function CheckAuthority(Icd : in ICDType; Msg: in out Network.NetworkMessage) return Boolean is
   begin
      case Msg.MessageType is
         --Only the doctor and assistant can switch on and off
         when ModeOn =>
            --Principal.DebugPrintPrincipalPtr(Msg.MOnSource);
            for i in Icd.Prins'Range loop
               if Msg.MOnSource = Icd.Prins(i) and
                 (Principal.HasRole(Msg.MOnSource.all,Principal.Cardiologist) or
                  Principal.HasRole(Msg.MOnSource.all,Principal.ClinicalAssistant))then
                  return True;
               end if;
            end loop;

         when ModeOff =>
            --Principal.DebugPrintPrincipalPtr(Msg.MOffSource);
            for i in Icd.Prins'Range loop
               if Msg.MOffSource = Icd.Prins(i) and
                 (Principal.HasRole(Msg.MOffSource.all,Principal.Cardiologist) or
                  Principal.HasRole(Msg.MOffSource.all,Principal.ClinicalAssistant))then
                  return True;
               end if;
            end loop;

         --Cardiologist, assistant and patient can read the hsitory
         when ReadRateHistoryRequest =>
            --Principal.DebugPrintPrincipalPtr(Msg.HSource);
            for i in Icd.Prins'Range loop
               if Msg.HSource = Icd.Prins(i) then
                  return True;
               end if;
            end loop;

         --Cardiologist and assistant can read the setting
         when ReadSettingsRequest =>
            --Put(Principal.PrincipalPtrToString(Msg.RSource));
            for i in Icd.Prins'Range loop
               if Msg.RSource = Icd.Prins(i)
                 and (Principal.HasRole(Msg.RSource.all,Principal.Cardiologist) or
                          Principal.HasRole(Msg.RSource.all,Principal.ClinicalAssistant))
               then
                  return True;
               end if;
            end loop;


         --Only the cardiologist can change the setting
         when ChangeSettingsRequest =>
            --Principal.DebugPrintPrincipalPtr(Msg.CSource);
            for i in Icd.Prins'Range loop
               if Msg.CSource = Icd.Prins(i) and
                 Principal.HasRole(Msg.CSource.all,Principal.Cardiologist)then
                  return True;
               end if;
            end loop;
         when others =>
            null;
      end case;

      --Otherwise not authorised
      return False;
   end CheckAuthority;


end ICD;

