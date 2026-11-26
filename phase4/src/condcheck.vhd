library ieee;
use ieee.std_logic_1164.all;
entity condcheck is
  port (
    Cond, Flags : in std_logic_vector(3 downto 0);
    CondEx : out std_logic
  );
end entity;

architecture rtl of condcheck is
  signal N, Z, C, V, GE : std_logic;
begin
  N <= Flags(3); Z <= Flags(2); C <= Flags(1); V <= Flags(0);
  GE <= N xnor V;
  with Cond select
    CondEx <= Z                  when "0000", -- EQ
              not Z              when "0001", -- NE
              C                  when "0010", -- CS / HS
              not C              when "0011", -- CC / LO
              N                  when "0100", -- MI
              not N              when "0101", -- PL
              V                  when "0110", -- VS
              not V              when "0111", -- VC
              C and not Z        when "1000", -- HI
              not (C and not Z)  when "1001", -- LS
              GE                 when "1010", -- GE
              not GE             when "1011", -- LT
              not Z and GE       when "1100", -- GT
              not (not Z and GE) when "1101", -- LE
              '1'                when "1110", -- AL
              '0'                when others;
end architecture;
