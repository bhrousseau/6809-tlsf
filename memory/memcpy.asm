;-----------------------------------------------------------------
; memcpy.uyd
; input  REG : [U] source
; input  REG : [Y] destination
; input  REG : [D] nb of bytes to copy
;-----------------------------------------------------------------
; copy bytes from a memory location to another one
;----------------------------------------------------------------- 

memcpy.uyd
        pshs  d,x,y,u

        ; compute end of src data cmp
        leax d,u
        stx  @cmpu+2
;
        ; is nb of bytes to copy an odd value ?
        lsrb
        bcc  >
        pulu a
        sta  ,y+
!
        ; is nb of bytes to copy a multiple of 2 ?
        lsrb
        bcc  >
        pulu x
        stx  ,y++
!
        ; is nb of bytes to copy a multiple of 4 ?
        lsrb
        bcc  @cmpu
        pulu d,x
        std  ,y++
        stx  ,y++
        bra  @cmpu
;
        ; process bytes by multiple of 8
!       pulu d,x
        std  ,y  
        stx  2,y 
        pulu d,x 
        std  4,y
        stx  6,y
        leay 8,y
@cmpu
        cmpu #0  ; end ?
        bne  <   ; not yet ...
@rts 
        puls d,x,y,u,pc
