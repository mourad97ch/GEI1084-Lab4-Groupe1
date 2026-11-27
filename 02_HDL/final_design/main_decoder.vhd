library ieee;
use ieee.std_logic_1164.all;

entity main_decoder is
  port (
    Op : in std_logic_vector(1 downto 0);
    --modification apportee
    Opcode : in std_logic_vector(3 downto 0); 
    Funct5, Funct0 : in std_logic;
    Branch, MemtoReg, MemW, ALUSrc, RegW, ALUOp : out std_logic;
    ImmSrc, RegSrc : out std_logic_vector(1 downto 0)
    
  );
end entity;

architecture rtl of main_decoder is
begin
  process(Op,Opcode, Funct5, Funct0)
  begin
    Branch <= '0'; MemtoReg <= '0'; MemW <= '0';
    ALUSrc <= '0'; RegW <= '0'; ALUOp <= '0';
    ImmSrc <= "00"; RegSrc <= "00";
    case Op is
     -- when "00" =>
     --   RegW <= '1'; ALUOp <= '1';
     --   ALUSrc <= Funct5;
     --modification
      when "00" =>
        ALUOp <= '1';
        ALUSrc <= Funct5;

        if Opcode = "1010" then
             RegW <= '0';  -- CMP
        else
              RegW <= '1';
        end if;
      when "01" =>
        ALUSrc <= '1'; ImmSrc <= "01";
        if Funct0 = '0' then
          MemW <= '1'; RegSrc <= "10";
        elsif Funct0 = '1' then
          MemtoReg <= '1'; RegW <= '1';
        end if;
      when "10" =>
        Branch <= '1'; ALUSrc <= '1';
        ImmSrc <= "10"; RegSrc <= "01";
      when others =>
        null;
    end case;
  end process;
end architecture;
