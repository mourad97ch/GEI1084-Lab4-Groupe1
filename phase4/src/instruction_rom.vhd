library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
entity instruction_rom is
 generic (PROGRAM_FILE : string := "Program.hex"; WORDS : positive := 256);
 port (PC : in std_logic_vector(31 downto 0);
       Instr : out std_logic_vector(31 downto 0));
end entity;
architecture simulation_ready of instruction_rom is
 type memory_t is array(0 to WORDS-1) of std_logic_vector(31 downto 0);
 impure function initialize return memory_t is
   file f : text open read_mode is PROGRAM_FILE;
   variable m : memory_t := (others => x"EC000000");
   variable l : line;
   variable i : natural := 0;
 begin
   while not endfile(f) loop
     assert i < WORDS report "Instruction ROM overflow" severity failure;
     readline(f,l); hread(l,m(i)); i := i+1;
   end loop;
   return m;
 end;
 constant memory : memory_t := initialize;
begin
 process(all)
   variable address : natural;
 begin
   Instr <= x"EC000000";
   if not is_x(PC) then
     address := to_integer(unsigned(PC(31 downto 2)));
     if address < WORDS then Instr <= memory(address); end if;
   end if;
 end process;
end architecture;
