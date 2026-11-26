library ieee;
use ieee.std_logic_1164.all;

entity alu32 is
    port (
        A          : in  std_logic_vector(31 downto 0);
        B          : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(1 downto 0);
        Result     : out std_logic_vector(31 downto 0);
        ALUFlags   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of alu32 is
    component alu_arithmetic
        port (
            A, B       : in  std_logic_vector(31 downto 0);
            SUBTRACT   : in  std_logic;
            ARITHMETIC : out std_logic_vector(31 downto 0);
            CARRY      : out std_logic
        );
    end component;

    component alu_select
        port (
            A, B, Sum  : in  std_logic_vector(31 downto 0);
            ALUControl : in  std_logic_vector(1 downto 0);
            Result     : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu_flags
        port (
            A, B, RESULT : in  std_logic_vector(31 downto 0);
            SUM31        : in  std_logic;
            CARRY_IN     : in  std_logic;
            ARITHMETIC   : in  std_logic;
            SUBTRACT     : in  std_logic;
            FLAGS        : out std_logic_vector(3 downto 0)
        );
    end component;

    signal arithmetic_result : std_logic_vector(31 downto 0);
    signal arithmetic_carry  : std_logic;
    signal selected_result   : std_logic_vector(31 downto 0);
    signal is_arithmetic     : std_logic;
    signal is_subtract       : std_logic;
begin
    is_arithmetic <= not ALUControl(1);
    is_subtract   <= ALUControl(0);

    arithmetic_unit : alu_arithmetic
        port map (
            A          => A,
            B          => B,
            SUBTRACT   => is_subtract,
            ARITHMETIC => arithmetic_result,
            CARRY      => arithmetic_carry
        );

    -- Harris, figure 5.15 : selection du resultat.
    result_unit : alu_select
        port map (
            A => A, B => B, Sum => arithmetic_result,
            ALUControl => ALUControl, Result => selected_result
        );

    flags_unit : alu_flags
        port map (
            A          => A,
            B          => B,
            RESULT     => selected_result,
            SUM31      => arithmetic_result(31),
            CARRY_IN   => arithmetic_carry,
            ARITHMETIC => is_arithmetic,
            SUBTRACT   => is_subtract,
            FLAGS      => ALUFlags
        );

    Result <= selected_result;
end architecture;
