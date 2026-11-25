library ieee;
use ieee.std_logic_1164.all;

entity datapath is
    port (
        PCPlus4 : in std_logic_vector(31 downto 0);
        Link : in std_logic;
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
end entity;

architecture structural of datapath is

    component register_file
        port (
            RegState : out std_logic_vector(479 downto 0);
            CLK      : in  std_logic;
            RegWrite : in  std_logic;
            RA1      : in  std_logic_vector(3 downto 0);
            RA2      : in  std_logic_vector(3 downto 0);
            A3       : in  std_logic_vector(3 downto 0);
            WD3      : in  std_logic_vector(31 downto 0);
            R15      : in  std_logic_vector(31 downto 0);
            RD1      : out std_logic_vector(31 downto 0);
            RD2      : out std_logic_vector(31 downto 0)
        );
    end component;

    component extend
        port (
            Instr  : in  std_logic_vector(23 downto 0);
            ImmSrc : in  std_logic_vector(1 downto 0);
            ExtImm : out std_logic_vector(31 downto 0)
        );
    end component;

    component alu32
        port (
            A          : in  std_logic_vector(31 downto 0);
            B          : in  std_logic_vector(31 downto 0);
            ALUControl : in  std_logic_vector(1 downto 0);
            Result     : out std_logic_vector(31 downto 0);
            ALUFlags   : out std_logic_vector(3 downto 0)
        );
    end component;

    component data_memory
        port (
            CLK      : in  std_logic;
            MemWrite : in  std_logic;
            A        : in  std_logic_vector(31 downto 0);
            WD       : in  std_logic_vector(31 downto 0);
            RD       : out std_logic_vector(31 downto 0)
        );
    end component;

    signal destination_s : std_logic_vector(3 downto 0);
    signal writeback_s : std_logic_vector(31 downto 0);
    signal ra1_s, ra2_s : std_logic_vector(3 downto 0);

    signal rd1_s, rd2_s   : std_logic_vector(31 downto 0);
    signal extimm_s       : std_logic_vector(31 downto 0);
    signal srcb_s         : std_logic_vector(31 downto 0);
    signal alu_result_s   : std_logic_vector(31 downto 0);
    signal read_data_s    : std_logic_vector(31 downto 0);
    signal output_s      : std_logic_vector(31 downto 0);

begin
    destination_s <= "1110" when Link='1' else Instr(15 downto 12);
    writeback_s <= PCPlus4 when Link='1' else output_s;

    -- Selection des adresses de lecture.
    ra1_s <= Instr(19 downto 16) when RegSrc(0) = '0'
             else "1111";

    ra2_s <= Instr(3 downto 0) when RegSrc(1) = '0'
             else Instr(15 downto 12);

    registers_unit : register_file
        port map (
            CLK      => CLK,
            RegWrite => RegWrite,
            RA1      => ra1_s,
            RA2      => ra2_s,
            A3       => destination_s,
            WD3      => writeback_s,
            R15      => PCPlus8,
            RegState => RegState,
            RD1      => rd1_s,
            RD2      => rd2_s
        );

    extend_unit : extend
        port map (
            Instr  => Instr(23 downto 0),
            ImmSrc => ImmSrc,
            ExtImm => extimm_s
        );

    -- Deuxieme operande : registre ou constante.
    srcb_s <= rd2_s when ALUSrc = '0'
              else extimm_s;

    alu_unit : alu32
        port map (
            A          => rd1_s,
            B          => srcb_s,
            ALUControl => ALUControl,
            Result     => alu_result_s,
            ALUFlags   => Flags
        );

    memory_unit : data_memory
        port map (
            CLK      => CLK,
            MemWrite => MemWrite,
            A        => alu_result_s,
            WD       => rd2_s,
            RD       => read_data_s
        );

    -- Valeur renvoyee vers la banque de registres.
    output_s <= alu_result_s when MemtoReg = '0'
                else read_data_s;

    -- Signaux observables pour la simulation.
    SrcA      <= rd1_s;
    SrcB      <= srcb_s;
    ALUResult <= alu_result_s;
    Output    <= output_s;
    WriteData <= rd2_s;

end architecture;
