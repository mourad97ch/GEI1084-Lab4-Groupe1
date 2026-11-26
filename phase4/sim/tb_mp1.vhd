
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
    generic (PROGRAM_FILE : string := "Program.hex");
    port (
      RegState : out std_logic_vector(479 downto 0);
      CLK, Reset : in std_logic;
      PC, Instr, ALUResult, WriteData :
        out std_logic_vector(31 downto 0);
      ALUFlags, Flags : out std_logic_vector(3 downto 0);
      FlagWrite : out std_logic_vector(1 downto 0);
      CondEx, RegWrite, MemWrite, PCSrc : out std_logic
    );
  end component;

  signal RegState : std_logic_vector(479 downto 0);
  signal R14 : std_logic_vector(31 downto 0);

  signal CLK : std_logic := '0';
  signal Reset : std_logic := '1';

  signal PC, Instr, ALUResult, WriteData :
    std_logic_vector(31 downto 0);

  signal ALUFlags, Flags : std_logic_vector(3 downto 0);
  signal FlagWrite : std_logic_vector(1 downto 0);

  signal CondEx, RegWrite, MemWrite, PCSrc : std_logic;

  signal ExpectedALUResult, ExpectedData :
    std_logic_vector(31 downto 0);

  signal Test_number, Error_count : natural := 0;
  signal Done : boolean := false;

begin

  R14 <= RegState(479 downto 448);

  CLK <= not CLK after 5 ns when not Done else '0';
  Reset <= '0' after 22 ns;

  dut : mp1_system
    generic map (PROGRAM_FILE => "Program.hex")
    port map (
      RegState => RegState,
      CLK => CLK,
      Reset => Reset,
      PC => PC,
      Instr => Instr,
      ALUResult => ALUResult,
      WriteData => WriteData,
      ALUFlags => ALUFlags,
      Flags => Flags,
      FlagWrite => FlagWrite,
      CondEx => CondEx,
      RegWrite => RegWrite,
      MemWrite => MemWrite,
      PCSrc => PCSrc
    );

  stimulus : process

    file expected : text open read_mode is EXPECTED_FILE;
    file program : text open read_mode is PROGRAM_FILE;

    variable row : line;
    variable vi, va, vd : bit_vector(31 downto 0);
    variable sep : character;

    variable ok, result_ok, fetch_ok, lt_ok : boolean;
    variable cmp_ok : boolean;

    variable tests, errors : natural := 0;

    variable expected_flags : std_logic_vector(3 downto 0);
    variable expected_cond : std_logic;
    variable expected_flagwrite : std_logic_vector(1 downto 0);

  begin

    wait until Reset = '0';

    while not endfile(expected) loop

      assert not endfile(program)
        report "Too few instructions"
        severity failure;

      readline(program, row);
      read(row, vi, ok);

      assert ok
        report "Invalid instruction"
        severity failure;

      readline(expected, row);
      read(row, va, ok);

      assert ok
        report "Invalid ExpectedALUResult"
        severity failure;

      read(row, sep, ok);

      assert ok and sep = '_'
        report "Invalid separator"
        severity failure;

      read(row, vd, ok);

      assert ok
        report "Invalid ExpectedData"
        severity failure;

      tests := tests + 1;
      Test_number <= tests;

      ExpectedALUResult <= to_stdlogicvector(va);
      ExpectedData <= to_stdlogicvector(vd);

      wait until rising_edge(CLK);

      fetch_ok :=
        PC = std_logic_vector(to_unsigned(4*(tests-1), 32))
        and Instr = to_stdlogicvector(vi);

      result_ok :=
        ALUResult = to_stdlogicvector(va)
        and WriteData = to_stdlogicvector(vd);

      lt_ok := true;
      cmp_ok := true;

      -- Test conditionnel LT original
      if tests = 12 then

        lt_ok :=
          Instr(31 downto 28) = "1011"
          and Flags = "1000"
          and CondEx = '1'
          and RegWrite = '1'
          and FlagWrite = "00";

      end if;

      -- Tests CMP C1 a C7
      if tests >= 21 and tests <= 27 then

        case tests is

          when 21 =>
            expected_flags := "0110";
            expected_cond := '1';
            expected_flagwrite := "11";

          when 22 =>
            expected_flags := "1000";
            expected_cond := '1';
            expected_flagwrite := "11";

          when 23 =>
            expected_flags := "0010";
            expected_cond := '1';
            expected_flagwrite := "11";

          when 24 =>
            expected_flags := "1010";
            expected_cond := '1';
            expected_flagwrite := "11";

          when 25 =>
            expected_flags := "0110";
            expected_cond := '1';
            expected_flagwrite := "11";

          when 26 =>
            expected_flags := "0110";
            expected_cond := '0';
            expected_flagwrite := "00";

          when 27 =>
            expected_flags := "1000";
            expected_cond := '1';
            expected_flagwrite := "11";

          when others =>
            expected_flags := "0000";
            expected_cond := '0';
            expected_flagwrite := "00";

        end case;

        -- Verifications avant mise a jour des registres
        cmp_ok :=
          Instr(24 downto 21) = "1010"
          and RegWrite = '0'
          and MemWrite = '0'
          and PCSrc = '0'
          and CondEx = expected_cond
          and FlagWrite = expected_flagwrite;

        -- ALUFlags est calcule meme si la condition est fausse
        if tests /= 26 then
          cmp_ok := cmp_ok and ALUFlags = expected_flags;
        end if;

        -- Attendre la mise a jour des flags
        wait for 1 ns;

        cmp_ok := cmp_ok and Flags = expected_flags;

        if cmp_ok then
          report "CMP C" & integer'image(tests-20)
            & " : PASS, NZCV="
            & to_hstring(Flags)
            severity note;
        else
          report "CMP C" & integer'image(tests-20)
            & " : FAIL, Flags="
            & to_hstring(Flags)
            & ", ALUFlags="
            & to_hstring(ALUFlags)
            & ", FlagWrite="
            & to_hstring(FlagWrite)
            severity warning;
        end if;

      end if;

      if not (fetch_ok and result_ok and lt_ok and cmp_ok) then

        errors := errors + 1;
        Error_count <= errors;

        report "Test " & integer'image(tests)
          & " FAILED: PC=0x" & to_hstring(PC)
          & ", ALUResult=0x" & to_hstring(ALUResult)
          & ", ExpectedALUResult=0x" & to_hstring(to_stdlogicvector(va))
          severity warning;

      end if;

    end loop;

    assert tests > 0 and endfile(program)
      report "Program and expected data lengths differ"
      severity failure;

    Done <= true;

    report "Tests: " & integer'image(tests)
      & "; errors: " & integer'image(errors)
      severity note;

    assert errors = 0
      report "CMP verification failed"
      severity error;

    wait;

  end process;

end architecture;
