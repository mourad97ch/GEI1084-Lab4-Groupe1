library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is
    port (
        CLK      : in  std_logic;
        RegWrite : in  std_logic;

        RA1      : in  std_logic_vector(3 downto 0);
        RA2      : in  std_logic_vector(3 downto 0);
        A3       : in  std_logic_vector(3 downto 0);

        WD3      : in  std_logic_vector(31 downto 0);
        R15      : in  std_logic_vector(31 downto 0);

        RD1      : out std_logic_vector(31 downto 0);
        RD2      : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of register_file is

    type register_array is array (0 to 15)
        of std_logic_vector(31 downto 0);

    signal registers : register_array :=
        (others => (others => '0'));

begin

    -- Deux lectures asynchrones.
    RD1 <= R15 when RA1 = "1111" else
           registers(to_integer(unsigned(RA1))) when not is_x(RA1) else
           (others => '0');
    RD2 <= R15 when RA2 = "1111" else
           registers(to_integer(unsigned(RA2))) when not is_x(RA2) else
           (others => '0');

    -- Ecriture au front montant si elle est autorisee.
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RegWrite = '1' and A3 /= "1111" then
                registers(to_integer(unsigned(A3))) <= WD3;
            end if;
        end if;
    end process;

end architecture;
