from lib_carotte import *

def decodeur(code) :
    commande = code[0:8]
    entier = code[8:24]
    read_addr1 = code[24:28]
    read_addr2 = code[28:32]
    write_addr_reg = read_addr2
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
    jump_flag_non_neg = Mux(sautage, zero, (~c3 & c4 & ~c5 & c6))
    jump_flag_nul = Mux(sautage, zero, (~c3 & ~c4 & c5 & ~c6))
    jump_flag_non_nul = Mux(sautage, zero, (~c3 & ~c4 & c5 & c6))
    
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





# jump_line                     indique la ligne de saut 
# jump_flag_inconditionnel      vaut 1 si la commande est un saut incond.
# jump_flag_neg                 idem pour saut <0
# jump_flag_non_neg             idem pour saut >=0
# jump_flag_non_nul             idem pour saut !=0
# jump_flag_nul                 idem pour saut ==0
# operation_brute               la partie de la commande qui concerne l'opération
# entier                        l'entier stocké dans la commande
# read_addr1                    1ere adresse de lecture des registres
# read_addr2                    2eme
# write_addr_reg                adresse d'ecriture des registres
# write_enable_reg              indicateur sur 1 bit
# write_enable_ram              indicateur sur 1 bit
# clock                         indicateur sur 1 bit
# sauver_resultat_alu           indicateur sur 1 bit
# batonnage                     indicateur sur 1 bit