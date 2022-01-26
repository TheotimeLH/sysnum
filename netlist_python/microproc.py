# carotte.py by TWal, hbens & more

from lib_carotte import *

from netlist_python.registres import gestion_registres
from netlist_python.alu import alu
from netlist_python.decodeur import decodeur
from netlist_python.batonneur import batonneur as sept_batons

allow_ribbon_logic_operations(True)
DEBOGUE_MODE = True

def main():
    #initialisation
    prog_rom_addr_size = 10
    prog_rom_word_size = 32
    reg_size = 16
    ram_addr_size = 10
    ram_word_size = 16
    addr_size_batons = 10
    word_size_batons = 16
    rom2_word_size = 16
    rom2_addr_size = 8
    #Ne pas changer ces variables, sans quoi le microprocesseur ne marchera plus

    #line_init = Constant("0000000000")    


    def liseur_code(jump_line, jump_flag, curr_line) :
        def incr_line(a):
            b = Constant("1")
            for i in range(prog_rom_addr_size - 1):
                c = a[prog_rom_addr_size - i -1] & b[0]
                b = c + b
            return a ^ b
        line_plus = incr_line(curr_line)
        next_line = Mux(jump_flag, line_plus, jump_line)
        return next_line

    def interf_alu(value_reg1, value_reg2, entier, resultat_nul, resultat_neg, operation_brute, operande_gauche, operande_droit) :

        operation = operation_brute[0:4]
        resultat_precedent_nul = Reg(resultat_nul)
        resultat_precedent_neg = Reg(resultat_neg)
        value1 = Mux(operande_gauche, value_reg1, value_reg2)
        value2 = Mux(operande_droit, value_reg1, entier)
        return value1, value2, resultat_precedent_nul, resultat_precedent_neg, operation



    #obtention du code
    curr_line = Reg(Defer(prog_rom_addr_size, lambda:next_line))
    curr_code = ROM(prog_rom_addr_size, prog_rom_word_size, curr_line)

    jump_line, jump_flag_inconditionnel, jump_flag_neg, jump_flag_non_neg, jump_flag_nul, jump_flag_non_nul, operation_brute, entier, read_addr1, read_addr2, write_addr_reg, write_enable_reg, write_enable_ram, lire_la_clock, sauver_resultat_alu, batonnage, lire_la_rom, operande_gauche, operande_droit , stop_prgm = decodeur(curr_code)
    stop_prgm.set_as_output("stop_prgm")
    next_line = liseur_code(jump_line, Defer(1, lambda:jump_flag), curr_line)

    #registres
    value_reg1, value_reg2 = gestion_registres(read_addr1, read_addr2, write_addr_reg, write_enable_reg, Defer(reg_size, lambda:write_data_reg))

    #calcul
    value1, value2, resultat_precedent_nul, resultat_precedent_neg, operation = interf_alu(value_reg1, value_reg2, entier, Defer(1, lambda:resultat_nul), Defer(1, lambda:resultat_neg), operation_brute, operande_gauche, operande_droit)

    resultat, resultat_nul, resultat_neg = alu(value1, value2, operation)


    #écriture
    write_data_reg = Mux(sauver_resultat_alu, Defer(16, lambda:autre_sauv), resultat)

    ram_addr = resultat

    rom_input = ROM(rom2_addr_size, rom2_word_size, resultat[8:16])

    ram_value = RAM(ram_addr_size, ram_word_size, resultat[6:16], write_enable_ram, resultat[6:16], value_reg2)

    #drapeau de saut
    jump_flag = jump_flag_inconditionnel | (jump_flag_neg & resultat_precedent_neg) | (jump_flag_nul & resultat_precedent_nul) | (jump_flag_non_neg & ~resultat_precedent_neg)| (jump_flag_non_nul & ~resultat_precedent_nul)

    #gestions des batons et de la ram à batons
    batonnage.set_as_output("maj_ecran")
    batons = Mux(batonnage, Constant("0"*16), sept_batons(value_reg2))
    ram_batons = RAM(addr_size_batons, word_size_batons, resultat[6:16], batonnage, resultat[6:16], batons)


    #gestion de la real_clock
    real_clock = Input(1)
    rclock_bus = Constant("0"*15) + real_clock


    #sauvegarde dans les registres
    autre_sauv_interm = Mux(lire_la_rom, ram_value, rom_input)
    autre_sauv = Mux(lire_la_clock, autre_sauv_interm, rclock_bus)

    if DEBOGUE_MODE :
        next_step = Input(1)
        next_step.set_as_output("j_espere_que_le_debogue_marche")
        curr_line.set_as_output("ligne_actuelle")
        jump_flag.set_as_output("jump_flag")
        entier.set_as_output("entier")
        operation_brute.set_as_output("operation_brute")
        read_addr1.set_as_output("registre1")
        read_addr2.set_as_output("registre2_et_add_ecriture")
        write_enable_reg.set_as_output("write_enable_reg")
        write_enable_ram.set_as_output("write_enable_ram")
        lire_la_clock.set_as_output("lecture_clock")
        lire_la_rom.set_as_output("lecture_rom")
        sauver_resultat_alu.set_as_output("sauvegarde_resultat_alu")
        batonnage2 = ~(~batonnage)
        batonnage2.set_as_output("batonnage")
        value_reg1.set_as_output("valeur_reg1")
        value_reg2.set_as_output("valeur_reg2")
        value1.set_as_output("operande1")
        value2.set_as_output("operande2")
        operation.set_as_output("operation_realisee")
        resultat.set_as_output("resultat")
        write_data_reg.set_as_output("valeur_enregistree_registres")
        ram_value.set_as_output("valeur_lue_ram")
        rom_input.set_as_output("valeur_lue_rom")
        batons.set_as_output("batons")
        real_clock.set_as_output("real_clock")
        
        







