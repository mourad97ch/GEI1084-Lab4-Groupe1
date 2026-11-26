library ieee;
use ieee.std_logic_1164.all;

entity extend is
    port (
        Instr  : in  std_logic_vector(23 downto 0);
        ImmSrc : in  std_logic_vector(1 downto 0);
        ExtImm : out std_logic_vector(31 downto 0)
    );
end entity;

architecture combinational of extend is
begin

    with ImmSrc select
        ExtImm <= x"000000" & Instr(7 downto 0)
                      when "00",

                  x"00000" & Instr(11 downto 0)
                      when "01",

                  (31 downto 26 => Instr(23)) & Instr(23 downto 0) & "00"
                      when "10",

                  (others => '0')
                      when others;

end architecture;