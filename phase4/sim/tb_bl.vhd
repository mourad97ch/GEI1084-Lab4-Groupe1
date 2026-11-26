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
type nat_array is array(1 to 8) of natural;
constant pcs : nat_array := (0,16,20,4,24,28,36,32);
constant next_pcs : nat_array := (16,20,4,24,28,36,32,36);
constant links : nat_array := (4,4,4,4,4,32,32,32);
begin
R14 <= RegState(479 downto 448);
CLK <= not CLK after 5 ns when not Done else '0';
Reset <= '0' after 22 ns;
dut : mp1_system generic map(PROGRAM_FILE=>"BL.hex") port map(
CLK=>CLK,Reset=>Reset,RegState=>RegState,PC=>PC,Instr=>Instr,
ALUResult=>ALUResult,WriteData=>WriteData,ALUFlags=>ALUFlags,Flags=>Flags,
FlagWrite=>FlagWrite,CondEx=>CondEx,RegWrite=>RegWrite,MemWrite=>MemWrite,PCSrc=>PCSrc);
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
end architecture;
