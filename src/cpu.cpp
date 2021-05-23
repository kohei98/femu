#include "cpu.hpp"

#define STR(var) #var
CPU::CPU()
{
    CPUregisters = {0x00, 0x00, 0x00, 0x01FD, {false, false, true, false, false, true, false, false}, 0xC000};
}

uint8_t CPU::zipP()
{
    uint8_t binary_P = 0x00;
    if (CPUregisters.P.Negative)
        binary_P += 1 << 7;
    if (CPUregisters.P.Overflow)
        binary_P += 1 << 6;
    if (CPUregisters.P.Resersved)
        binary_P += 1 << 5;
    if (CPUregisters.P.Break)
        binary_P += 1 << 4;
    if (CPUregisters.P.Decimal)
        binary_P += 1 << 3;
    if (CPUregisters.P.Interrupt)
        binary_P += 1 << 2;
    if (CPUregisters.P.Zero)
        binary_P += 1 << 1;
    if (CPUregisters.P.Carry)
        binary_P += 1 << 0;
    return binary_P;
}

void CPU::unzipP(uint8_t binary_P)
{
    CPUregisters.P = {false, false, true, false, false, false, false, false};
    if ((binary_P >> 0) & 0x1)
        CPUregisters.P.Carry = true;
    if ((binary_P >> 1) & 0x1)
        CPUregisters.P.Zero = true;
    if ((binary_P >> 2) & 0x1)
        CPUregisters.P.Interrupt = true;
    if ((binary_P >> 3) & 0x1)
        CPUregisters.P.Decimal = true;
    if ((binary_P >> 4) & 0x1)
        CPUregisters.P.Break = true;
    if ((binary_P >> 5) & 0x1)
        CPUregisters.P.Resersved = true;
    if ((binary_P >> 6) & 0x1)
        CPUregisters.P.Overflow = true;
    if ((binary_P >> 7) & 0x1)
        CPUregisters.P.Negative = true;
}

void CPU::reset()
{
    // printf("%x\n", CPUregisters.PC);
    uint8_t high = ramread(0xFFFD);
    uint8_t low = ramread(0xFFFC);
    CPUregisters.PC = (high << 8) | low;
    // CPUregisters.PC = 0xC00e;
    printf("reset:%4x\n", CPUregisters.S);
    return;
}

uint8_t CPU::fetch()
{
    return ramread(CPUregisters.PC++);
}

uint16_t CPU::fetchOpeland(addressingMode mode)
{
    switch (mode)
    {
    case accumulator:
        return 0x0000;
    case implied:
        return 0x0000;
    case immediate:
        return CPU::fetch();
    case zeroPage:
        return (0x00FF & CPU::fetch());
    case zeroPageX:
    {
        uint8_t addr = CPU::fetch();
        return (addr + CPUregisters.X) & 0xFF;
    }
    case zeroPageY:
    {
        uint8_t addr = CPU::fetch();
        return (addr + CPUregisters.Y) & 0xFF;
    }
    case absolute:
    {
        uint16_t addr1 = CPU::fetch();
        uint16_t addr2 = (CPU::fetch()) << 8;
        return (addr1 | addr2);
    }
    case absoluteX:
    {
        uint16_t addr1 = CPU::fetch();
        uint16_t addr2 = (CPU::fetch()) << 8;
        return addr1 + addr2 + CPUregisters.X;
    }
    case absoluteY:
    {
        uint16_t addr1 = CPU::fetch();
        uint16_t addr2 = (CPU::fetch()) << 8;
        return addr1 + addr2 + CPUregisters.Y;
    }
    case relative:
    {
        uint16_t pc = CPUregisters.PC;
        uint16_t addr1 = CPU::fetch();
        if (addr1 < 0x80)
            return CPUregisters.PC + addr1;
        else
            return (addr1 | 0xFF00) + CPUregisters.PC;
    }
    case preIndexedIndirect:
    {
        uint16_t addr1 = 0x00FF & (CPU::fetch() + CPUregisters.X);
        uint8_t addr1data = ramread(addr1);
        uint16_t addr = ((ramread((addr1 + 1) & 0x00FF) & 0xFF) << 8) | addr1data;
        return addr;
    }
    case postIndexedIndirect:
    {
        uint16_t addr1 = CPU::fetch() & 0x00FF;
        uint8_t addr1data = ramread(addr1);
        uint16_t addr = (addr1data) + (ramread((addr1 + 1) & 0xFF) << 8) + CPUregisters.Y;
        return addr;
    }
    case indirectAbsolute:
    {
        uint16_t addr1 = CPU::fetch() + (CPU::fetch() << 8);
        uint16_t addr = ramread(addr1) + (ramread(addr1 & 0xFF00 | ((addr1 + 1) & 0x00FF)) << 8);
        return addr;
    }
    }
    return 0x0000;
}

void CPU::exec(baseName &basename, uint16_t opeland, addressingMode &mode)
{
    switch (basename)
    {
    case LDA:
    {
        if (mode != immediate)
            CPUregisters.A = ramread(opeland);
        else
            CPUregisters.A = opeland;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0x00);
        break;
    }
    case LDX:
    {
        if (mode != immediate)
            CPUregisters.X = ramread(opeland);
        else
            CPUregisters.X = opeland;
        CPUregisters.P.Negative = (CPUregisters.X & 0x80);
        CPUregisters.P.Zero = (CPUregisters.X == 0x00);
        break;
    }
    case LDY:
    {
        if (mode != immediate)
            CPUregisters.Y = ramread(opeland);
        else
            CPUregisters.Y = opeland;
        CPUregisters.P.Negative = (CPUregisters.Y & 0x80);
        CPUregisters.P.Zero = (CPUregisters.Y == 0x00);
        break;
    }

    case STA:
        ramwrite(opeland, CPUregisters.A);
        break;
    case STX:
        ramwrite(opeland, CPUregisters.X);
        break;
    case STY:
        ramwrite(opeland, CPUregisters.Y);
        break;

    case TXA:
    {
        CPUregisters.A = CPUregisters.X;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0x00);
        break;
    }
    case TYA:
    {
        CPUregisters.A = CPUregisters.Y;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0x00);
        break;
    }
    case TXS:
    {
        CPUregisters.S = 0x0100 | CPUregisters.X;
        break;
    }
    case TAY:
    {
        CPUregisters.Y = CPUregisters.A;
        CPUregisters.P.Negative = (CPUregisters.Y & 0x80);
        CPUregisters.P.Zero = (CPUregisters.Y == 0x00);
        break;
    }
    case TAX:
    {
        CPUregisters.X = CPUregisters.A;
        CPUregisters.P.Negative = (CPUregisters.X & 0x80);
        CPUregisters.P.Zero = (CPUregisters.X == 0x00);
        break;
    }
    case TSX:
    {
        CPUregisters.X = CPUregisters.S;
        CPUregisters.P.Negative = (CPUregisters.X & 0x80);
        CPUregisters.P.Zero = (CPUregisters.X == 0x00);
        break;
    }
    case PHP:
    {
        ramwrite(CPUregisters.S, (zipP() | (1 << 4) | (1 << 5))); //よくわからないがbreakflagを立てて入れる
        CPUregisters.S--;
        break;
    }
    case PLP:
    {
        CPUregisters.S++;
        uint8_t binary_P = (ramread(CPUregisters.S) & ~(1 << 4)) | (1 << 5); //breakflagはクリアしておく
        unzipP(binary_P);
        break;
    }
    case PHA:
    {
        ramwrite(CPUregisters.S, CPUregisters.A);
        CPUregisters.S--;
        break;
    }
    case PLA:
    {
        CPUregisters.S++;
        CPUregisters.A = ramread(CPUregisters.S);
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0x00);
        break;
    }
    case ADC:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        uint16_t result = CPUregisters.A + argment + CPUregisters.P.Carry;
        CPUregisters.P.Carry = (result & 0xFF00);
        CPUregisters.P.Overflow = (!((((CPUregisters.A ^ argment)) >> 7) & 1) && ((((argment ^ result)) >> 7) & 1));
        CPUregisters.P.Negative = (result & 0x80);
        CPUregisters.P.Zero = ((result & 0x00FF) == 0x0000);
        CPUregisters.A = result & 0xFF;
        break;
    }
    case SBC:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = ~opeland;
        else
            argment = ~ramread(opeland);
        uint16_t result = CPUregisters.A + argment + CPUregisters.P.Carry;
        CPUregisters.P.Carry = (result & 0xFF00);
        CPUregisters.P.Overflow = (!((((CPUregisters.A ^ argment)) >> 7) & 1) && ((((argment ^ result)) >> 7) & 1));
        CPUregisters.P.Negative = (result & 0x80);
        CPUregisters.P.Zero = ((result & 0x00FF) == 0x0000);
        CPUregisters.A = result & 0xFF;
        break;
    }
    case CPX:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.P.Carry = (CPUregisters.X - argment >= 0);
        CPUregisters.P.Zero = (CPUregisters.X - argment == 0);
        CPUregisters.P.Negative = ((CPUregisters.X - argment) & 0x80);
        break;
    }
    case CPY:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.P.Carry = (CPUregisters.Y - argment >= 0);
        CPUregisters.P.Zero = (CPUregisters.Y - argment == 0);
        CPUregisters.P.Negative = ((CPUregisters.Y - argment) & 0x80);
        break;
    }
    case CMP:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.P.Carry = (CPUregisters.A - argment >= 0);
        CPUregisters.P.Zero = (CPUregisters.A == argment);
        CPUregisters.P.Negative = ((CPUregisters.A - argment) & 0x80);
        break;
    }
    case AND:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.A &= argment;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0);
        break;
    }
    case ORA:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.A |= argment;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0);
        break;
    }
    case EOR:
    {
        uint8_t argment;
        if (mode == immediate)
            argment = opeland;
        else
            argment = ramread(opeland);
        CPUregisters.A ^= argment;
        CPUregisters.P.Negative = (CPUregisters.A & 0x80);
        CPUregisters.P.Zero = (CPUregisters.A == 0);
        break;
    }
    case BIT:
    {
        uint8_t argment = ramread(opeland);
        CPUregisters.P.Negative = ((argment >> 7) & 1);
        CPUregisters.P.Overflow = ((argment >> 6) & 1);
        CPUregisters.P.Zero = !(argment & CPUregisters.A);
        break;
    }
    case ASL:
    {
        if (mode == accumulator)
        {
            CPUregisters.P.Carry = (CPUregisters.A >> 7) & 1;
            CPUregisters.A = (CPUregisters.A) << 1;
            CPUregisters.P.Negative = (CPUregisters.A & 0x80);
            CPUregisters.P.Zero = (CPUregisters.A == 0);
        }
        else
        {
            uint8_t argment = ramread(opeland);
            CPUregisters.P.Carry = (argment >> 7) & 1;
            argment = argment << 1;
            CPUregisters.P.Negative = (argment & 0x80);
            CPUregisters.P.Zero = (argment == 0);
            ramwrite(opeland, argment);
        }
        break;
    }

    case LSR:
    {
        if (mode == accumulator)
        {
            CPUregisters.P.Carry = ((CPUregisters.A) & 1);
            CPUregisters.A = (((CPUregisters.A) >> 1) & (~(0x80)));
            CPUregisters.P.Negative = (CPUregisters.A & 0x80);
            CPUregisters.P.Zero = (CPUregisters.A == 0);
        }
        else
        {
            uint8_t argment = ramread(opeland);
            CPUregisters.P.Carry = (argment >> 0) & 1;
            argment = argment >> 1;
            CPUregisters.P.Negative = (argment & 0x80);
            CPUregisters.P.Zero = (argment == 0);
            ramwrite(opeland, argment);
        }
        break;
    }
    case ROL:
    {
        if (mode == accumulator)
        {
            uint8_t argment = CPUregisters.A << 1;
            argment |= CPUregisters.P.Carry;
            CPUregisters.P.Carry = (CPUregisters.A >> 7) & 1;
            CPUregisters.P.Negative = (argment & 0x80);
            CPUregisters.P.Zero = (argment == 0);
            CPUregisters.A = argment;
        }
        else
        {
            uint8_t argment = ramread(opeland);
            // printf("%4x\n", argment);
            uint8_t write_argment = argment << 1;
            write_argment |= CPUregisters.P.Carry;
            CPUregisters.P.Carry = (argment >> 7) & 1;
            CPUregisters.P.Negative = (write_argment & 0x80);
            CPUregisters.P.Zero = (write_argment == 0);
            // printf("%4x\n", argment);
            ramwrite(opeland, write_argment);
        }
        break;
    }
    case ROR:
    {
        if (mode == accumulator)
        {
            uint8_t argment = CPUregisters.A >> 1;
            argment |= (CPUregisters.P.Carry << 7);
            CPUregisters.P.Carry = (CPUregisters.A >> 0) & 1;
            CPUregisters.P.Negative = (argment & 0x80);
            CPUregisters.P.Zero = (argment == 0);
            CPUregisters.A = argment;
        }
        else
        {
            uint8_t argment = ramread(opeland);
            uint8_t write_argment = argment >> 1;
            write_argment |= (CPUregisters.P.Carry << 7);
            CPUregisters.P.Carry = (argment >> 0) & 1;
            CPUregisters.P.Negative = (write_argment & 0x80);
            CPUregisters.P.Zero = (write_argment == 0);
            ramwrite(opeland, write_argment);
        }
        break;
    }
    case INX:
    {
        CPUregisters.X++;
        CPUregisters.P.Negative = (CPUregisters.X & 0x80);
        CPUregisters.P.Zero = (CPUregisters.X == 0);
        break;
    }
    case INY:
    {
        CPUregisters.Y++;
        CPUregisters.P.Negative = (CPUregisters.Y & 0x80);
        CPUregisters.P.Zero = (CPUregisters.Y == 0);
        break;
    }
    case DEY:
    {
        CPUregisters.Y--;
        CPUregisters.P.Negative = (CPUregisters.Y & 0x80);
        CPUregisters.P.Zero = (CPUregisters.Y == 0);
        break;
    }
    case DEX:
    {
        CPUregisters.X--;
        CPUregisters.P.Negative = (CPUregisters.X & 0x80);
        CPUregisters.P.Zero = (CPUregisters.X == 0);
        break;
    }
    case INC:
    {
        int8_t argment = ramread(opeland);
        argment++;
        CPUregisters.P.Negative = (argment & 0x80);
        CPUregisters.P.Zero = (argment == 0);
        ramwrite(opeland, argment);
        break;
    }
    case DEC:
    {
        int8_t argment = ramread(opeland);
        argment--;
        CPUregisters.P.Negative = (argment & 0x80);
        CPUregisters.P.Zero = (argment == 0);
        ramwrite(opeland, argment);
        break;
    }
    case CLC:
    {
        CPUregisters.P.Carry = 0;
        break;
    }
    case SEC:
    {
        CPUregisters.P.Carry = 1;
        break;
    }
    case CLI:
    {
        CPUregisters.P.Interrupt = 0;
        break;
    }
    case SEI:
    {
        CPUregisters.P.Interrupt = 1;
        break;
    }
    case NOP:
    {
        break;
    }
    case BRK:
    {
        if (!CPUregisters.P.Interrupt)
        {
            print();
            CPUregisters.PC++;
            uint8_t pc1 = (0xFF & (CPUregisters.PC >> 8));
            ramwrite(CPUregisters.S--, pc1);
            uint8_t pc2 = (CPUregisters.PC & 0xFF);
            ramwrite(CPUregisters.S--, pc2);
            ramwrite(CPUregisters.S--, zipP());
            CPUregisters.PC = ramread(0xFFFF) << 8 | ramread(0xFFFE);
            CPUregisters.P.Break = true;
            CPUregisters.P.Interrupt = true;
            // printf("pc1:%4x,pc2:%4x PC:%4x\n", pc1, pc2, CPUregisters.PC);
        }
        break;
    }
    case JSR:
    {
        uint16_t address = opeland;
        uint16_t pc = CPUregisters.PC - 1;
        // printf("pc:%4x, high: %4x, low: %4x, stack: %4x\n", pc, pc >> 8, pc & 0xFF, CPUregisters.S);
        ramwrite(CPUregisters.S, pc >> 8);
        CPUregisters.S--;
        ramwrite(CPUregisters.S, pc & 0x00FF);
        CPUregisters.S--;
        CPUregisters.PC = address;
        break;
    }
    case JMP:
    {
        uint16_t address = opeland;
        CPUregisters.PC = address;
        // printf("%d\n", CPUregisters.PC);
        break;
    }
    case RTI:
    {
        uint8_t binary_P = ramread(++CPUregisters.S);
        unzipP(binary_P);
        uint16_t pc = ramread(++CPUregisters.S);
        pc |= (ramread(++CPUregisters.S) << 8);
        CPUregisters.PC = pc;
        break;
    }
    case RTS:
    {
        uint16_t pc = ramread(++CPUregisters.S);
        // printf("stack: %4x pc:%4x\n", CPUregisters.S, pc);
        pc |= (ramread(++CPUregisters.S) << 8);
        // printf("stack: %4x pc:%4x\n", CPUregisters.S, pc);
        CPUregisters.PC = pc + 1;
        break;
    }
    case BPL:
    {
        if (!CPUregisters.P.Negative)
            CPUregisters.PC = opeland;
        break;
    }
    case BMI:
    {
        if (CPUregisters.P.Negative)
            CPUregisters.PC = opeland;
        break;
    }
    case BVC:
    {
        if (!CPUregisters.P.Overflow)
            CPUregisters.PC = opeland;
        break;
    }
    case BVS:
    {
        if (CPUregisters.P.Overflow)
            CPUregisters.PC = opeland;
        break;
    }
    case BCC:
    {
        if (!CPUregisters.P.Carry)
            CPUregisters.PC = opeland;
        break;
    }
    case BCS:
    {
        if (CPUregisters.P.Carry)
            CPUregisters.PC = opeland;
        break;
    }
    case BNE:
    {
        if (!CPUregisters.P.Zero)
            CPUregisters.PC = opeland;
        break;
    }
    case BEQ:
    {
        if (CPUregisters.P.Zero)
            CPUregisters.PC = opeland;
        break;
    }
    case SED:
    {
        CPUregisters.P.Decimal = 1;
        break;
    }
    case CLD:
    {
        CPUregisters.P.Decimal = 0;
        break;
    }
    case CLV:
    {
        CPUregisters.P.Overflow = 0;
        break;
    }
    default:
    {
        exit(1);
        break;
    }
    }
    return;
}
uint8_t CPU::ramread(uint16_t address)
{
    if (address < 0x0800)
    {
        return *(RAM + address);
    }
    else if (address < 0x2000)
    {
        return ramread(address - 0x0800);
    }

    // printf("%x\n", *(RAM + address));
    else if (address < 0x4000)
    {
        return vramread_cpu((address - 0x2000) % 8);
    }
    else if (address == 0x4016)
    { //コントローラー
        return send_pad_info();
    }
    return *(RAM + address);
}
void CPU::ramwrite(uint16_t address, u_int8_t data)
{
    if (address == 0x0100)
    {
        // printf("0x0100\n");
    }
    if (address == 0x2000)
    {
        PPUregister.ppuctrl = data;
        return;
    }
    if (address == 0x2001)
    {
        PPUregister.ppumask = data;
        return;
    }
    if (address == 0x2002)
    {
        return;
    }
    if (address == 0x2003)
    {
        PPUregister.oamaddr = data;
        return;
    }
    if (address == 0x2004)
    {
        vramwrite(address, data);
    }
    if (address == 0x2005)
    {
        PPUregister.ppuscroll = data;
        return;
    }
    if (address == 0x2006)
    {

        if (!ppuaddr_flag)
        {
            ppuaddr_buffer = 0;
            ppuaddr_buffer |= (data << 8);
        }
        else
        {
            ppuaddr_buffer |= data;
            PPUregister.ppuaddr = ppuaddr_buffer;
        }
        ppuaddr_flag ^= 1;
        return;
    }
    if (address == 0x2007)
    {
        // printf("call vramwrite\n");
        vramwrite(address, data);
        return;
    }
    if (address == 0x4016)
    { //コントローラー
        pad_init(data);
        return;
    }
    if (address == 0x4014)
    { //DMA
        // printf("call dma\n");
        exec_dma(data);
        return;
    }
    if (address >= 0x800 && address <= 0x1fff)
    {
        ramwrite(address - 0x800, data);
    }
    *(RAM + address) = data;
    return;
}

uint8_t CPU::run()
{
    // printf("=======\n");
    uint8_t prev_code = ramread(CPUregisters.PC);
    // print();
    const uint8_t opecode = CPU::fetch();
    opecodestructure opest = opecodeList[opecode];
    baseName basename = opest.basename;
    addressingMode mode = opest.mode;
    uint8_t cycle = opest.cycle;
    uint16_t opeland = fetchOpeland(mode);
    // cout << dictionary[opecode];
    // printf("%4x A:%4x\n", opeland, CPUregisters.A);
    exec(basename, opeland, mode);
    return cycle;
}

void CPU::print()
{
    printf("A:%4x,X:%4x, Y:%4x, ,P:%4x, PC:%4x, SP:%4x\n", CPUregisters.A, CPUregisters.X, CPUregisters.Y, zipP(), CPUregisters.PC, CPUregisters.S);
    return;
}

void CPU::NMI()
{
    // printf("callnmi\n");
    CPUregisters.P.Break = false;
    uint8_t pc1 = (CPUregisters.PC >> 8);
    ramwrite(CPUregisters.S--, pc1);
    uint8_t pc2 = (CPUregisters.PC & 0xFF);
    ramwrite(CPUregisters.S--, pc2);
    ramwrite(CPUregisters.S--, zipP());
    CPUregisters.P.Interrupt = true;
    CPUregisters.PC = (ramread(0xFFFB) << 8) | ramread(0xFFFA);
    // printf("high:%4x, low:%4x\n", ramread(0xFFFB), ramread(0xFFFA));
    return;
}
void CPU::IRQ()
{
    if (!(CPUregisters.P.Interrupt))
    {
        CPUregisters.P.Break = false;
        uint8_t pc1 = (CPUregisters.PC >> 8);
        ramwrite(CPUregisters.S--, pc1);
        uint8_t pc2 = (CPUregisters.PC & 0xFF);
        ramwrite(CPUregisters.S--, pc2);
        ramwrite(CPUregisters.S--, zipP());
        CPUregisters.P.Interrupt = true;
        CPUregisters.PC = ramread(0xFFFB) << 8 | ramread(0xFFFA);
    }
}