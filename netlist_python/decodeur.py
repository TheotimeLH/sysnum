from lib_carotte import *

def decodeur(code) :
    commande = code[0:8]
    entier = code[8:24]
    read_addr_1 = code[24:28]
    read_addr_2 = code[28:32]
    write_addr_reg = read_addr_2
    zero = Constant("0")
    un = Constant("1")
    
    c0 = commande[0]
    c1 = commande[1]
    c2 = commande[2]
    c3 = commande[3]
    c4 = commande[4]
    c5 = commande[5]
    c6 = commande[6]
    c7 = commande[7]

    #gestion des sauts
    sautage = c0 & ~(c1 | c2)
    jump_flag_inconditionnel = Mux(sautage, zero, (~c3 & ~c4 & ~c5 & c6))
    jump_flag_neg = Mux(sautage, zero, (~c3 & c4 & ~c5 & ~c6))
    jump_flag_not_neg = Mux(sautage, zero, (~c3 & c4 & ~c5 & c6))
    jump_flag_nul = Mux(sautage, zero, (~c3 & ~c4 & c5 & ~c6))
    jump_flag_not_nul = Mux(sautage, zero, (~c3 & ~c4 & c5 & c6))
    
    jump_line = entier
 
 
    #operation brute
    operation_op = commande[3:8]
    operation_ram = Constant("00011")
    operation_pas_doperation = Constant("00000")
    pas_de_calcul = (~c0 & ~c1 & c2) | (~c0 & c1 & c2 & c7) | (c0 & ~c1 & ~c7)
    calcul_daddresse = (~c0 & c1 & c2 & ~c7) | (c0 & ~c1 & c2 & c5 & ~c6 & c7) 
    operation = Mux(calcul_daddresse, operation_op, operation_ram)
    operation_brute = Mux(pas_de_calcul, operation, operation_pas_doperation)

    #indicatrice de "lecture de la clock"
    lire_la_clock = c0 & ~c1 & c2 & ~c5 & c6


    #write_enable
    write_enable_ram = ~c0 & c1 & c2 & ~c3 & ~c4 & c5 & ~c6
    write_enable_reg = ~(c0 | write_enable_ram ) | lire_la_clock
   
    #chargement ou calcul
    sauver_resultat_alu = (c0 ^ c1) & c2 #catégorie rom ram ou clock

    batonnage = c0 & ~c1 & c2 & c5 & ~c6

    return jump_line, jump_flag_inconditionnel, jump_flag_neg, jump_flag_non_neg, jump_flag_nul, jump_flag_non_nul, operation_brute, entier, read_addr1, read_addr2, write_addr_reg, write_enable_reg, write_enable_ram, lire_la_clock, sauver_resultat_alu, batonnage





# jump_line                     ok
# jump_flag_inconditionnel      ok
# jump_flag_neg                 ok
# jump_flag_non_neg             ok
# jump_flag_non_nul             ok
# jump_flag_nul                 ok
# operation_brute               ok
# entier                        ok
# read_addr1                    ok
# read_addr2                    ok
# write_addr_reg                ok
# write_enable_reg              ok
# write_enable_ram              ok
# clock                         ok
# sauver_resultat_alu           ok
# batonnage                     ok
