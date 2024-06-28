with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Hello is
   task type SemaphoreCounts (initValue : Integer) is
      entry P;
      entry V;
      entry GetValue (val : out Integer);
   end SemaphoreCounts;

   task body SemaphoreCounts is
      curr : Integer := initValue;
   begin
      loop
         select
            when curr > 0 =>
               accept P do
                  curr := curr - 1;
               end P;
            or
               accept V do
                  curr := curr + 1;
               end V;
            or
               accept GetValue(val : out Integer) do
                  val := curr;
               end GetValue;
         or
            delay 1.0;
         end select;
      end loop;
   end SemaphoreCounts;

   S1 : SemaphoreCounts (3);
   S2 : SemaphoreCounts (1);
   
   procedure SemaphoreTest(Sem : in out SemaphoreCounts) is
      val : Integer;
   begin
      Sem.GetValue(val);
      Put_Line("initial value: " & Integer'Image(val));
      
      Sem.P;
      Sem.GetValue(val);
      Put_Line("after P: " & Integer'Image(val));
      
      Sem.V;
      Sem.GetValue(val);
      Put_Line("after V: " & Integer'Image(val));
   end SemaphoreTest;

begin
    Put_Line("====testing S1====");
    SemaphoreTest(S1);

    Put_Line("====testing S2====");
    SemaphoreTest(S2);

    delay 2.0;

    declare
       val : Integer;
    begin
       S1.GetValue(val);
       Put ("S1 final value: ");
       Put(val, 0);
       New_Line;

       S2.GetValue(val);
       Put ("S2 final value: ");
       Put(val, 0);
       New_Line;
    end;
end Hello;
