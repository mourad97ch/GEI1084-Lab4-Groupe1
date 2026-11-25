library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_mp1 is
  generic (
    PROGRAM_FILE  : string := "Instructions.txt";
    EXPECTED_FILE : string := "ExpectedData.txt"
  );
end entity;

architecture simulation of tb_mp1 is
component mp1_system
 generic(PROGRAM_FILE : string := "Program.hex");
  port (
    RegState : out std_logic_vector(479 downto 0);
    CLK, Reset : in std_logic;
    PC, Instr, ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ALUFlags, Flags : out std_logic_vector(3 downto 0);
    FlagWrite : out std_logic_vector(1 downto 0);
    CondEx, RegWrite, MemWrite, PCSrc : out std_logic
  );
end component;

  signal RegState : std_logic_vector(479 downto 0);
  signal R14 : std_logic_vector(31 downto 0);
  signal CLK : std_logic := '0';
  signal Reset : std_logic := '1';
  signal PC, Instr, ALUResult, WriteData : std_logic_vector(31 downto 0);
  signal ALUFlags, Flags : std_logic_vector(3 downto 0);
  signal FlagWrite : std_logic_vector(1 downto 0);
  signal CondEx, RegWrite, MemWrite, PCSrc : std_logic;
  signal ExpectedALUResult, ExpectedData : std_logic_vector(31 downto 0);
  signal Test_number, Error_count : natural := 0;
  signal Done : boolean := false;
begin
  R14 <= RegState(479 downto 448);
  CLK <= not CLK after 5 ns when not Done else '0';
  Reset <= '0' after 22 ns;

  dut : mp1_system
    generic map(PROGRAM_FILE => "Program.hex")
    port map (
      RegState => RegState, CLK => CLK, Reset => Reset, PC => PC, Instr => Instr,
      ALUResult => ALUResult, WriteData => WriteData, ALUFlags => ALUFlags,
      Flags => Flags, FlagWrite => FlagWrite, CondEx => CondEx,
      RegWrite => RegWrite, MemWrite => MemWrite, PCSrc => PCSrc
    );

  stimulus : process
    file expected : text open read_mode is EXPECTED_FILE;
    file program : text open read_mode is PROGRAM_FILE;
    variable row : line;
    variable vi, va, vd : bit_vector(31 downto 0);
    variable sep : character;
    variable ok, result_ok, fetch_ok, lt_ok : boolean;
    variable tests, errors : natural := 0;
  begin
    wait until Reset = '0';
    while not endfile(expected) loop
      assert not endfile(program) report "Too few instructions" severity failure;
      readline(program, row);
      read(row, vi, ok);
      assert ok report "Invalid instruction" severity failure;
      readline(expected, row);
      read(row, va, ok);
      assert ok report "Invalid ExpectedALUResult" severity failure;
      read(row, sep, ok);
      assert ok and sep = '_' report "Invalid separator" severity failure;
      read(row, vd, ok);
      assert ok report "Invalid ExpectedData" severity failure;

      tests := tests + 1;
      Test_number <= tests;
      ExpectedALUResult <= to_stdlogicvector(va);
      ExpectedData <= to_stdlogicvector(vd);
      -- Observe the current instruction before the edge commits its effects.
      wait until rising_edge(CLK);

      fetch_ok := PC = std_logic_vector(to_unsigned(4*(tests-1), 32))
                  and Instr = to_stdlogicvector(vi);
      result_ok := ALUResult = ExpectedALUResult and WriteData = ExpectedData;
      lt_ok := true;
      if tests = 12 then
        lt_ok := Instr(31 downto 28) = "1011" and Flags = "1000"
                 and CondEx = '1' and RegWrite = '1' and FlagWrite = "00";
        if lt_ok then
          report "LT: NZCV=1000, CondEx=1, RegWrite=1, FlagWrite=00" severity note;
        end if;
      end if;
      if not (fetch_ok and result_ok and lt_ok) then
        errors := errors + 1;
        Error_count <= errors;
        report "Test " & integer'image(tests) &
               ": PC=0x" & to_hstring(PC) &
               ", ALUResult=0x" & to_hstring(ALUResult) &
               " expected=0x" & to_hstring(ExpectedALUResult) &
               ", WriteData=0x" & to_hstring(WriteData) &
               " expected=0x" & to_hstring(ExpectedData) &
               ", CondEx=" & std_logic'image(CondEx) severity warning;
      end if;
    end loop;
    assert tests > 0 and endfile(program) report "Program and expected data lengths differ" severity failure;
    Done <= true;
    report "Tests: " & integer'image(tests) & "; errors: " & integer'image(errors) severity note;
    assert errors = 0 report "Lab 4 verification failed" severity error;
    wait;
  end process;
end architecture;
