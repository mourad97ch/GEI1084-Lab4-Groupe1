library ieee;
use ieee.std_logic_1164.all;
entity tb_lsr32_review is end;
architecture verification of tb_lsr32_review is
signal a,y:std_logic_vector(31 downto 0);
begin
u:entity work.shifter port map(A=>a,shamt=>"00000",sh=>"01",bit4=>'0',Y=>y);
process begin
a<=x"80000001";wait for 1 ns;
report "HAROUN_LSR_IMM5_ZERO A=" & to_hstring(a) & " observed=" & to_hstring(y) & " ARM_LSR32_expected=00000000" severity note;
assert y=x"00000000" report "LSR imm5=00000 preserves A instead of ARM LSR #32" severity warning;
wait;
end process;
end;
