with Ada.Text_IO; use Ada.Text_IO;

package body Rozwiazanie is

   task type KotrolaLotow(MAX : Positive) is
      entry Zajmij(SamolotID : in Integer);
      entry Zwolnij(SamolotID : in Integer);
      entry Wjedz(SamolotID : in Integer);
      entry Opusc(SamolotID : in Integer);
      
      entry ExtraEntryA(SamolotID : in Integer);
      entry ExtraEntryB(SamolotID : in Integer);
      entry ExtraEntryC(SamolotID : in Integer);
      entry ExtraEntryD(SamolotID : in Integer);
   end KotrolaLotow;

task body KotrolaLotow is
    Pas_Occupied : Boolean := False;
    Apron_Count : Integer := 0;
    Is_First : Boolean := True;
    Takeoff_Requests : Integer := 0;
    Landing_Requests : Integer := 0;
    Stop_Flag : Boolean := False;
    
    type Direction_Type is (none, take_off, landing);
    Current_Direction : Direction_Type := none;
    Planes_Direction : array (1 .. 32) of Direction_Type := (others => none);

    procedure Log(Message : String) is
    begin
        Ada.Text_IO.Put_Line(Message);
    end Log;

begin
    loop
        exit when Stop_Flag and Takeoff_Requests = 0 and Landing_Requests = 0 and Apron_Count = 0 and not Pas_Occupied;
        select
            when Apron_Count < MAX =>
                accept Wjedz(SamolotID : Integer) do
                    if Planes_Direction(SamolotID) = none then
                        Planes_Direction(SamolotID) := take_off;
                        Takeoff_Requests := Takeoff_Requests + 1;
                        if Is_First then
                            Current_Direction := take_off;
                            Is_First := False;
                        end if;
                    end if;
                    if Planes_Direction(SamolotID) = take_off then
                        if Current_Direction = landing or Apron_Count >= MAX then
                            requeue ExtraEntryA;
                        end if;
  
                        Log("Wjedz TAKE-OFF accepted for Plane ID: " & Integer'Image(SamolotID));
                        Apron_Count := Apron_Count + 1;
                        Current_Direction := take_off;
                    end if;
                    if Planes_Direction(SamolotID) = landing then
                        Log("Wjedz LANDING accepted for Plane ID: " & Integer'Image(SamolotID));
                        Apron_Count := Apron_Count + 1;
                    end if;
                end Wjedz;
        or  
            when Apron_Count > 0 and Current_Direction = take_off =>
                accept Opusc(SamolotID : Integer) do
                    Log("Opusc TAKE-OFF accepted for Plane ID: " & Integer'Image(SamolotID));
                    Apron_Count := Apron_Count - 1;
                end Opusc;
        or
            when Pas_Occupied and Current_Direction = take_off =>
                accept Zwolnij(SamolotID : Integer) do
                    Log("Zwolnij TAKE-OFF accepted for Plane ID: " & Integer'Image(SamolotID));
                    Pas_Occupied := False;
                    Takeoff_Requests := Takeoff_Requests - 1;
                    Stop_Flag := True;
                    Planes_Direction(SamolotID) := none;
                    if Takeoff_Requests = 0 then
                        Current_Direction := none;
                    end if;
                end Zwolnij;
        or
            when (not Pas_Occupied) =>
                accept Zajmij(SamolotID : Integer) do
                    if Planes_Direction(SamolotID) = none then
                        Planes_Direction(SamolotID) := landing;
                        Landing_Requests := Landing_Requests + 1;
                        if Is_First then
                            Current_Direction := landing;
                            Is_First := False;
                        end if;
                    end if;
                    if Planes_Direction(SamolotID) = landing then
                        if Current_Direction = take_off or Apron_Count >= MAX then
                            requeue ExtraEntryB;
                        end if;
                        
                        Pas_Occupied := True;
                        Current_Direction := landing;
                        Log("Zajmij LANDING accepted for Plane ID: " & Integer'Image(SamolotID));
                    end if;
                    if Planes_Direction(SamolotID) = take_off then
                        Log("Zajmij TAKE-OFF accepted for Plane ID: " & Integer'Image(SamolotID));
                        Pas_Occupied := True;
                    end if;
                    
                end Zajmij;
        or
            when Pas_Occupied and Current_Direction = landing =>
                accept Zwolnij(SamolotID : Integer) do
                    Log("Zwolnij LANDING accepted for Plane ID: " & Integer'Image(SamolotID));
                    Pas_Occupied := False;
                end Zwolnij;
        or
            when Apron_Count > 0 and Current_Direction = landing =>
                accept Opusc(SamolotID : Integer) do
                    Log("Opusc LANDING accepted for Plane ID: " & Integer'Image(SamolotID));
                    
                    Apron_Count := Apron_Count - 1;
                    Landing_Requests := Landing_Requests - 1;
                    Stop_Flag := True;
                    Planes_Direction(SamolotID) := none;
                    if Landing_Requests = 0 then
                        Current_Direction := none;
                    end if;
                end Opusc;
        or
            accept ExtraEntryB(SamolotID : Integer) do
                Log("waiting. Plane ID: " & Integer'Image(SamolotID));
                delay 0.02;
                requeue Zajmij;
            end ExtraEntryB;
        or
            accept ExtraEntryA(SamolotID : Integer) do
                Log("waiting. Plane ID: " & Integer'Image(SamolotID));
                delay 0.02;
                requeue Wjedz;
            end ExtraEntryA;
        end select;
    end loop;
    Log("end of loop");
end KotrolaLotow;




-- Define a task type for airplanes
task type Samolot(KL : access KotrolaLotow; ID : Integer; Typ : Character);

task body Samolot is
begin
    if Typ = 'S' then  -- Взлет
        Put_Line("Plane " & Integer'Image(ID) & " requesting to enter apron for takeoff.");
        KL.Wjedz(ID);
        delay 0.05;  -- Preparing for takeoff
        Put_Line("Plane " & Integer'Image(ID) & " requesting to occupy the runway.");
        KL.Zajmij(ID);
        delay 0.05;  -- Simulating time on the runway
        Put_Line("Plane " & Integer'Image(ID) & " requesting to leave the apron.");
        KL.Opusc(ID);
        delay 0.05;  -- Preparing to free the runway
        Put_Line("Plane " & Integer'Image(ID) & " requesting to free the runway.");
        KL.Zwolnij(ID);
    else  -- Посадка
        Put_Line("Plane " & Integer'Image(ID) & " requesting to occupy the runway for landing.");
        KL.Zajmij(ID);
        delay 0.05;  -- Simulating landing time
        Put_Line("Plane " & Integer'Image(ID) & " requesting to enter the apron.");
        KL.Wjedz(ID);
        delay 0.05;  -- Preparing to leave the runway
        Put_Line("Plane " & Integer'Image(ID) & " requesting to free the runway.");
        KL.Zwolnij(ID);
        delay 0.05;  -- Simulating time on the apron
        Put_Line("Plane " & Integer'Image(ID) & " requesting to leave the apron.");
        KL.Opusc(ID);
    end if;
    Put_Line("Plane " & Integer'Image(ID) & " finished its operations.");
end Samolot;


    MyKotrolaLotow : aliased KotrolaLotow(MAX => 1);

   Plane1 : Samolot(MyKotrolaLotow'Access, 1, 'S');
   Plane2 : Samolot(MyKotrolaLotow'Access, 2, 'L');
   Plane3 : Samolot(MyKotrolaLotow'Access, 3, 'S');
   Plane4 : Samolot(MyKotrolaLotow'Access, 4, 'L');
   Plane5 : Samolot(MyKotrolaLotow'Access, 5, 'S');
   Plane6 : Samolot(MyKotrolaLotow'Access, 6, 'L');
   Plane7 : Samolot(MyKotrolaLotow'Access, 7, 'S');
   Plane8 : Samolot(MyKotrolaLotow'Access, 8, 'L');
   Plane9 : Samolot(MyKotrolaLotow'Access, 9, 'S');
   Plane10 : Samolot(MyKotrolaLotow'Access, 10, 'L');
   Plane11 : Samolot(MyKotrolaLotow'Access, 11, 'S');
   Plane12 : Samolot(MyKotrolaLotow'Access, 12, 'L');
   Plane13 : Samolot(MyKotrolaLotow'Access, 13, 'S');
   Plane14 : Samolot(MyKotrolaLotow'Access, 14, 'L');
   Plane15 : Samolot(MyKotrolaLotow'Access, 15, 'S');
   Plane16 : Samolot(MyKotrolaLotow'Access, 16, 'L');
   Plane17 : Samolot(MyKotrolaLotow'Access, 17, 'S');
   Plane18 : Samolot(MyKotrolaLotow'Access, 18, 'L');
   Plane19 : Samolot(MyKotrolaLotow'Access, 19, 'S');
   Plane20 : Samolot(MyKotrolaLotow'Access, 20, 'L');
   Plane21 : Samolot(MyKotrolaLotow'Access, 21, 'S');
   Plane22 : Samolot(MyKotrolaLotow'Access, 22, 'L');
   Plane23 : Samolot(MyKotrolaLotow'Access, 23, 'S');
   Plane24 : Samolot(MyKotrolaLotow'Access, 24, 'L');
   Plane25 : Samolot(MyKotrolaLotow'Access, 25, 'S');
   Plane26 : Samolot(MyKotrolaLotow'Access, 26, 'L');
   Plane27 : Samolot(MyKotrolaLotow'Access, 27, 'S');
   Plane28 : Samolot(MyKotrolaLotow'Access, 28, 'L');
   Plane29 : Samolot(MyKotrolaLotow'Access, 29, 'S');
   Plane30 : Samolot(MyKotrolaLotow'Access, 30, 'L');
   Plane31 : Samolot(MyKotrolaLotow'Access, 31, 'S');
   Plane32 : Samolot(MyKotrolaLotow'Access, 32, 'L');
begin
   delay 10.0;
   Put_Line("Program finished.");
end Rozwiazanie;
