library ieee;
use ieee.std_logic_1164.all;

entity alu_decoder is
  port (
    ALUOp : in std_logic;
    Funct : in std_logic_vector(4 downto 0);
    ALUControl, FlagW : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of alu_decoder is
begin
  process(ALUOp, Funct)
  begin
    ALUControl <= "00";
    FlagW <= "00";
    if ALUOp = '1' then
      case Funct(4 downto 1) is
        when "0100" =>                     -- ADD / ADDS
          if Funct(0) = '1' then FlagW <= "11"; end if;
        when "0010" =>                     -- SUB / SUBS
          ALUControl <= "01";
          if Funct(0) = '1' then FlagW <= "11"; end if;
        when "0000" =>                     -- AND / ANDS
          ALUControl <= "10";
          if Funct(0) = '1' then FlagW <= "10"; end if;
        when "1100" =>                     -- ORR / ORRS
          ALUControl <= "11";
          if Funct(0) = '1' then FlagW <= "10"; end if;
          --modification
          when "1010" =>                     -- CMP
          ALUControl <= "01";
          FlagW <= "11";
        when others =>
          null;
      end case;
    end if;
  end process;
end architecture;
