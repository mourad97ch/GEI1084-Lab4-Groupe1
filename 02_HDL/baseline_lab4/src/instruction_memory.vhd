library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity instruction_memory is
  port (
    A : in std_logic_vector(4 downto 0);
    RD : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of instruction_memory is
  type rom_array is array (0 to 31) of std_logic_vector(31 downto 0);
  -- Words 0 to 19 come from the supplied Instructions.txt.
  constant rom : rom_array := (
     0 => x"E0400000",
     1 => x"E2802005",
     2 => x"E280300C",
     3 => x"E2437009",
     4 => x"E1874002",
     5 => x"E0035004",
     6 => x"E0855004",
     7 => x"E0558007",
     8 => x"E0538004",
     9 => x"E2805000",
    10 => x"E0578002",
    11 => x"B2857001",
    12 => x"E0477002",
    13 => x"E5837054",
    14 => x"E5902060",
    15 => x"E0885000",
    16 => x"E280200E",
    17 => x"E280200D",
    18 => x"E280200A",
    19 => x"E5802064",
    others => (others => '0')
  );
begin
  RD <= rom(to_integer(unsigned(A))) when not is_x(A) else (others => '0');
end architecture;
