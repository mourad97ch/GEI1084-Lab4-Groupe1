library ieee;
use ieee.std_logic_1164.all;
entity arm_mp1 is
  port (
    CLK, Reset : in std_logic;
    Instruction : in std_logic_vector(31 downto 0);
    RegState : out std_logic_vector(479 downto 0);
    PC, Instr, ALUResult, WriteData : out std_logic_vector(31 downto 0);
    ALUFlags, Flags : out std_logic_vector(3 downto 0);
    FlagWrite : out std_logic_vector(1 downto 0);
    CondEx, RegWrite, MemWrite, PCSrc : out std_logic

  );
end entity;

architecture structural of arm_mp1 is
component main_decoder
  port (
    Op : in std_logic_vector(1 downto 0);
        --modification
    Opcode : in std_logic_vector(3 downto 0);
    Funct5, Funct0 : in std_logic;
    Branch, MemtoReg, MemW, ALUSrc, RegW, ALUOp : out std_logic;
    ImmSrc, RegSrc : out std_logic_vector(1 downto 0)
  );
end component;
component alu_decoder
  port (
ALUOp : in std_logic;
    Funct : in std_logic_vector(4 downto 0);
    ALUControl, FlagW : out std_logic_vector(1 downto 0)
  );
end component;
component pc_logic
  port (
Rd : in std_logic_vector(3 downto 0);
    RegW, Branch : in std_logic;
    PCSrc : out std_logic
  );
end component;
component datapath
  port (
RegState : out std_logic_vector(479 downto 0);
CLK        : in  std_logic;
        Instr      : in  std_logic_vector(31 downto 0);
        PCPlus8    : in  std_logic_vector(31 downto 0);

        MemtoReg   : in  std_logic;
        MemWrite   : in  std_logic;
        ALUControl : in  std_logic_vector(1 downto 0);
        ALUSrc     : in  std_logic;
        ImmSrc     : in  std_logic_vector(1 downto 0);
        RegWrite   : in  std_logic;
        RegSrc     : in  std_logic_vector(1 downto 0);

        Flags      : out std_logic_vector(3 downto 0);
        SrcA       : out std_logic_vector(31 downto 0);
        SrcB       : out std_logic_vector(31 downto 0);
        ALUResult  : out std_logic_vector(31 downto 0);
        Output     : out std_logic_vector(31 downto 0);
        WriteData  : out std_logic_vector(31 downto 0)
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
component adder
  port (
    a, b : in std_logic_vector(31 downto 0);
    y : out std_logic_vector(31 downto 0)
  );
end component;

component condlogic
  port (
    CLK, Reset : in std_logic;
    Cond, ALUFlags : in std_logic_vector(3 downto 0);
    FlagW : in std_logic_vector(1 downto 0);
    RegW, MemW, PCS : in std_logic;
    RegWrite, MemWrite, PCSrc, CondEx : out std_logic;
    FlagWrite : out std_logic_vector(1 downto 0);
    Flags : out std_logic_vector(3 downto 0)
  );
end component;

  signal pc_s, pc4_s, pc8_s, pcnext_s, instr_s, result_s : std_logic_vector(31 downto 0);
  signal aluflags_s : std_logic_vector(3 downto 0);
  signal immsrc_s, regsrc_s, alucontrol_s, flagw_s : std_logic_vector(1 downto 0);
  signal branch_s, memtoreg_s, memw_s, alusrc_s, regw_s, aluop_s : std_logic;
  signal pcs_s, pcsrc_s, regwrite_s, memwrite_s : std_logic;
begin
  pcnext_s <= result_s when pcsrc_s = '1' else pc4_s;
  pc_register : reg_enable generic map (WIDTH => 32)
    port map (CLK => CLK, Reset => Reset, Enable => '1', D => pcnext_s, Q => pc_s);
  pc_plus4 : adder port map (a => pc_s, b => x"00000004", y => pc4_s);
  pc_plus8 : adder port map (a => pc4_s, b => x"00000004", y => pc8_s);
  instr_s <= Instruction;

  main_unit : main_decoder
    port map (
      Op => instr_s(27 downto 26), Funct5 => instr_s(25), Funct0 => instr_s(20),
      --modification
      Opcode => instr_s(24 downto 21),
      Branch => branch_s, MemtoReg => memtoreg_s, MemW => memw_s, ALUSrc => alusrc_s,
      RegW => regw_s, ALUOp => aluop_s, ImmSrc => immsrc_s, RegSrc => regsrc_s
    );

  alu_control_unit : alu_decoder
    port map (ALUOp => aluop_s, Funct => instr_s(24 downto 20),
              ALUControl => alucontrol_s, FlagW => flagw_s);

  pc_unit : pc_logic
    port map (Rd => instr_s(15 downto 12), RegW => regw_s, Branch => branch_s, PCSrc => pcs_s);

  condition_unit : condlogic
    port map (
      CLK => CLK, Reset => Reset, Cond => instr_s(31 downto 28), ALUFlags => aluflags_s,
      FlagW => flagw_s, RegW => regw_s, MemW => memw_s, PCS => pcs_s,
      RegWrite => regwrite_s, MemWrite => memwrite_s, PCSrc => pcsrc_s,
      CondEx => CondEx, FlagWrite => FlagWrite, Flags => Flags
    );

  datapath_unit : datapath
    port map (
      RegState => RegState, CLK => CLK, Instr => instr_s, PCPlus8 => pc8_s, MemtoReg => memtoreg_s,
      MemWrite => memwrite_s, ALUControl => alucontrol_s, ALUSrc => alusrc_s,
      ImmSrc => immsrc_s, RegWrite => regwrite_s, RegSrc => regsrc_s,
      Flags => aluflags_s, SrcA => open, SrcB => open, ALUResult => ALUResult,
      Output => result_s, WriteData => WriteData
    );

  PC <= pc_s;
  Instr <= instr_s;
  ALUFlags <= aluflags_s;
  PCSrc <= pcsrc_s;
  RegWrite <= regwrite_s;
  MemWrite <= memwrite_s;
end architecture;
