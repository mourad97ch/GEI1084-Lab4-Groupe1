library ieee;
use ieee.std_logic_1164.all;
entity reg_enable is
  generic (WIDTH : positive := 32);
  port (
    CLK, Reset, Enable : in std_logic;
    D : in std_logic_vector(WIDTH-1 downto 0);
    Q : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity;

architecture rtl of reg_enable is
begin
  process(CLK, Reset)
  begin
    if Reset = '1' then
      Q <= (others => '0');
    elsif rising_edge(CLK) then
      if Enable = '1' then Q <= D; end if;
    end if;
  end process;
end architecture;
