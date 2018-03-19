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

   procedure Init(Icd : out ICDType; KnownPrins : access PrincipalArray) is
   begin
            --initial mode is off
      Icd.IsOn := False;
      --initial upper bound is 100
      Icd.Tachy := 100;
      --initial Joules
      Icd.Joules := 30;
      Icd.IsFirstTick :=True;
      Icd.rate1.Rate := Measures.BPM(0);
      Icd.rate2.Rate := Measures.BPM(0);
      Icd.rate3.Rate := Measures.BPM(0);
      Icd.rate4.Rate := Measures.BPM(0);
      Icd.rate5.Rate := Measures.BPM(0);
      Icd.Rate6.Rate := Measures.BPM(0);
      Icd.rateCurrent.Rate := Measures.BPM(0);

      Icd.totalTick := 0;

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

   procedure SetBound(Icd : in out ICDType; Bound:in Integer) is
      newBound : Measures.BPM;
   begin
      newBound := Measures.LimitBPM(Bound);
      Icd.Tachy := newBound;
      Put("Setting bound to");
      Put(Item => newBound);
      New_Line;
   end SetBound;

   procedure SetJoules(Icd: in out ICDType; J:in Integer) is
      newJ : Measures.Joules;
   begin
      newJ := Measures.LimitJoules(J);
      Icd.Joules := newJ;
      Put("Setting J to");Put(Item => newJ);
      New_Line;
   end SetJoules;


   function GetHistory(Icd: in ICDType) return Network.RateHistory is
      RH : Network.RateHistory;
   begin
      RH(1) := Icd.Rate2;
      RH(2) := Icd.Rate3;
      RH(3) := Icd.Rate4;
      RH(4) := Icd.Rate5;
      RH(5) := Icd.Rate6;
      return RH;
   end GetHistory;


   function ProcessMessage(Msg: in out Network.NetworkMessage; Icd: in out ICDType)
                           return Network.NetworkMessage is
   begin
      case Msg.MessageType is
         when ModeOn =>
            return (MessageType => ModeOn,
                    MOnSource => Msg.MOnSource);

         when ModeOff =>
            return (MessageType => ModeOff,
                    MOffSource => Msg.MOffSource);

         when ReadRateHistoryRequest =>
            return (MessageType => ReadRateHistoryResponse,
                    HDestination => Msg.HSource,
                    History => GetHistory(Icd));

         when ReadSettingsRequest =>
            return (MessageType => ReadSettingsResponse,
                    RDestination => Msg.RSource,
                    RTachyBound => Icd.Tachy,
                    RJoulesToDeliver => Icd.Joules);

         when ChangeSettingsRequest =>
            SetBound(Icd, Msg.CTachyBound);
            SetJoules(Icd,Msg.CJoulesToDeliver);
            return (MessageType => ChangeSettingsResponse,
                    CDestination => Msg.CSource);

         when others =>
            raise Ada.Assertions.Assertion_Error;
      end case;

   end ProcessMessage;

   procedure Tick (Icd1: in out ICDType; Network1: in out Network.Network;
                   Hrm1: in out HRMType; Gen1: in out GeneratorType; Hrt1 :HeartType)
   is
      ComingMessage : Network.NetworkMessage;

      NewMessageAvailable : Boolean;
   begin

      Icd1.totalTick := Icd1.totalTick+1;

      ImpulseGenerator.SetImpulse(Gen1,0);

      -- at the beginning the response is unavailable
      Icd1.ResponseAvailable := False;
      -- judge whether it is the first tick
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

      Network.GetNewMessage(Network1, NewMessageAvailable, ComingMessage);

      --handle the message

      if NewMessageAvailable then

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


            when ChangeSettingsRequest =>
               if Icd1.IsOn = False  then
                  Icd1.ResponseAvailable :=true;
                  Icd1.ResponseMessage := ProcessMessage(ComingMessage,Icd1);

               end if;

               when others =>
            raise Ada.Assertions.Assertion_Error;
         end case;
         if Icd1.ResponseAvailable then
            Network.SendMessage(Network1,Icd1.ResponseMessage);
         end if;


      end if;

      if Icd1.IsOn then
         if Icd1.NImpulse /= 0 then
            Put_Line("Need more impulse");

            --If this is not the tick that we should send impluse signal, just pass
            if Icd1.NTick /= Icd1.AvgTick then
               Icd1.NTick := Icd1.NTick +1;

               --Else send the signal and signal counter +1, reset tick counter
            else
               Put("Sending impulse ");
               Put(Item => Icd1.NImpulse);
               New_Line;
               ImpulseGenerator.SetImpulse(Gen1,2);
               Icd1.NImpulse := Icd1.NImpulse +1;
               Icd1.NTick := 0;
            end if;

            --Was that the last signal I need to send?
            if Icd1.NImpulse = 10 then
               Icd1.NImpulse := 0;
            end if;

         else
            Put("passing tick");New_Line;
            if Icd1.IsFirstTick = False then
               CheckAvg(Icd1,Gen1);
               CheckMax(Icd1,Gen1);
            end if;
         end if;
      end if;





   end Tick;


   procedure CheckMax(Icd: in out ICDType; Gen: out ImpulseGenerator.GeneratorType) is
   begin
      if Icd.rateCurrent.Rate >= Icd.Tachy then
         Put("Max reached");New_Line;
         Icd.AvgTick := 600 / (Icd.rateCurrent.Rate + 15);
         ImpulseGenerator.SetImpulse(Gen,2);
         Icd.NImpulse := 1;
      end if;

   end CheckMax;


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
      if AvgChange >= 10 then
         Put("avgchng reached");New_Line;
         ImpulseGenerator.SetImpulse(Gen,Icd.Joules);
      end if;
   end CheckAvg;


   function CheckAuthority(Icd : ICDType; Msg: Network.NetworkMessage) return Boolean is
      Source : Principal.PrincipalPtr;
   begin
      case Msg.MessageType is
         when ModeOn =>
            Source := Msg.MOnSource;
            --Put_Line(Item => Principal.PrincipalPtrToString(P => Source));
            for i in Icd.Prins'Range loop
               if Source = Icd.Prins(i) and
                 (Principal.HasRole(Source.all,Principal.Cardiologist) or
                  Principal.HasRole(Source.all,Principal.ClinicalAssistant))then
                  return True;
               end if;
            end loop;

         when ModeOff =>
            Source := Msg.MOffSource;
            --Put_Line(Item => Principal.PrincipalPtrToString(P => Source));
            for i in Icd.Prins'Range loop
               if Source = Icd.Prins(i) and
                 (Principal.HasRole(Source.all,Principal.Cardiologist) or
                  Principal.HasRole(Source.all,Principal.ClinicalAssistant))then
                  return True;
               end if;
            end loop;

         when ReadRateHistoryRequest =>
            Source := Msg.HSource;
            --Put_Line(Item => Principal.PrincipalPtrToString(P => Source));
            for i in Icd.Prins'Range loop
               if Source = Icd.Prins(i) then
                  return True;
               end if;
            end loop;

         when ReadSettingsRequest =>
            Source := Msg.RSource;
            --Put_Line(Item => Principal.PrincipalPtrToString(P => Source));
            for i in Icd.Prins'Range loop
               if Source = Icd.Prins(i) and
                 (Principal.HasRole(Source.all,Principal.Cardiologist) or
                  Principal.HasRole(Source.all,Principal.ClinicalAssistant))then
                  return True;
               end if;
            end loop;

         when ChangeSettingsRequest =>
            Source := Msg.CSource;
            --Put_Line(Item => Principal.PrincipalPtrToString(P => Source));
            for i in Icd.Prins'Range loop
               if Source = Icd.Prins(i) and
                 Principal.HasRole(Source.all,Principal.Cardiologist)then
                  return True;
               end if;
            end loop;

         when others =>
            raise Ada.Assertions.Assertion_Error;
      end case;

      return False;
   end CheckAuthority;


end ICD;

