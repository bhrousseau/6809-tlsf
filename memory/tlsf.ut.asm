;-----------------------------------------------------------------
; Unit Test for TLSF (Two Level Segregated Fit)
;-----------------------------------------------------------------
; Benoit Rousseau - 02/09/2023
;-----------------------------------------------------------------



tlsf.ut
        jsr   tlsf.ut.init
        jsr   tlsf.ut.mappingSearch
        jsr   tlsf.ut.malloc
        jsr   tlsf.ut.realloc
        jsr   tlsf.ut.random
        rts

        INCLUDE   "new-engine\math\random.asm"

tlsf.ut.init
        ldd   #tlsf.err.return
        std   tlsf.err.callback        ; routine to call when tlsf raise an error

        ldd   #$0001                   ; only 1 byte is not enough for header info
        ldx   #$1111+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init
        lda   tlsf.err
        cmpa  #tlsf.err.init.MIN_SIZE
        beq   >
        bra   *
!       clr   tlsf.err

        ldd   #$0008                   ; with 4 bytes as headroom, make only 4 bytes available for a malloc
        ldx   #$1111+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init
        lda   tlsf.err
        beq   >
        bra   *
!       ldd   tlsf.fl.bitmap
        cmpd  #%0000000000001000       ; fl=3
        bne   *
        ldd   tlsf.sl.bitmaps+3*2
        cmpd  #%0000000000010000       ; sl=4
        bne   *
        ldd   tlsf.headMatrix+(16*3+4)*2
        cmpd  #$1111
        bne   *

        ldd   #$8004                   ; maximum allowed allocation for this tlsf implementation (with header)
        ldx   #$2222+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init
        lda   tlsf.err
        beq   >
        bra   *
!       ldd   tlsf.fl.bitmap
        cmpd  #%1000000000000000       ; fl=15
        bne   *
        ldd   tlsf.sl.bitmaps+15*2
        cmpd  #%0000000000000001       ; sl=0
        bne   *
        ldd   tlsf.headMatrix+(16*15)*2
        cmpd  #$2222
        bne   *

        ldd   #$8005                   ; over the maximum allowed allocation for this tlsf implementation (with header)
        ldx   #$1111+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init
        lda   tlsf.err
        cmpa  #tlsf.err.init.MAX_SIZE
        beq   >
        bra   *
!       clr   tlsf.err
        rts

tlsf.ut.mappingSearch
        ; test all values in table
        ldx   #tlsf.ut.mappingSearch.in
        ldy   #tlsf.ut.mappingSearch.out
!       ldd   ,x++
        pshs  x,y
        jsr   tlsf.mappingSearch
        puls  x,y
        lda   tlsf.fl
        ldb   tlsf.sl
        cmpd  ,y++
        bne   *
        cmpx  #tlsf.ut.mappingSearch.in.end
        bne   <
        rts

tlsf.ut.mappingSearch.in
        fdb   %0000000000000001 ;      1
        fdb   %0000000000000010 ;      2
        fdb   %0000000000000011 ;    ...
        fdb   %0000000000000100
        fdb   %0000000000000101
        fdb   %0000000000000110
        fdb   %0000000000000111
        fdb   %0000000000001000
        fdb   %0000000000001001
        fdb   %0000000000001010
        fdb   %0000000000001011
        fdb   %0000000000001100
        fdb   %0000000000001101
        fdb   %0000000000001110
        fdb   %0000000000001111
        fdb   %0000000000010000
        fdb   %0000000000010001
        fdb   %0000000000010010
        fdb   %0000000000010011
        fdb   %0000000000010100
        fdb   %0000000000010101
        fdb   %0000000000010110
        fdb   %0000000000010111
        fdb   %0000000000011000
        fdb   %0000000000011001
        fdb   %0000000000011010
        fdb   %0000000000011011
        fdb   %0000000000011100
        fdb   %0000000000011101
        fdb   %0000000000011110 ;    ...
        fdb   %0000000000011111 ;     31

        fdb   %0000000000010000 ;     16
        fdb   %0000000000100010 ;     34
        fdb   %0000000001001000 ;     72
        fdb   %0000000010011000 ;    152
        fdb   %0000000101000000 ;    320
        fdb   %0000001010100000 ;    672
        fdb   %0000010110000000 ;  1 408
        fdb   %0000101110000000 ;  2 944
        fdb   %0001100000000000 ;  6 144
        fdb   %0011001000000000 ; 12 800
        fdb   %0110100000000000 ; 26 624
        fdb   %0110110000000000 ; 27 648
        fdb   %0111000000000000 ; 28 672
        fdb   %0111010000000000 ; 29 696
        fdb   %0111100000000000 ; 30 720
        fdb   %0111110000000000 ; 31 744

        fdb   %0000000000010001 ;     17
        fdb   %0000000000100011 ;     35
        fdb   %0000000001001001 ;     73
        fdb   %0000000010011001 ;    153
        fdb   %0000000101000001 ;    321
        fdb   %0000001010100001 ;    673
        fdb   %0000010110000001 ;  1 409
        fdb   %0000101110000001 ;  2 945
        fdb   %0001100000000001 ;  6 145
        fdb   %0011001000000001 ; 12 801
        fdb   %0110100000000001 ; 26 625
        fdb   %0110110000000001 ; 27 649
        fdb   %0111000000000001 ; 28 673
        fdb   %0111010000000001 ; 29 697
        fdb   %0111100000000001 ; 30 721
        fdb   %0111110000000001 ; 31 745
tlsf.ut.mappingSearch.in.end

tlsf.ut.mappingSearch.out
        fcb   3,1
        fcb   3,2
        fcb   3,3
        fcb   3,4
        fcb   3,5
        fcb   3,6
        fcb   3,7
        fcb   3,8
        fcb   3,9
        fcb   3,10
        fcb   3,11
        fcb   3,12
        fcb   3,13
        fcb   3,14
        fcb   3,15
        fcb   4,0
        fcb   4,1
        fcb   4,2
        fcb   4,3
        fcb   4,4
        fcb   4,5
        fcb   4,6
        fcb   4,7
        fcb   4,8
        fcb   4,9
        fcb   4,10
        fcb   4,11
        fcb   4,12
        fcb   4,13
        fcb   4,14
        fcb   4,15

        fcb   4,0
        fcb   5,1
        fcb   6,2
        fcb   7,3
        fcb   8,4
        fcb   9,5
        fcb   10,6
        fcb   11,7
        fcb   12,8
        fcb   13,9
        fcb   14,10
        fcb   14,11
        fcb   14,12
        fcb   14,13
        fcb   14,14
        fcb   14,15

        fcb   4,1
        fcb   5,2
        fcb   6,3
        fcb   7,4
        fcb   8,5
        fcb   9,6
        fcb   10,7
        fcb   11,8
        fcb   12,9
        fcb   13,10
        fcb   14,11
        fcb   14,12
        fcb   14,13
        fcb   14,14
        fcb   14,15
        fcb   15,0

tlsf.ut.malloc
        ; test unvalid sizes
        ldy   #$F801
!       clr   tlsf.err
        tfr   y,d
        pshs  y
        jsr   tlsf.malloc
        puls  y
        leay  1,y
        beq   @rts
        lda   tlsf.err
        cmpa  #tlsf.err.malloc.MAX_SIZE
        beq   <
        bra   *
@rts    rts

tlsf.ut.realloc
        ldd   #$1100
        std   tlsf.ut.realloc.var
        jsr   tlsf.ut.realloc.doOneTest
        ldd   #$1105
        std   tlsf.ut.realloc.var
        jsr   tlsf.ut.realloc.doOneTest
        ldd   #$1106
        std   tlsf.ut.realloc.var
        jmp   tlsf.ut.realloc.doOneTest

tlsf.ut.realloc.doOneTest
        ; init allocator
        ldd   #$4000
        ldx   #$0000+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init

        clr   tlsf.err
        ldd   #$101
        jsr   tlsf.malloc              ; allocate a temp block
        stu   @u0
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldd   #$3DFF                   ; maximum allowed size here, due to indexation of free block (see steps in chart)
        jsr   tlsf.malloc
        stu   @u1
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ; [u] contain address of allocated memory
        ldd   #$2000
        clr   tlsf.err
        jsr   tlsf.realloc             ; test case : shrink to a specific size (tlsf.realloc.shrink)
        cmpu  @u1
        beq   >
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldd   #1
        jsr   tlsf.realloc             ; test case : shrink min size 1 rounded to 4 (tlsf.realloc.shrink)
        cmpu  @u1
        beq   >
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldd   #0
        jsr   tlsf.realloc             ; test case : shrink min size 0 rounded to 4 (tlsf.realloc.shrink), size is identical, return
        cmpu  @u1
        beq   >
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldd   #$1000
        jsr   tlsf.realloc             ; test case : growth (tlsf.realloc.growth)
        cmpu  @u1
        beq   >
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldd   #$2DFF                   ; allocate near full memory
        jsr   tlsf.malloc
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        ldu   @u0
        jsr   tlsf.free                ; free temp block
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!                                      ; should test three branches of test case: tlsf.realloc.do
        ldu   @u1                      ; $1100 (malloc ok, memcpy)
        ldd   tlsf.ut.realloc.var      ; $1105 (malloc ko, but recycle of free block ok, memcpy)
        jsr   tlsf.realloc             ; $1106 (malloc ko, recycle of free block ko, memcpy)
        ldd   tlsf.ut.realloc.var
        cmpd  #$1106
        beq   @errorCase               ; an error is expected for the third case
        lda   tlsf.err
        beq   >
        bra   * ; error trap
!
        rts
@errorCase
        lda   tlsf.err
        bne   >
        bra   * ; error trap
!
        ldu   #$0004
        ldd   #$1107
        jsr   tlsf.realloc             ; (malloc ko, recycle of free block ko, no memcpy)
        lda   tlsf.err
        bne   >
        bra   * ; error trap
!
        rts
;
tlsf.ut.realloc.var fdb 0
@u0     fdb   0
@u1     fdb   0

tlsf.ut.random
        ; init allocator
        ldd   #$4000
        ldx   #$0000+tlsf.ut.MEMORY_POOL
        jsr   tlsf.init

        ldd   #tlsf.ut.random.free
        std   tlsf.err.callback        ; routine to call when tlsf raise an error

        jsr   random.init

tlsf.ut.random.malloc
!       jsr   random.get
        clra
        andb  #%11111110
        ldx   #allocRefs
        ldu   d,x
        bne   tlsf.ut.random.free.switch
tlsf.ut.random.malloc.switch
        std   @d
        jsr   random.get
        anda  #%00000011
        andb  #%11111111
        addd  #1
        jsr   tlsf.malloc
 IFEQ tlsf.ut.MEMORY_POOL-$C000
        cmpu  #tlsf.ut.MEMORY_POOL     ; special case, when $4000 memory pool is at the end of RAM
        blo   @exit
 ELSE
        cmpu  #$4000+tlsf.ut.MEMORY_POOL
        bhs   @exit
 ENDC
        ldx   #allocRefs
        stu   1234,x
@d      equ   *-2
        bra   <
@exit   bra   *                        ; error, allocated block is out of range

tlsf.ut.random.free
        lda   tlsf.err
        cmpa  #tlsf.err.malloc.OUT_OF_MEMORY
        beq   >
        bra   *
!       clr   tlsf.err
        jsr   random.get
        clra
        andb  #%11111110
        ldx   #allocRefs
        ldu   d,x
        beq   tlsf.ut.random.malloc.switch
tlsf.ut.random.free.switch
        ldy   #0
        sty   d,x
        jsr   tlsf.free
        bra   <
        rts

allocRefs
        fill  0,256