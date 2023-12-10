; ---------------------------------------------------------------------------
; Subroutine to generate a pseudo-random number in d
; By Samuel Devulder
; ---------------------------------------------------------------------------

random.init
        ldd   $E7C6
        std   random.seed
        rts

random.get
        ldd   #0
random.seed equ *-2
        lsra              
        rorb              
        eorb  random.seed
        stb   @a
        rorb              
        eorb  random.seed+1
        tfr   b,a         
        eora  #0          
@a      equ   *-1
        std   random.seed
        rts
