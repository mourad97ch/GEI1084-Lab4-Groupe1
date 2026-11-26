library ieee;
use ieee.std_logic_1164.all;

entity alu_flags is
    port (
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
        RESULT     : in  std_logic_vector(31 downto 0);
        SUM31      : in  std_logic;
        CARRY_IN   : in  std_logic;
        ARITHMETIC : in  std_logic;
        SUBTRACT   : in  std_logic;
        FLAGS      : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of alu_flags is
begin
    -- Harris, figure 5.17, pages 250-251 : equations dans l'ordre N, Z, C, V.
    FLAGS(3) <= RESULT(31);
    FLAGS(2) <= '1' when RESULT = x"00000000" else '0';
    FLAGS(1) <= CARRY_IN and ARITHMETIC;
    FLAGS(0) <= not (A(31) xor B(31) xor SUBTRACT)
                and (A(31) xor SUM31) and ARITHMETIC;
end architecture;
