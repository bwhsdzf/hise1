pragma Warnings (Off);
pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b__manualoperationexample.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b__manualoperationexample.adb");
pragma Suppress (Overflow_Check);
with Ada.Exceptions;

package body ada_main is

   E015 : Short_Integer; pragma Import (Ada, E015, "system__soft_links_E");
   E025 : Short_Integer; pragma Import (Ada, E025, "system__exception_table_E");
   E027 : Short_Integer; pragma Import (Ada, E027, "system__exceptions_E");
   E019 : Short_Integer; pragma Import (Ada, E019, "system__secondary_stack_E");
   E152 : Short_Integer; pragma Import (Ada, E152, "ada__containers_E");
   E065 : Short_Integer; pragma Import (Ada, E065, "ada__io_exceptions_E");
   E118 : Short_Integer; pragma Import (Ada, E118, "ada__numerics_E");
   E054 : Short_Integer; pragma Import (Ada, E054, "interfaces__c_E");
   E088 : Short_Integer; pragma Import (Ada, E088, "system__os_lib_E");
   E067 : Short_Integer; pragma Import (Ada, E067, "ada__tags_E");
   E064 : Short_Integer; pragma Import (Ada, E064, "ada__streams_E");
   E091 : Short_Integer; pragma Import (Ada, E091, "system__file_control_block_E");
   E086 : Short_Integer; pragma Import (Ada, E086, "system__finalization_root_E");
   E084 : Short_Integer; pragma Import (Ada, E084, "ada__finalization_E");
   E083 : Short_Integer; pragma Import (Ada, E083, "system__file_io_E");
   E008 : Short_Integer; pragma Import (Ada, E008, "ada__calendar_E");
   E006 : Short_Integer; pragma Import (Ada, E006, "ada__calendar__delays_E");
   E062 : Short_Integer; pragma Import (Ada, E062, "ada__text_io_E");
   E143 : Short_Integer; pragma Import (Ada, E143, "system__assertions_E");
   E135 : Short_Integer; pragma Import (Ada, E135, "system__random_seed_E");
   E115 : Short_Integer; pragma Import (Ada, E115, "measures_E");
   E149 : Short_Integer; pragma Import (Ada, E149, "principal_E");
   E117 : Short_Integer; pragma Import (Ada, E117, "randomnumber_E");
   E113 : Short_Integer; pragma Import (Ada, E113, "heart_E");
   E137 : Short_Integer; pragma Import (Ada, E137, "hrm_E");
   E145 : Short_Integer; pragma Import (Ada, E145, "impulsegenerator_E");
   E147 : Short_Integer; pragma Import (Ada, E147, "network_E");
   E139 : Short_Integer; pragma Import (Ada, E139, "icd_E");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
   begin
      E062 := E062 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "ada__text_io__finalize_spec");
      begin
         F1;
      end;
      declare
         procedure F2;
         pragma Import (Ada, F2, "system__file_io__finalize_body");
      begin
         E083 := E083 - 1;
         F2;
      end;
      declare
         procedure Reraise_Library_Exception_If_Any;
            pragma Import (Ada, Reraise_Library_Exception_If_Any, "__gnat_reraise_library_exception_if_any");
      begin
         Reraise_Library_Exception_If_Any;
      end;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");

      procedure Runtime_Finalize;
      pragma Import (C, Runtime_Finalize, "__gnat_runtime_finalize");

   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      Runtime_Finalize;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");
      Bind_Env_Addr : System.Address;
      pragma Import (C, Bind_Env_Addr, "__gl_bind_env_addr");

      procedure Runtime_Initialize (Install_Handler : Integer);
      pragma Import (C, Runtime_Initialize, "__gnat_runtime_initialize");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      Runtime_Initialize (1);

      Finalize_Library_Objects := finalize_library'access;

      System.Soft_Links'Elab_Spec;
      System.Exception_Table'Elab_Body;
      E025 := E025 + 1;
      System.Exceptions'Elab_Spec;
      E027 := E027 + 1;
      System.Soft_Links'Elab_Body;
      E015 := E015 + 1;
      System.Secondary_Stack'Elab_Body;
      E019 := E019 + 1;
      Ada.Containers'Elab_Spec;
      E152 := E152 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E065 := E065 + 1;
      Ada.Numerics'Elab_Spec;
      E118 := E118 + 1;
      Interfaces.C'Elab_Spec;
      E054 := E054 + 1;
      System.Os_Lib'Elab_Body;
      E088 := E088 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Tags'Elab_Body;
      E067 := E067 + 1;
      Ada.Streams'Elab_Spec;
      E064 := E064 + 1;
      System.File_Control_Block'Elab_Spec;
      E091 := E091 + 1;
      System.Finalization_Root'Elab_Spec;
      E086 := E086 + 1;
      Ada.Finalization'Elab_Spec;
      E084 := E084 + 1;
      System.File_Io'Elab_Body;
      E083 := E083 + 1;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E008 := E008 + 1;
      Ada.Calendar.Delays'Elab_Body;
      E006 := E006 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E062 := E062 + 1;
      System.Assertions'Elab_Spec;
      E143 := E143 + 1;
      System.Random_Seed'Elab_Body;
      E135 := E135 + 1;
      E115 := E115 + 1;
      E149 := E149 + 1;
      Randomnumber'Elab_Body;
      E117 := E117 + 1;
      E113 := E113 + 1;
      E137 := E137 + 1;
      E145 := E145 + 1;
      Network'Elab_Body;
      E147 := E147 + 1;
      E139 := E139 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_manualoperationexample");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   /Users/JunjieHuang/Downloads/hise1/obj/measures.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/principal.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/randomnumber.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/heart.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/hrm.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/impulsegenerator.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/network.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/ICD.o
   --   /Users/JunjieHuang/Downloads/hise1/obj/manualoperationexample.o
   --   -L/Users/JunjieHuang/Downloads/hise1/obj/
   --   -L/Users/JunjieHuang/Downloads/hise1/obj/
   --   -L/users/junjiehuang/ada/lib/gcc/x86_64-apple-darwin14.5.0/6.3.1/adalib/
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
