library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tb_bl is end entity;
architecture simulation of tb_bl is
component mp1_system
 generic(PROGRAM_FILE : string := "Program.hex");
  port (
    CLK, Reset : in std_logic;

    RegState : out std_logic_vector(479 downto 0);
    PC, Instr, ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ALUFlags, Flags : out std_logic_vector(3 downto 0);
    FlagWrite : out std_logic_vector(1 downto 0);
    CondEx, RegWrite, MemWrite, PCSrc : out std_logic
  );
end component;
signal CLK : std_logic := '0';
signal Reset : std_logic := '1';
signal RegState : std_logic_vector(479 downto 0);
signal R14 : std_logic_vector(31 downto 0);
signal PC, Instr, ALUResult, WriteData : std_logic_vector(31 downto 0);
signal ALUFlags, Flags : std_logic_vector(3 downto 0);
signal FlagWrite : std_logic_vector(1 downto 0);
signal CondEx, RegWrite, MemWrite, PCSrc : std_logic;
signal Test_number, Error_count : natural := 0;
signal Done : boolean := false;
signal CLK_EQ : std_logic := '0';
signal Reset_EQ : std_logic := '1';
signal RegState_EQ : std_logic_vector(479 downto 0);
signal PC_EQ, Instr_EQ, ALUResult_EQ, WriteData_EQ : std_logic_vector(31 downto 0);
signal ALUFlags_EQ, Flags_EQ : std_logic_vector(3 downto 0);
signal FlagWrite_EQ : std_logic_vector(1 downto 0);
signal CondEx_EQ, RegWrite_EQ, MemWrite_EQ, PCSrc_EQ : std_logic;
signal Test_number_EQ, Error_count_EQ : natural := 0;
signal Done_EQ : boolean := false;
type nat_array is array(1 to 8) of natural;
constant pcs : nat_array := (0,16,20,4,24,28,36,32);
constant next_pcs : nat_array := (16,20,4,24,28,36,32,36);
constant links : nat_array := (4,4,4,4,4,32,32,32);
type eq_address_array is array(1 to 5) of natural;
constant eq_pcs : eq_address_array := (0,4,20,24,8);
constant eq_next_pcs : eq_address_array := (4,20,24,8,12);
begin
R14 <= RegState(479 downto 448);
CLK <= not CLK after 5 ns when not Done else '0';
Reset <= '0' after 22 ns;
CLK_EQ <= not CLK_EQ after 5 ns when not Done_EQ else '0';
Reset_EQ <= '0' after 22 ns;
dut : mp1_system generic map(PROGRAM_FILE=>"BL.hex") port map(
CLK=>CLK,Reset=>Reset,RegState=>RegState,PC=>PC,Instr=>Instr,
ALUResult=>ALUResult,WriteData=>WriteData,ALUFlags=>ALUFlags,Flags=>Flags,
FlagWrite=>FlagWrite,CondEx=>CondEx,RegWrite=>RegWrite,MemWrite=>MemWrite,PCSrc=>PCSrc);
dut_eq : mp1_system generic map(PROGRAM_FILE=>"BL_EQ.hex") port map(
CLK=>CLK_EQ,Reset=>Reset_EQ,RegState=>RegState_EQ,PC=>PC_EQ,Instr=>Instr_EQ,
ALUResult=>ALUResult_EQ,WriteData=>WriteData_EQ,ALUFlags=>ALUFlags_EQ,
Flags=>Flags_EQ,FlagWrite=>FlagWrite_EQ,CondEx=>CondEx_EQ,
RegWrite=>RegWrite_EQ,MemWrite=>MemWrite_EQ,PCSrc=>PCSrc_EQ);
stimulus : process
variable errors : natural := 0;
variable before_regs : std_logic_vector(479 downto 0);
procedure check(constant ok : boolean; constant msg : string) is
begin
 if not ok then errors:=errors+1; report msg severity warning; end if;
end procedure;
begin
wait until Reset='0';
for i in 1 to 8 loop
 Test_number<=i;
 wait until rising_edge(CLK);
 check(PC=std_logic_vector(to_unsigned(pcs(i),32)),"PC before execution");
 before_regs:=RegState;
 check(MemWrite='0',"Unexpected memory write");
 if i=1 or i=6 then
  check(PCSrc='1' and RegWrite='1' and CondEx='1',"BL controls");
 elsif i=5 then
  check(PCSrc='0' and RegWrite='0' and CondEx='0',"False BLEQ controls");
 elsif i=4 or i=7 then
  check(PCSrc='1' and RegWrite='0',"B must not write LR");
 elsif i=3 then
  check(PCSrc='1',"Return via PC failed");
 end if;
 wait for 1 ns;
 check(PC=std_logic_vector(to_unsigned(next_pcs(i),32)),"PC after execution");
 check(RegState(479 downto 448)=std_logic_vector(to_unsigned(links(i),32)),"LR after execution");
 check(Flags="0000","Unexpected saved Flags");
 if i=5 or i=4 or i=7 then
  check(RegState=before_regs,"B or false BL changed registers");
 end if;
 if i>=2 then check(RegState(63 downto 32)=x"00000007","R1 subroutine result"); end if;
 if i=8 then check(RegState(95 downto 64)=x"00000009","R2 result"); end if;
 Error_count<=errors;
end loop;
Done<=true;
report "BL: 8 executed instructions; errors: " & integer'image(errors) severity note;
assert errors=0 report "BL verification failed" severity failure;
wait;
end process;

eq_stimulus : process
variable errors : natural := 0;
begin
wait until Reset_EQ='0';
for i in eq_pcs'range loop
 Test_number_EQ<=i;
 wait until rising_edge(CLK_EQ);
 if PC_EQ/=std_logic_vector(to_unsigned(eq_pcs(i),32)) then
  errors:=errors+1; report "EQ BL PC before execution" severity warning;
 end if;
 case i is
  when 1 =>
   if Instr_EQ/=x"E2503000" or FlagWrite_EQ/="11" or ALUFlags_EQ/="0110" then
    errors:=errors+1; report "SUBS did not set flags before EQ BL" severity warning;
   end if;
  when 2 =>
   if Instr_EQ/=x"0B000002" or Flags_EQ/="0110" or CondEx_EQ/='1'
      or PCSrc_EQ/='1' or RegWrite_EQ/='1' then
    errors:=errors+1; report "EQ-true BL controls or flags are incorrect" severity warning;
   end if;
  when 3 =>
   if Instr_EQ/=x"E2802005" then
    errors:=errors+1; report "EQ BL did not reach its target" severity warning;
   end if;
  when 4 =>
   if Instr_EQ/=x"E28EF000" or PCSrc_EQ/='1' then
    errors:=errors+1; report "Return through LR failed" severity warning;
   end if;
  when 5 =>
   if Instr_EQ/=x"E2801009" then
    errors:=errors+1; report "EQ BL did not return to LR" severity warning;
   end if;
 end case;
 wait for 1 ns;
 if PC_EQ/=std_logic_vector(to_unsigned(eq_next_pcs(i),32)) then
  errors:=errors+1; report "EQ BL PC after execution" severity warning;
 end if;
 if i=1 and Flags_EQ/="0110" then
  errors:=errors+1; report "SUBS did not produce NZCV=0110" severity warning;
 end if;
 if i>=2 and RegState_EQ(479 downto 448)/=x"00000008" then
  errors:=errors+1; report "EQ BL did not preserve LR=PC+4" severity warning;
 end if;
 if i=3 and RegState_EQ(95 downto 64)/=x"00000005" then
  errors:=errors+1; report "EQ BL target instruction did not execute" severity warning;
 end if;
 if i=5 and RegState_EQ(63 downto 32)/=x"00000009" then
  errors:=errors+1; report "Instruction after LR return did not execute" severity warning;
 end if;
end loop;
Error_count_EQ<=errors;
Done_EQ<=true;
report "BL EQ-true: 1 conditional branch taken; errors: " & integer'image(errors)
 severity note;
assert errors=0 report "EQ-true BL verification failed" severity failure;
wait;
end process;
end architecture;
