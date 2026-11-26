library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity tb_cmp_catalog is
 generic(PROGRAM_FILE:string:="Program.hex"; EXPECTED_FILE:string:="Trace.txt"; TEST_ID:string:="TEST");
end entity;
architecture verification of tb_cmp_catalog is
component arm_mp1
port (
    CLK, Reset : in std_logic;
    Instruction : in std_logic_vector(31 downto 0);
    RegState : out std_logic_vector(479 downto 0);
    PC, Instr, ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ALUFlags, Flags : out std_logic_vector(3 downto 0);
    FlagWrite : out std_logic_vector(1 downto 0);
    CondEx, RegWrite, MemWrite, PCSrc : out std_logic
  );
end component;

 component instruction_rom is
  generic(PROGRAM_FILE:string:="Program.hex";WORDS:positive:=256);
  port(PC:in std_logic_vector(31 downto 0);Instr:out std_logic_vector(31 downto 0));
 end component;
 signal CLK : std_logic:='0';
 signal Reset : std_logic:='1';
 signal Done : boolean:=false;
 signal PC,Instruction,Instr,ALUResult,WriteData:std_logic_vector(31 downto 0);
 signal ALUFlags,Flags:std_logic_vector(3 downto 0);
 signal FlagWrite:std_logic_vector(1 downto 0);
 signal CondEx,RegWrite,MemWrite,PCSrc:std_logic;
 signal RegState:std_logic_vector(479 downto 0);
 signal Error_count,Test_number:natural:=0;
begin
 CLK<=not CLK after 5 ns when not Done else '0';
 Reset<='0' after 22 ns;
 rom_unit:instruction_rom generic map(PROGRAM_FILE=>PROGRAM_FILE)
   port map(PC=>PC,Instr=>Instruction);
 dut:arm_mp1 port map(CLK=>CLK,Reset=>Reset,Instruction=>Instruction,RegState=>RegState,
   PC=>PC,Instr=>Instr,ALUResult=>ALUResult,WriteData=>WriteData,
   ALUFlags=>ALUFlags,Flags=>Flags,FlagWrite=>FlagWrite,
   CondEx=>CondEx,RegWrite=>RegWrite,MemWrite=>MemWrite,PCSrc=>PCSrc);
 stimulus:process
  file f:text open read_mode is EXPECTED_FILE;
  variable l:line;
  variable v:std_logic_vector(31 downto 0);
  variable reg_expected:std_logic_vector(479 downto 0);
  variable nextpc:std_logic_vector(31 downto 0);
  variable flags_before,flags_after:std_logic_vector(3 downto 0);
  variable rw,mw,ps,fw,ce:integer;
  variable good:boolean;
  variable cycles,errors:natural:=0;
 begin
  wait until Reset='0';
  while not endfile(f) loop
   wait until rising_edge(CLK);
   readline(f,l);cycles:=cycles+1;Test_number<=cycles;good:=true;
   hread(l,v);good:=good and PC=v;
   hread(l,v);good:=good and Instr=v;
   hread(l,v);good:=good and ALUResult=v;
   hread(l,v);good:=good and WriteData=v;
   hread(l,flags_before);good:=good and Flags=flags_before;
   read(l,rw);read(l,mw);read(l,ps);read(l,fw);read(l,ce);
   good:=good and RegWrite=std_logic'val(rw+2) and MemWrite=std_logic'val(mw+2)
     and PCSrc=std_logic'val(ps+2) and CondEx=std_logic'val(ce+2)
     and FlagWrite=std_logic_vector(to_unsigned(fw,2));
   hread(l,nextpc);hread(l,flags_after);
   for i in 0 to 14 loop hread(l,reg_expected(32*i+31 downto 32*i));end loop;
   wait for 1 ns;
   good:=good and PC=nextpc and Flags=flags_after and RegState=reg_expected;
   if not good then
    errors:=errors+1;Error_count<=errors;
    report TEST_ID & " cycle " & integer'image(cycles) &
      " FAIL PC_after=" & to_hstring(PC) & " expected=" & to_hstring(nextpc) &
      " LR=" & to_hstring(RegState(479 downto 448)) severity warning;
   end if;
  end loop;
  Done<=true;
  report TEST_ID & " cycles=" & integer'image(cycles) & " errors=" & integer'image(errors) severity note;
  assert errors=0 report TEST_ID & " FAILED" severity error;
  wait;
 end process;
end architecture;
