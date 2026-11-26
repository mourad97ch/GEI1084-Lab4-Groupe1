library ieee;
use ieee.std_logic_1164.all;

entity alu_select is
    port (
        A, B, Sum  : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(1 downto 0);
        Result     : out std_logic_vector(31 downto 0)
    );
end entity;

architecture combinational of alu_select is
begin
    -- Harris, figure 5.15 : portes AND/OR et multiplexeur de sortie.
    with ALUControl select
        Result <= Sum     when "00",
                  Sum     when "01",
                  A and B when "10",
                  A or B  when "11",
                  (others => 'X') when others;
end architecture;
