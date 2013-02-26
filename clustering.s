########################################
# Proyecto 1                           #
# María Gracia Hidalgo Carnet 03-36048 #
########################################

# Declaración de Constantes

LEN = 1000
LF = 10

     .data
archivo: .asciiz "ejemplo.txt"
buf:     .space 1000
espacio: .word 0:200
distancias: .word 0:50
nombres: .word 0:50
m1: .asciiz "\n"
m2: .asciiz " Mensaje 2 \n"
separador: .asciiz " - "
componentes: .word 0
parametros: .word 0
clusters: .word 0
longitud: .word 0

    # Planificación de Registros
    # $s1 file descriptor

    .text

main:
    # Se abre el archivo
    # Abro archivo

    li $v0 13 
    la $a0 archivo    # Nombre del archivo
    li $a1 0x0        # Flag
    syscall

    move $s0, $v0     # Se respalda el descriptor del archivo

    # Lectura de la cardinalidad de los datos
    move $a0 $s0
    la $a1, buf
    li $a2 LEN
    li $v0 14
    syscall

    blez $v0 fin
    
    # Obtiene el número de componentes de la muestra
    lb $t0 0($a1)
    # Calcula el valor entero del componente de la muestra
    addi $t0 $t0 -48
    # Almacena el valor de los componentes
    sw $t0 componentes

    # Obtiene el número de parámetros de cada componente
    addi $a1 $a1 2
    lb $t0 0($a1)
    # Calcula el valor entero del parámetro de la muestra
    addi $t0 $t0 -48
    # Almacena el valor del número de parámetros
    sw $t0 parametros

    # Obtiene el número de clusters deseados
    addi $a1 $a1 2
    lb $t0 0($a1)
    # Calcula el valor entero del cluster
    addi $t0 $t0 -48
    # Almacena el valor del número de clusters deseados
    sw $t0 clusters

    lw $s0 clusters # Cantidad de clusters deseados
    lw $s1 componentes # Cantidad inicial de componentes

    la $s4 nombres
    li $t0 0
    
cicloNombres:
    addi $t1 $t1 48
    sb $t1 0($t2)
    addi $s4 $s4 1
    bneq $t0 $s0 cicloNombres
     
matrizEspacio:
    la $t7 espacio # Dirección de la matriz que contiene la información de los documentos

    la $t0 componentes
    lw $t1 0($t0)
    la $t0 parametros
    lw $t2 0($t0)
    mul $t8 $t1 $t2
    li $a2 0

# Ciclo que llena la matriz de Documentos con sus tamaños y números de acceso
tamDoc:
    beq $t8 $a2 fin
    lw $t1 0($t7)
    beqz $t1 flagDoc
    addi $t7 $t7 4

flagDoc:
    addi $a1 $a1 1
    lb $t0 0($a1)

sig1:
    beq $t0 32 accesos # Si leo un espacio, lleno el acceso en la siguiente posición de la matriz
    beq $t0 10 tamDoc # Si leo un fin de línea, lleno el tamaño del siguiente documento en la siguiente posición de la matriz
    beq $t0 13 tamDoc # Si leo un fin de línea, lleno el tamaño del siguiente documento en la siguiente posición de la matriz

    addi $t0 $t0 -48
    
    lw $t1 0($t7)
    mul $t1 $t1 10
    add $t1 $t1 $t0
    sw $t1 0($t7)

    addi $a1 $a1 1
    lb $t0 0($a1)

    b sig1

accesos:
    addi $a2 $a2 2
    lw $t1 0($t7)
    beqz $t1 flagAcc
    addi $t7 $t7 4

flagAcc:
    addi $a1 $a1 1
    lb $t0 0($a1)

sig2:
    beq $t0 10 tamDoc # Si leo un fin de línea, lleno el tamaño del siguiente documento en la siguiente posición de la matriz
    beq $t0 13 tamDoc # Si leo un fin de línea, lleno el tamaño del siguiente documento en la siguiente posición de la matriz
    addi $t0 $t0 -48

    lw $t1 0($t7)
    mul $t1 $t1 10
    add $t1 $t1 $t0
    sw $t1 0($t7)

    addi $a1 $a1 1
    lb $t0 0($a1)

    b sig2

fin:
    # Se cierra el archivo
    li $v0 16
    move $a0 $s0
    syscall

    la $t0 espacio    

# Comienza el Clustering    
    beq $s0 $s1 Final # Cuando la cantidad de clusters y de componentes es igual, terminé

    li $t6 0 # El registro t6 es mi i en la matriz. Inicializo i en 0
    la $t9 distancias # Obtiene la dirección de la matriz de distancias
    addi $t9 $t9 -4

    la $t0 espacio # Voy con t0 a la primera posición de la matriz de documentos
    addi $t0 $t0 -8
    la $t1 espacio # Voy con t1 a la primera posición de la matriz de documentos

nuevaLinea:
    addi $t0 $t0 8
    addi $t6 $t6 1
    beq $t6 $s1 finMatriz # Si i es igual a número de componentes, llegué al final de la matriz

    li $t7 0

ceros:
    addi $t9 $t9 4 # Me voy al siguiente elemento de la matriz de distancias
    sw $zero 0($t9)
    addi $t7 $t7 1

    bne $t6 $t7 ceros

    lw $t2 0($t0) # Tamaño del elemento en t2
    lw $t3 4($t0) # Accesos del elemento en t2
    move $t1 $t0
    addi $t1 $t1 8

distancia:
    addi $t9 $t9 4 # Me voy al siguiente elemento de la matriz de distancias
    lw $t4 0($t1) # Tamaño del elemento en t4
    lw $t5 4($t1) # Accesos del elemento en t5

# Cálculo de la distancia Manhatan
    sub $t4 $t4 $t2
    abs $t4 $t4
    sub $t5 $t5 $t3
    abs $t5 $t5
    add $t4 $t4 $t5
    sw $t4 0($t9) # Almaceno la distancia entre los elementos en t0 y en t1 en la posición (t0,t1) de la matriz direcciones

    addi $t7 $t7 1 # j++
    beq $t7 $s1 nuevaLinea # Si j = componentes, terminé de calcular las distancias para $t0 y lleno una nueva línea de la matriz de distancias
    addi $t1 $t1 8
    b distancia # Sigo calculando la distancia con t0 fijo y el siguiente t1

# Código cuando termino de llenar la matriz
finMatriz:

    la $t0 distancias
    lw $t1 4($t0) # Tomo como primer elemento el primer elemento de la matriz de distancias
    li $s6 0 # Fila en la que se encuentra el elemento que estoy comparando
    li $s7 0 # Columna en la que se encuentra el elemento que estoy comparando

minimaDistancia:
    addi $s7 $s7 1 # Me muevo a la siguiente columna
    bne $t9 $s1 sigue # Mientras no llegue al último elemento de la fila, sigo
    addi $s6 $s6 1 # Cuando llego al último elemento de la fila, incremento el contador de fila

    beq $s6 $s1 Centroide # Cuando llegue a la última fila, terminé de buscar la mínima distancia
    li $s7 0 # Cuando llego al último elemento de la fila, reinicio el contador de columna

sigue:
    addi $t0 $t0 4 # Me muevo al siguiente elemento de la matriz

    lw $t2 0($t0) # Guardo en t2 el elemento con el que compararé

    bge $t2 $t1 minimaDistancia # Si el elemento en t2 es mayor que el elemento en t1, sigo comparando con el siguiente elemento de la matriz
    beqz $t2 minimaDistancia # Si el elemento en t2 es 0, la posición de la matriz está vacía y me muevo a la siguiente

    move $t1 $t2

    b minimaDistancia

Centroide:

#########################    

    li $v0 1
    move $a0 $s6
    syscall

    li $v0 4
    la $a0 blanco
    syscall

    li $v0 1
    move $a0 $s7
    syscall

    li $v0 4
    la $a0 blanco
    syscall

########################

    addi $t8 $s6 -1 # Como indica el número del archivo, le resto uno para que indique la fila que corresponde en la matriz de archivo
    mul $t8 $t8 8 # Me voy a la posición cero de la fila que me interesa
    addi $t9 $s7 -1 # Como indica el número del archivo, le resto uno para que indique la fila que corresponde en la matriz de archivo
    mul $t9 $t9 8 # Me voy a la posición cero de la fila que me interesa

    la $t0 espacio
    add $t1 $t0 $t8 # Posición cero de la primera fila a unir
    add $t2 $t0 $t9 # Posición cero de la segunda fila a unir

# Calculo el promedio de los tamaños
    lw $t3 0($t1)
    lw $t4 0($t2)
    add $t3 $t3 $t4
    div $t3 $t3 2

# Calculo el promedio de los accesos
    lw $t4 4($t1)
    lw $t5 4($t2)
    add $t4 $t4 $t5
    div $t4 $t4 2

# Reagrupa los archivos
    blt $s7 $s6 menor2
    la $t0 nombres
    lw $t1 $s6
    addi $t0 $t0 $t1
    
menor2:
    



Final:
    # Finaliza el programa
    li $v0 10
    syscall
