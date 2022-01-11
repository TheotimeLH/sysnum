from lib_carotte import *
reg_size = 16
allow_ribbon_logic_operations(True)

def gestion_registres(read_addr1, read_addr2, write_addr, write_enable, write_data) :
    def registre(write_data, write_enable) :
        new_value = Mux(write_enable, Defer(reg_size, lambda:former_value), write_data)
        former_value = Reg(new_value)
        return former_value
    zero = Constant("0")

    a1_1 = read_addr1[1]
    a1_2 = read_addr1[2]
    a1_3 = read_addr1[3]

    a2_1 = read_addr2[1]
    a2_2 = read_addr2[2]
    a2_3 = read_addr2[3]

    w_1 = write_addr[1]
    w_2 = write_addr[2]
    w_3 = write_addr[3]

    w_e_1_to_4 = write_enable & write_addr[0] & ~w_1
    w_e_1_to_2 = w_e_1_to_4 & ~ w_2
    w_e_r1 = w_e_1_to_2 & ~w_3
    w_e_r2 = w_e_1_to_2 & w_3
    w_e_3_to_4 = w_e_1_to_4 & ~w_e_1_to_2
    w_e_r3 = w_e_3_to_4 & ~w_3
    w_e_r4 = w_e_3_to_4 & w_3
    w_e_5_to_8 = write_enable & write_addr[0] & w_1
    w_e_5_to_6 = w_e_5_to_8 & ~ w_2
    w_e_rax = w_e_5_to_6 & ~w_3
    w_e_rbx = w_e_5_to_6 & w_3
    w_e_7_to_8 = w_e_5_to_8 & ~w_e_5_to_6
    w_e_rcx = w_e_7_to_8 & ~w_3
    w_e_rck = w_e_7_to_8 & w_3


    
    r1 = registre(write_data, w_e_r1)
    r2 = registre(write_data, w_e_r2)
    r3 = registre(write_data, w_e_r3)
    r4 = registre(write_data, w_e_r4)
    rax = registre(write_data, w_e_rax)
    rbx = registre(write_data, w_e_rbx)
    rcx = registre(write_data, w_e_rcx)
    rck = registre(write_data, w_e_rck)
    
    def multimultiplexeur(a_1, a_2, a_3, r1, r2, r3, r4, rax, rbx, rcx, rck) :
        val_12 = Mux(a_3, r1, r2)
        val_34 = Mux(a_3, r3, r4)
        val_14 = Mux(a_2, val_12, val_34)
        val_56 = Mux(a_3, rax, rbx)
        val_78 = Mux(a_3, rcx, rck)
        val_58 = Mux(a_2, val_56, val_78)
        val = Mux(a_1, val_14, val_58)
        return val
    
    val1 = multimultiplexeur(a1_1, a1_2, a1_3, r1, r2, r3, r4, rax, rbx, rcx, rck)
    val2 = multimultiplexeur(a2_1, a2_2, a2_3, r1, r2, r3, r4, rax, rbx, rcx, rck)
 

    value_reg1 = Mux(read_addr1[0], Constant("0"*16), val1)
    value_reg2 = Mux(read_addr2[0], Constant("0"*16), val2)

    return value_reg1, value_reg2


def main() :
    r1 = Input(4)
    r2 = Input(4)
    wa = Input(4)
    we = Input(1)
    w_value = Input(16)
    reg1, reg2 = gestion_registres(r1, r2, wa, we, w_value) 
    reg1.set_as_output("val1")
    reg2.set_as_output("val2")
