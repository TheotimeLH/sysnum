# carotte.py by TWal, hbens & more

from lib_carotte import *

from netlist_python.registres import gestion_registres
from netlist_python.alu import alu
from netlist_python.decodeur import decodeur


#TEMPORAIRE, À IMPORTER 
def sept_batons(a) :
    return Constant("0"*16)
#----------------------

allow_ribbon_logic_operations(True)

def main():
    #initialisation
    prog_rom_addr_size = 10
    prog_rom_word_size = 32
    line_incr = Constant("1")
    reg_size = 16
    ram_addr_size = 10
    ram_word_size = 16
    addr_size_batons = 10
    word_size_batons = 16
    
    #line_init = Constant("0000000000")    
   

    def liseur_code(jump_line, jump_flag, line_incr) :
        def incr_line(a):
            b = Constant("1")
            s = a[0] ^ b
            b = a[0] & b
            for i in range(1, prog_rom_addr_size):
                s = s + (a[i] ^ b)
                b = a[i] & b
            return s
        line_plus = incr_line(curr_line)
        next_line = Mux(jump_flag, line_plus, jump_line)
        return next_line
    
    def interf_alu(value_reg1, value_reg2, entier, resultat_nul, resultat_neg, operation_brute) :
        def decode_op(operation_brute) :
            return operation_brute[0:4], operation_brute[4]

        code_operation, op_entier = decode_op(operation_brute)
        resultat_precedent_nul = Reg(resultat_nul)
        resultat_precedent_neg = Reg(resultat_neg)
        value1 = value_reg1
        value2 = Mux(op_entier, value_reg2, entier)
        operation, op_entier = decode_op(operation_brute)
        return value1, value2, resultat_precedent_nul, resultat_precedent_neg, operation



    #obtention du code
    curr_line = Reg(Defer(prog_rom_addr_size, lambda:next_line))
    curr_code = ROM(prog_rom_addr_size, prog_rom_word_size, curr_line)
    
    jump_line, jump_flag_inconditionnel, jump_flag_neg, jump_flag_non_neg, jump_flag_nul, jump_flag_non_nul, operation_brute, entier, read_addr1, read_addr2, write_addr_reg, write_enable_reg, write_enable_ram, lire_la_clock, sauver_resultat_alu, batonnage = decodeur(curr_code)
    
    next_line = liseur_code(jump_line, Defer(1, lambda:jump_flag), curr_line)

    #registres
    value_reg1, value_reg2 = gestion_registres(read_addr1, read_addr2, write_addr_reg, write_enable_reg, Defer(reg_size, lambda:write_data_reg))

    #calcul
    value1, value2, resultat_precedent_nul, resultat_precedent_neg, operation = interf_alu(value_reg1, value_reg2, entier, Defer(1, lambda:resultat_nul), Defer(1, lambda:resultat_neg), operation_brute)

    resultat, resultat_nul, resultat_neg = alu(value1, value2, operation)
    

    #écriture
    write_data_reg = Mux(sauver_resultat_alu, Defer(16, lambda:autre_sauv), resultat)
    
    ram_addr = resultat

    ram_value = RAM(ram_addr_size, ram_word_size, resultat[6:16], write_enable_ram, resultat[6:16], value_reg2)

    #drapeau de saut
    jump_flag = jump_flag_inconditionnel | (jump_flag_neg & resultat_precedent_neg) | (jump_flag_nul & resultat_precedent_nul)

    #gestions des batons et de la ram à batons
    batonnage.set_as_output("maj_ecran")
    batons = Mux(batonnage, Constant("0"*16), sept_batons(value_reg2))
    ram_batons = RAM(addr_size_batons, word_size_batons, resultat[6:16], batonnage, resultat[6:16], batons)
    

    #gestion de la real_clock
    real_clock = Input(1)
    rclock_bus = Constant("0"*15) + real_clock
    
    autre_sauv = Mux(lire_la_clock, ram_value, rclock_bus)



