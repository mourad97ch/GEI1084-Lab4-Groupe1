"""Modele de reference ARM monocycle (sous-ensemble MP1) pour les tests S1-S10.

Genere 03_TESTBENCH/instructions/S<n>.hex et 03_TESTBENCH/expected_results/S<n>.trace au format du banc catalogue
(meme format que les traces B1-B8) :
  PC Instr ALUResult WriteData Flags RegW MemW PCSrc FlagW CondEx
  NextPC FlagsApres R0 ... R14
Le modele est ecrit a partir de la specification ARM (pas du VHDL) :
il sert d'attendu independant pour la simulation Vivado.

Usage : python 03_TESTBENCH/expected_results/generators/gen_shift_tests.py
"""
from pathlib import Path

MASK = 0xFFFFFFFF
TB = Path(__file__).resolve().parents[2]          # 03_TESTBENCH
HEX_DIR = TB / "instructions"
TRACE_DIR = TB / "expected_results"

# ---------------------------------------------------------------- encodage
COND_AL = 0xE
OPC = {"AND": 0b0000, "SUB": 0b0010, "ADD": 0b0100, "ORR": 0b1100}
SH = {"LSL": 0b00, "LSR": 0b01}


def dp_reg(op, rd, rn, rm, sh="LSL", shamt=0):
    """Traitement de donnees, operande registre decale par une constante."""
    return (COND_AL << 28) | (OPC[op] << 21) | (rn << 16) | (rd << 12) \
        | (shamt << 7) | (SH[sh] << 5) | rm


def dp_imm(op, rd, rn, imm8):
    """Traitement de donnees, immediat 8 bits (rot = 0)."""
    return (COND_AL << 28) | (1 << 25) | (OPC[op] << 21) | (rn << 16) \
        | (rd << 12) | imm8


def mem(load, rd, rn, imm12):
    """LDR/STR avec deplacement immediat positif (P=1, U=1)."""
    return (COND_AL << 28) | (0b01 << 26) | (1 << 24) | (1 << 23) \
        | (int(load) << 20) | (rn << 16) | (rd << 12) | imm12


# ---------------------------------------------------------- modele ISA
def shift(value, sh, n):
    if sh == 0b00:
        return (value << n) & MASK
    if sh == 0b01:
        return 0 if n == 0 else value >> n   # ARM LSR #32 when imm5 = 0
    return value                             # hors portee


def run(program):
    regs = [0] * 15
    mem_data = {}
    pc = 0
    flags = 0
    rows = []
    for _ in program:
        instr = program[pc // 4]
        op = (instr >> 26) & 3
        funct = (instr >> 20) & 0x3F
        rn, rd = (instr >> 16) & 0xF, (instr >> 12) & 0xF
        pc8 = (pc + 8) & MASK

        def rd_reg(r):
            return pc8 if r == 15 else regs[r]

        regw = memw = 0
        if op == 0b00:                       # traitement de donnees
            ra2 = instr & 0xF
            a = rd_reg(rn)
            if funct & 0x20:                 # I = 1 : immediat, jamais decale
                b = instr & 0xFF
            else:                            # I = 0 : registre decale
                b = shift(rd_reg(ra2), (instr >> 5) & 3, (instr >> 7) & 0x1F) \
                    if not (instr >> 4) & 1 else rd_reg(ra2)
            cmd = (funct >> 1) & 0xF
            res = {0b0100: a + b, 0b0010: a - b, 0b0000: a & b,
                   0b1100: a | b}[cmd] & MASK
            regw = 1
            write_data = rd_reg(ra2)         # RD2 non decale
            wb = res
        elif op == 0b01:                     # LDR / STR
            load = (funct >> 0) & 1
            ra2 = rd if not load else instr & 0xF
            res = (rd_reg(rn) + (instr & 0xFFF)) & MASK
            write_data = rd_reg(ra2)
            word = res & 0x3F                # memoire de 64 mots (A(5:0))
            if load:
                regw = 1
                wb = mem_data.get(word, 0)
            else:
                memw = 1
                mem_data[word] = write_data
        else:
            raise ValueError("instruction hors portee des tests Shift")

        if regw and rd != 15:
            regs[rd] = wb
        next_pc = pc + 4
        rows.append([f"{pc:08X}", f"{instr:08X}", f"{res:08X}",
                     f"{write_data:08X}", f"{flags:X}", str(regw), str(memw),
                     "0", "0", "1", f"{next_pc:08X}", f"{flags:X}"]
                    + [f"{r:08X}" for r in regs])
        pc = next_pc
    return rows


# ---------------------------------------------------------- tests S1-S11
TESTS = {
    # S1 : LSL #0 = identite
    "S1": [dp_imm("ADD", 1, 0, 0xA5),
           dp_reg("ADD", 2, 0, 1, "LSL", 0)],              # R2 = 0xA5
    # S2 : LSL #1
    "S2": [dp_imm("ADD", 3, 0, 3),
           dp_reg("ADD", 4, 0, 3, "LSL", 1)],              # R4 = 6
    # S3 : LSL multi-bits (4 et 28)
    "S3": [dp_imm("ADD", 3, 0, 3),
           dp_reg("ADD", 5, 0, 3, "LSL", 4),               # R5 = 0x30
           dp_reg("ADD", 6, 0, 3, "LSL", 28)],             # R6 = 0x30000000
    # S4 : LSR ordinaire
    "S4": [dp_imm("ADD", 6, 0, 0x20),
           dp_reg("ADD", 7, 0, 6, "LSR", 1),               # R7 = 0x10
           dp_reg("ADD", 8, 0, 6, "LSR", 5)],              # R8 = 1
    # S5 : LSR avec MSB = 1 -> des zeros entrent (pas d'ASR)
    "S5": [dp_imm("ADD", 1, 0, 1),
           dp_reg("SUB", 8, 0, 1),                         # R8 = 0xFFFFFFFF
           dp_reg("ADD", 9, 0, 8, "LSR", 1),               # R9 = 0x7FFFFFFF
           dp_reg("ADD", 11, 0, 8, "LSR", 31)],            # R11 = 1
    # S6 : decalage jusqu'a zero
    "S6": [dp_imm("ADD", 1, 0, 1),
           dp_reg("SUB", 8, 0, 1),                         # R8 = 0xFFFFFFFF
           dp_reg("ADD", 9, 0, 8, "LSR", 1),               # R9 = 0x7FFFFFFF
           dp_reg("SUB", 10, 8, 9),                        # R10 = 0x80000000
           dp_reg("ADD", 11, 0, 10, "LSL", 1),             # R11 = 0
           dp_reg("ADD", 12, 0, 1, "LSR", 1)],             # R12 = 0
    # S7 : AND avec operande decale
    "S7": [dp_imm("ADD", 1, 0, 0xF0),
           dp_imm("ADD", 2, 0, 0xFF),
           dp_reg("AND", 3, 2, 1, "LSR", 4),               # R3 = 0x0F (sans shift 0xF0)
           dp_reg("AND", 4, 2, 1, "LSL", 4)],              # R4 = 0x00 (sans shift 0xF0)
    # S8 : ORR avec operande decale
    "S8": [dp_imm("ADD", 1, 0, 0x0F),
           dp_imm("ADD", 2, 0, 0x01),
           dp_reg("ORR", 3, 2, 1, "LSL", 8),               # R3 = 0xF01 (sans shift 0x0F)
           dp_reg("ORR", 4, 2, 3, "LSR", 4)],              # R4 = 0xF1
    # S9 : regression registre non decale (bits 11:4 = 0)
    "S9": [dp_imm("ADD", 1, 0, 7),
           dp_imm("ADD", 2, 0, 3),
           dp_reg("SUB", 3, 1, 2),                         # R3 = 4
           dp_reg("ADD", 4, 1, 2),                         # R4 = 10
           dp_reg("AND", 5, 1, 2),                         # R5 = 3
           dp_reg("ORR", 6, 1, 2)],                        # R6 = 7
    # S10 : regression du chemin immediat (bits 11:4 non nuls mais pas un shift)
    "S10": [dp_imm("ADD", 1, 0, 0xA5),                     # bits 11:4 = 0x0A -> R1 = 0xA5 (pas 0x52)
            dp_imm("SUB", 2, 1, 0xE0),                     # R2 = 0xFFFFFFC5
            mem(False, 1, 0, 0x8A),                        # STR : WriteData = R1 non decale
            mem(True, 3, 0, 0x8A)],                        # LDR : R3 = 0xA5
    # Boundary rule from ARM: LSR with imm5 = 0 encodes a shift by 32.
    "S11": [dp_imm("ADD", 1, 0, 1),
            dp_reg("SUB", 2, 0, 1),                        # R2 = 0xFFFFFFFF
            dp_reg("ADD", 3, 0, 2, "LSR", 0)],             # R3 = 0
}


def main():
    for name, prog in TESTS.items():
        rows = run(prog)
        (HEX_DIR / f"{name}.hex").write_text(
            "".join(f"{i:08X}\n" for i in prog), encoding="ascii", newline="\n")
        (TRACE_DIR / f"{name}.trace").write_text(
            "".join(" ".join(r) + "\n" for r in rows), encoding="ascii",
            newline="\n")
        print(f"{name}: {len(prog)} instructions")


if __name__ == "__main__":
    main()
