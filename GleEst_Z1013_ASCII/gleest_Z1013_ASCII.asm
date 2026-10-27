;------------------------------------------------------------------------------
; Titel:                GleEst für Z1013 ASCII
;
; Erstellt:             26.10.2026
; Letzte Änderung:      27.10.2026
;------------------------------------------------------------------------------ 

        cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255

        ifndef  BASE
                BASE:   set     0100H   
        endif   
                org     BASE
        
        call    cls             ; Bildschirm löschen
        call    initGleEst
        
;------------------------------------------------------------------------------
        
        ; Start GleEst

        ld      hl, 0001h       ; (stack) darf nicht 0 sein
        push    hl
        
        ld      hl, buffer1
        
        exx
        
        loop_ix:

                rst     20h             
                db      04h             ; INKEY
                cp      a, 0            ; 0 = nicht gedrückt
                jr      z, noKey        ; weiter
                
        x1:     call    cls
                jp      0F003h          ; BIOS -> WBOOT
                
        noKey:  ld      hl,buffer2
        
                loop:   
                        ld      bc,1304h        ; BH = 3F -> max. 64 Punkte / 256-Byte-Block
                                                ; BL = 04 -> HL auf Anfang von nächstem 
                                                ;            256-Byte-Block setzen
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl  
                                ld      d,(hl)          ;BWS hi holen
                                
                                ld      a, ' '          ; Reset "Pixel"
                                ld      (de),a                  
                                
                                exx                     
                                
                                proc:   ld      a,L
                                
                                        ld      e,(hl)   
                                        inc     l
                                        
                                        ld      d,(hl) 
                                        inc     l
                                        
                                        inc     l
                                        inc     l
                                        
                                        ld      c,(hl)  
                                        inc     l
                                        
                                        ld      b,(hl)
                                        ex      de,hl
                                        add     hl,bc
                                        ex      de,hl
                                        srl     d
                                        rr      e
                                        ld      L,a
                                        
                                        ld      (hl),e
                                        inc     l
                                        
                                        ld      (hl),d
                                        inc     l
                                        
                                        push    de
                                        and     2       
                                        
                                jr      z, proc

                                pop     bc
                                ex      (sp),hl
                                
                                exx
                                
                                ld      a,b
                                
                                exx
                                
                                cp      10h
                                jr      c,dontplot
                                
                                ld      bc,0fd40h
                                add     hl,bc
                                srl     h
                                jr      nz,dontplot
                                
                                rr      l
                                ld      c,L
                                ld      a,d
                                add     a,b
                                srl     a
                                jr      nz,dontplot
                                
                        plot:
                                ld      a,e
                                rra
                                ;cp      0C0h           ; Y max  
                                
                                ld      b,a
                                
                                ;
                                ; Pixel schreiben
                                ;
                                
                                ;-------------------------------
                                ; ZX Spectrum 
                                ;-------------------------------                                

                                ; THE 'PIXEL ADDRESS' SUBROUTINE
                                ; This subroutine is called by the POINT subroutine and by the PLOT command routine. 
                                ; Is is entered with the co-ordinates of a pixel in the BC register pair and returns 
                                ; with HL holding the address of the display file byte which contains that pixel 
                                ; and A pointing to the position of the pixel within the byte.
                
                                ;call   c,22b0h         -> Spectrum ROM
                                
                                ;-------------------------------
                                ; Z1013
                                ;-------------------------------                                
                                
                                ; yx2ad
                                ; in:  BC = Y,X 
                                ; out: HL = VRAM
                                
                                ;call    c,yx2ad        ; nur bei Abfrage von Y-max notwendig
                                call    yx2ad
                                ld      (hl),'.'        ; Set "Pixel"
                                
                                push    hl
                                
                                exx
                                
                                pop     de              
                                 
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
             
                                ld      a,b
                                
                                exx
        
                        dontplot:
                                pop     hl              
                                
                                exx
                                
                                inc     hl              

                        djnz    d_loop

                        add     hl,bc   
                        
                        exx                     
                        
                        random:
                                pop     de
                                ld      b,6;10h
                                
                                backw:  sla     e
                                        rl      d
                                        ld      a,d
                                        and     0c0h    
                                        jp      pe,forw
                                        inc     e
                                        
                        forw:   djnz    backw
                        
                                ld      a,d
                                push    de
                                rra
                                rr      b
                                and     07h
                                ld      (hl),b   
                                inc     l
                                ld      (hl),a  
                                inc     l
                        jr      nz,random
                        
                        exx                             
                        
                        ld      a,hi(buffer2_end)-2;1
                        cp      a,h
                        
                jp      nc,loop
                
        jp      loop_ix
        
;------------------------------------------------------------------------------



        
;------------------------------------------------------------------------------
; Z1013 "Grafik"-Routinen 
;------------------------------------------------------------------------------

;;; Bildschirm löschen

cls:
        ld      hl, 0EC00h
        ld      (hl), ' '
        ld      de, 0EC01h
        ld      bc, 003ffh
        ldir
        ret  

;;; Koordinaten (BC) in BWS-Adresse (HL) umrechnen,
;;; B = Y, C = X

yx2ad:  push    bc
        push    de
        rept 3  ; y/8   
        srl     b       ; y
        endm
        
        rept 3  ; x/8
        srl     c       ; x
        endm
        
        ld      e,c     ; DE = X
        ld      d,0
                        
        ld      l,d     ; Y*32
        ld      h,b
        rept    3
        srl     h
        rr      l
        endm
                        
        add     hl,de   ; Y*32 + X      
        
                        ; hl = 0000-03FF
        ld      a,h
        or      a,0ECh
        ld      h,a
        
        pop     de
        pop     bc
        ret
        
;------------------------------------------------------------------------------
; buffer2 wird mit Adresse von "dummy", 08h und 55h initialisiert, damit beim 
; Laufen von GleEst keine undefinierten Schreibvorgänge im RAM erfolgen können.
;------------------------------------------------------------------------------
        
initGleEst:

        ld      bc, (buffer2_end - buffer2)/2
        ld      hl, buffer2
        ld      de, dummy
        
fb1:    ld      (hl), e         ; Dummy-BWS hi
        inc     hl
        ld      (hl), d         ; Dummy-BWS lo
        inc     hl
        
        dec     bc
        ld      a, b
        or      c
        jr      nz, fb1 
        ret  
        
end

;------------------------------------------------------------------------------

        ; RAM für GleEst

dummy:  db      55h 
        
        align   100h
        
buffer1:        
        ds      100h        
buffer2:                ; 6 x 256 Bytes
        ds      0600h   ; 600h  
buffer2_end:    


        
        



