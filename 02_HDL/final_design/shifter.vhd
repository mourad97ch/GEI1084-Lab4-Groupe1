-- Shifter combinatoire (registre decale par une constante).
-- Place entre RD2 et l'entree d0 du mux ALUSrc : seul le deuxieme
-- operande REGISTRE est decale ; ExtImm (entree d1) reste intact.
--   shamt = Instr(11:7) : nombre de positions (0 a 31)
--   sh    = Instr(6:5)  : 00 = LSL, 01 = LSR (logique)
--   bit4  = Instr(4)    : 0 = decalage par constante
-- Hors portee (ASR, ROR, decalage par registre) : operande transmis
-- sans decalage. LSL #0 = identite, donc les instructions registre du
-- Lab 4 (bits 11:4 a zero) gardent exactement le meme comportement.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
    port (
        A     : in  std_logic_vector(31 downto 0);  -- RD2
        shamt : in  std_logic_vector(4 downto 0);   -- Instr(11:7)
        sh    : in  std_logic_vector(1 downto 0);   -- Instr(6:5)
        bit4  : in  std_logic;                      -- Instr(4)
        Y     : out std_logic_vector(31 downto 0)   -- vers mux ALUSrc (d0)
    );
end entity;

architecture combinational of shifter is
begin

    process(A, shamt, sh, bit4)
        variable n : natural range 0 to 31;
    begin
        n := to_integer(unsigned(shamt));
        Y <= A;
        if bit4 = '0' then
            case sh is
                -- LSL : des zeros entrent a droite.
                when "00" =>
                    Y <= std_logic_vector(shift_left(unsigned(A), n));
                -- LSR logique : unsigned => des zeros entrent a gauche
                -- (sur signed, ce serait un ASR qui recopie le bit 31).
                when "01" =>
                    -- ARM encode LSR #32 with imm5 = 0.  A zero shift
                    -- amount here is therefore 32, not the identity.
                    if n = 0 then
                        Y <= (others => '0');
                    else
                        Y <= std_logic_vector(shift_right(unsigned(A), n));
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;

end architecture;
