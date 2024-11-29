;------------------------------------------------------------------------------
; Titel:                GleEst für Z1013 KRT
;
; Erstellt:             20.11.2024
; Letzte Änderung:      29.11.2024
;------------------------------------------------------------------------------ 

        cpu     z80

hi      function x,(x>>8)&255
lo      function x, x&255

        ifndef  BASE
                BASE:   set     0100H   
        endif   
                org     BASE
        
        call    gein    ; Grafik einschalten
        call    cls     ; Bildschirm löschen
        
;------------------------------------------------------------------------------
        
        ; Start GleEst
        
        ld      sp, stack
        ld      hl, buffer1
        
        exx

        loop_ix:

                ld      hl,buffer2
                loop:   
                        ;ld     bc,10FFh        ; nur wenige Punkte (für Test)
                        ld      bc,3F06h        ; BH = Abstand Punkte, BL = Anzahl Punkte 
                        
                        d_loop:
                                ;
                                ; Pixel löschen
                                ;
                                
                                ld      e,(hl)          ;BWS lo holen
                                inc     hl
                                
                                ld      d,(hl)          ;BWS hi holen
                                inc     hl
                                
                                ld      a,(hl)          ;BWS-Block holen
                                out     (deco),a        ;BWS_Block setzen
                                inc     hl
                                                        
                                ld      a,(de)          ;BWS-Byte holen (t)     
                                or      (hl)            ;mit BWS-Byte (t-1) kombinieren (Bits löschen)                                               
                                ld      (de),a          ;BWS schreiben 
                                
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
                                cp      0c0h
                                
                                ld      b,a
                                
                                ;
                                ; Pixel schreiben
                                ;
                                
                                ; yx2ad
                                ; in:  BC = Y,X 
                                ; out: HL = VRAM, (ldeco)= BWS-Block, A = Bitpos (3-Bit binär)
                                
                                call    c,yx2ad  

                                ld      b,hi(sprite-1)          
                                cpl
                                ld      c,a             
                                ld      a,(bc)          ; BWS-Byte holen
                                and     (hl)            ; Hintergrund und Pixel 
                                ld      (hl),a          ; BWS-Byte neu schreiben
                                cpl
                                
                                push    hl
                                
                                exx
                                
                                pop     de              
                   
                                ld      (hl),a          ; BWS-Byte merken
                                dec     hl
                                        
                                ld      a,(ldeco)       ; BWS-Block holen
                                ld      (hl),a          ; BWS-Block merken
                                dec     hl
                                
                                ld      (hl),d          ; BWS hi merken
                                dec     hl
                                
                                ld      (hl),e          ; BWS lo merken
                                inc     hl                      
                                inc     hl
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
                                ld      b,10h
                                
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
                        
                        ld      a,hi(buffer2_end)
                        cp      a,h
                        
                jp      nz,loop
                
        jp      loop_ix
        
;------------------------------------------------------------------------------

        org     BASE+0F8h

        db      11111110b
        db      11111101b
        db      11111011b
        db      11110111b
        db      11101111b
        db      11011111b
        db      10111111b
        db      01111111b
sprite:

        
;------------------------------------------------------------------------------
; Z1013 KRT Grafik-Routinen von Dietmar Uhlig aus:
;
; https://github.com/duhlig/Z1013_software
;
;------------------------------------------------------------------------------

;;; Grafik einschalten

geinp:  defb 08h        ; KRT: Port 8, FA: Port 0CH

gein:   push bc
        ld   a,(geinp)
        ld   c,a
        ld   a,08h
        out  (c),a
        pop  bc
        ret

;;; Grafik ausschalten

gausp:  defb 08h        ; KRT: Port 8, FA: Port 10H

gaus:   push bc
        ld   a,(gausp)
        ld   c,a
        ld   a,09h
        out  (c),a
        pop  bc
        ret

;;; Bildschirm löschen

deco    equ  08h

cls:    push    hl
        push    de
        push    bc
        
        xor     a               ; Block 0
cls1:   out     (deco), a       ; Block aktivieren
        ld      hl, 0EC00h      ; BWS Anfang
        ld      (hl), 0FFh      ; erste 8 Pixel auf Hintergrund"farbe"
        ld      d, h
        ld      e, l
        inc     de              ; Beginn des überlappenden Bereichs
        ld      bc, 003FFh      ; Länge_BWS - 1
        ldir                    ; Hintergrund über BWS schmieren
        inc     a
        cp      008h            ; Anzahl Blöcke
        jr      nz, cls1
        
        pop     bc
        pop     de
        pop     hl
        
        ret

;;; Angepasst und erweitert für GleEst (HST, 28.11.24)  
;;;
;;; Koordinaten (BC) in BWS-Adresse (HL) umrechnen,
;;; Speicherseite schalten und merken in -> (ldeco) last deco,
;;; Pixelspalte in Reg. a zurückgeben

ldeco:  db      0

yx2ad:  ld   a,b        ; y-Koord.
        and  a,0F8h     ; Bits 7-3 sind Teil der BWS-Adr.
        ld   l,a
        ld   h,000h
        add  hl,hl
        add  hl,hl      ; y[7..3] -> BWS[9..5]
        ld   a,c        ; x-Koord.
        and  a,0F8h     ; Bits 7-3 sind Teil der BWS-Adr.
        rrca
        rrca
        rrca
        or   l          ; l[4..0] ist 0
        ld   l,a        ; x[7..3] -> BWS[4..0]
        ld   a,h
        add  a,0ECh
        ld   h,a        ; --> hl += %EC00
        ld   a,b        ; a:=(pixze)
        and  a,007h     ; y[2..0] -> G-BWS-Block/-Seite
        out  (deco),a
        ld   (ldeco),a
        ld   a,c        ; a:=(pixsp)
        and  a,007h     ; x[2..0] ist Bitpos. im BWS-Byte       
        ret
        
end

;------------------------------------------------------------------------------

        ; RAM für GleEst
        
        align   100h
        
buffer1:        
        ds      100h
buffer2:        
        ds      900h
buffer2_end:    
        ds      20h
stack:  
        
        



