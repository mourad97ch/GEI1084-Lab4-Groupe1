library ieee;
use ieee.std_logic_1164.all;
entity mp1_system is
 generic(PROGRAM_FILE : string := "Program.hex");
  port (
    CLK, Reset : in std_logic;
    
    RegState : out std_logic_vector(479 downto 0);
    PC, Instr, ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ALUFlags, Flags : out std_logic_vector(3 downto 0);
    FlagWrite : out std_logic_vector(1 downto 0);
    CondEx, RegWrite, MemWrite, PCSrc : out std_logic
  );
end entity;
architecture structural of mp1_system is
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
component instruction_rom
 generic(PROGRAM_FILE : string := "Program.hex"; WORDS : positive := 256);
 port(PC : in std_logic_vector(31 downto 0); Instr : out std_logic_vector(31 downto 0));
end component;
signal pc_s, instruction_s : std_logic_vector(31 downto 0);
begin
rom_unit : instruction_rom generic map(PROGRAM_FILE=>PROGRAM_FILE) port map(PC=>pc_s,Instr=>instruction_s);
cpu_unit : arm_mp1 port map(CLK=>CLK,Reset=>Reset,Instruction=>instruction_s,RegState=>RegState,PC=>pc_s,Instr=>Instr,ALUResult=>ALUResult,WriteData=>WriteData,ALUFlags=>ALUFlags,Flags=>Flags,FlagWrite=>FlagWrite,CondEx=>CondEx,RegWrite=>RegWrite,MemWrite=>MemWrite,PCSrc=>PCSrc);
PC<=pc_s;
end architecture;
