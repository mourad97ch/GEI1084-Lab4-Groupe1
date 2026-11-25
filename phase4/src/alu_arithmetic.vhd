library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_arithmetic is
    port (
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
        SUBTRACT   : in  std_logic;
        ARITHMETIC : out std_logic_vector(31 downto 0);
        CARRY      : out std_logic
    );
end entity;

architecture rtl of alu_arithmetic is
    -- Harris, figures 5.15 et 5.17 : B ou not B, puis A + B_effectif + Cin.
    signal b_effectif : std_logic_vector(31 downto 0);
    signal retenue_entree : unsigned(32 downto 0);
    signal somme : unsigned(32 downto 0);
begin
    -- Multiplexeur : B pour additionner, not(B) pour soustraire.
    with SUBTRACT select
        b_effectif <= B     when '0',
                      not B when '1',
                      (others => 'X') when others;

    -- Additionneur sur 33 bits : A + B_effectif + Cin.
    retenue_entree <= (0 => SUBTRACT, others => '0');
    somme <= ('0' & unsigned(A)) + ('0' & unsigned(b_effectif)) + retenue_entree;

    ARITHMETIC <= std_logic_vector(somme(31 downto 0));
    CARRY <= somme(32);
end architecture;
