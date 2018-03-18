with HRM; use HRM;
with ImpulseGenerator; use ImpulseGenerator;
with Measures;
with Network; use Network;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Assertions;
with Principal; use type Principal.PrincipalPtr;

package body ICD is

   procedure Init(Icd : out ICDType; KnownPrins : access PrincipalArray) is
   begin
      Icd.IsOn := False;
      Icd.Tachy := 100;
      Icd.Joules := 30;

      Icd.Prins := new PrincipalArray(KnownPrins'First..KnownPrins'Last);
      for i in KnownPrins'Range loop
         Icd.Prins(i) := KnownPrins(i);
      end loop;


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
   end SetBound;

   procedure SetJoules(Icd: in out ICDType; J:in Integer) is
      newJ : Measures.Joules;
   begin
      newJ := Measures.LimitJoules(J);
      Icd.Joules := newJ;
   end SetJoules;


   function GetHistory(Icd: in ICDType) return Network.RateHistory is
      RH : Network.RateHistory;
   begin
      RH(1) := Icd.Rate1;
      RH(2) := Icd.Rate2;
      RH(3) := Icd.Rate3;
      RH(4) := Icd.Rate4;
      RH(5) := Icd.Rate5;
      return RH;
   end GetHistory;


   function ProcessMessage(Msg: in out Network.NetworkMessage; Icd: in out ICDType)
                           return Network.NetworkMessage is
   begin
      case Msg.MessageType is
         when ModeOn =>
            On(Icd);
            return (MessageType => ModeOn,
                    MOnSource => Msg.MOnSource);

         when ModeOff =>
            Off(Icd);
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

   procedure Tick (Icd1: in out ICDType; Network1: in out Network.Network; Hrm1: in HRMType; Gen1: in GeneratorType)
   is
      ComingMessage : Network.NetworkMessage;

      NewMessageAvailable : Boolean;



   begin

      Icd1.totalTick := Icd1.totalTick+1;

      -- at the beginning the response is unavailable
      Icd1.ResponseAvailable := False;

      if Icd1.IsFirstTick then
         GetRate(Hrm1,Icd1.rateCurrent.Rate);
         Icd1.rate5 := Icd1.rateCurrent;
         Icd1.rate4 := Icd1.rateCurrent;
         Icd1.rate3 := Icd1.rateCurrent;
         Icd1.rate2 := Icd1.rateCurrent;
         Icd1.rate1 := Icd1.rateCurrent;

         Icd1.IsFirstTick := False;
      else

         Icd1.rate1 := Icd1.rate2;
         Icd1.rate2 := Icd1.rate3;
         Icd1.rate3 := Icd1.rate4;
         Icd1.rate4 := Icd1.rate5;
         Icd1.rate5 := Icd1.rateCurrent;
         GetRate(Hrm1,Icd1.rateCurrent.Rate);


      end if;

      Network.GetNewMessage(Network1, NewMessageAvailable, ComingMessage);

      --handle the message

      if NewMessageAvailable then

         case ComingMessage.MessageType is
            when ModeOn =>
               Put("d");
            when ModeOff =>
               Put("d");

            when ChangeSettingsResponse =>
                 Put("d");
            when ReadRateHistoryResponse =>
               Put("d");
            when ReadSettingsResponse =>
               Put("d");

            when ReadRateHistoryRequest =>
               if Icd1.IsOn = true  then

               Put("hi");
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


         end case;
      end if;


   end Tick;


   procedure CheckMax(Gen: out ImpulseGenerator.GeneratorType) is
   begin
      Put("hi");
   end CheckMax;


   procedure CheckAvg(Icd: ICDType; Gen: in out ImpulseGenerator.GeneratorType) is
      AvgChange : Integer;
   begin
      AvgChange := abs (Icd.Rate2.Rate - Icd.Rate1.Rate) +
      abs (Icd.Rate3.Rate - Icd.Rate2.Rate) +
      abs (Icd.Rate4.Rate - Icd.Rate3.Rate) +
      abs (Icd.Rate5.Rate - Icd.Rate4.Rate);
      AvgChange := AvgChange/5;
      if AvgChange > 10 then
         ImpulseGenerator.SetImpulse(Gen,2);
      end if;
   end CheckAvg;


   function CheckAuthority(Icd : ICDType; Msg: Network.NetworkMessage) return Boolean is
      Source : Principal.PrincipalPtr;
   begin
      case Msg.MessageType is
         when ModeOn =>
            Source := Msg.MOnSource;

         when ModeOff =>
            Source := Msg.MOffSource;

         when ReadRateHistoryRequest =>
            Source := Msg.HSource;

         when ReadSettingsRequest =>
            Source := Msg.RSource;

         when ChangeSettingsRequest =>
            Source := Msg.CSource;

         when others =>
            raise Ada.Assertions.Assertion_Error;
      end case;

      for i in Icd.Prins'Range loop
         if Source = Icd.Prins(i) then
            return True;
         end if;
      end loop;
      return False;
   end CheckAuthority;


end ICD;

