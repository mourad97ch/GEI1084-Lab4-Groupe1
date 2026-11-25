library ieee;
use ieee.std_logic_1164.all;
entity condlogic is
  port (
    CLK, Reset : in std_logic;
    Cond, ALUFlags : in std_logic_vector(3 downto 0);
    FlagW : in std_logic_vector(1 downto 0);
    RegW, MemW, PCS : in std_logic;
    RegWrite, MemWrite, PCSrc, CondEx : out std_logic;
    FlagWrite : out std_logic_vector(1 downto 0);
    Flags : out std_logic_vector(3 downto 0)
  );
end entity;
architecture structural of condlogic is
component condcheck
  port (
    Cond, Flags : in std_logic_vector(3 downto 0);
    CondEx : out std_logic
  );
end component;
component reg_enable
  generic (WIDTH : positive := 32);
  port (
    CLK, Reset, Enable : in std_logic;
    D : in std_logic_vector(WIDTH-1 downto 0);
    Q : out std_logic_vector(WIDTH-1 downto 0)
  );
end component;

  signal saved : std_logic_vector(3 downto 0);
  signal enable_flags : std_logic_vector(1 downto 0);
  signal condition_ok, execute : std_logic;
begin
  check_unit : condcheck
    port map (Cond => Cond, Flags => saved, CondEx => condition_ok);

  execute <= condition_ok and not Reset;
  enable_flags(1) <= FlagW(1) and execute;
  enable_flags(0) <= FlagW(0) and execute;

  nz_unit : reg_enable
    generic map (WIDTH => 2)
    port map (CLK => CLK, Reset => Reset, Enable => enable_flags(1),
              D => ALUFlags(3 downto 2), Q => saved(3 downto 2));

  cv_unit : reg_enable
    generic map (WIDTH => 2)
    port map (CLK => CLK, Reset => Reset, Enable => enable_flags(0),
              D => ALUFlags(1 downto 0), Q => saved(1 downto 0));

  RegWrite <= RegW and execute;
  MemWrite <= MemW and execute;
  PCSrc <= PCS and execute;
  CondEx <= condition_ok;
  FlagWrite <= enable_flags;
  Flags <= saved;
end architecture;
