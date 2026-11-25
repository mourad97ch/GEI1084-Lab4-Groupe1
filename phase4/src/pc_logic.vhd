library ieee;
use ieee.std_logic_1164.all;

entity pc_logic is
  port (
    Rd : in std_logic_vector(3 downto 0);
    RegW, Branch : in std_logic;
    PCSrc : out std_logic
  );
end entity;

architecture rtl of pc_logic is
begin
  PCSrc <= '1' when Branch = '1' or (Rd = "1111" and RegW = '1')
           else '0';
end architecture;
