library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        CLK      : in  std_logic;
        MemWrite : in  std_logic;
        A        : in  std_logic_vector(31 downto 0);
        WD       : in  std_logic_vector(31 downto 0);
        RD       : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_memory is

    type memory_array is array (0 to 63)
        of std_logic_vector(31 downto 0);

    signal memory : memory_array :=
        (others => (others => '0'));

begin

    -- Ecriture synchrone.
    process(CLK)
    begin
        if rising_edge(CLK) then
            if MemWrite = '1' then
                memory(to_integer(unsigned(A(5 downto 0)))) <= WD;
            end if;
        end if;
    end process;

    -- Lecture asynchrone.
    RD <= memory(to_integer(unsigned(A(5 downto 0))));

end architecture;