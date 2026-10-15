;*********************************************************
; ASCII-Lines für Z1013 ala MS Screensaver
; Quelle: FADEN.MAC Mario Leubner (KC 85/4)
; Anpassung an Hübler-Grafik-PC V. Pohlers 07.05.2012
; Anpassung an Z1013 H. Strugalla 15.10.2026
;*********************************************************
; 'Grafik' wird aus ASCII-Zeichen '*' generiert. 
; LINE mit 8-connected Bresenham f. schmale Linien.
;
; Start: J 100
; Tasten: 
;       + -> mehr Linien
;       - -> weniger Linien
;       H -> hor. Spiegelung ein/aus
;       V -> vert. Spiegelung ein/aus
;       sonst:  Ende
;*********************************************************

        cpu     z80

        org     100h
                
TOP:    CALL    FADEN1          ; Programm ausfuehren
        RET
        
;
; Erzeugung einer Zufallszahl
; (im Bereich von 3 bis 15)
;
RND:    EXX
        LD      A,0     ; Zwischenablage
ZAHL    EQU     $-1
        INC     A
        LD      D,A
        ;
        ADD     A,A
        ADD     A,A
        ADD     A,A
        ADD     A,A
        SUB     D       ; Zahl*15
        ;
        ADD     A,A
        LD      L,A
        LD      A,R
        ADD     A,L
        LD      (ZAHL),A
        LD      B,13
RND1:   SUB     B
        CP      B
        JR      NC,RND1
        ADD     A,3
        EXX
        RET
;
; FADEN-Hauptschleife:
;
FADEN:  LD      HL,(ZYKLUS)
        INC     HL              ; Zykluszaehler
        BIT     1,H
        RES     1,H
        LD      (ZYKLUS),HL
        JR      Z,FADEN2

FADEN1: ;LD     C,0Ch           ; CLS, Bild loeschen
        CALL    cls
        LD      HL,MEM          ; Variablenspeicher
        LD      (ZEIGER),HL
        LD      DE,MEM+1
        LD      BC,127
        LD      (HL),0          ; Variablen loeschen
        LDIR
FADEN2: LD      HL,X1           ; Koordinaten und
        LD      DE,ZUF1         ; dazugehoerige Zufallszahlen
        LD      B,4             ; fuer 4 Werte
NEU:    LD      A,(HL)
        AND     A
        JR      NZ,NEU1
        CALL    RND             ; Koordinate=0
        LD      (DE),A          ; positive Zufallszahl
NEU1:   LD      A,(HL)
        INC     A
        JR      NZ,NEU2
        CALL    RND             ; Koordinate=ffh
        NEG
        LD      (DE),A          ; negative Zufallszahl
NEU2:   INC     HL
        INC     DE
        DJNZ    NEU
;
; Linie(n) zeichnen
;
        LD      HL,(X1)
        LD      D,L
        LD      B,H
        LD      HL,(Y1)
        LD      E,L
        LD      C,H
        CALL    LINES           ; 1. Linie
        LD      A,(MIRR)
        RRA                     ; H-Spiegel?
        JR      NC,NOSP1
        LD      A,(Y1)
        CPL
        LD      (Y3),A
        LD      A,(Y2)
        CPL
        LD      (Y4),A
        LD      HL,(X1)
        LD      D,L
        LD      B,H
        LD      HL,(Y3)
        LD      E,L
        LD      C,H
        CALL    LINE            ; 2. Linie
NOSP1:  LD      A,(MIRR)
        RLA                     ; V-Spiegel?
        JR      NC,NOSP2
        LD      A,(X1)
        CPL
        LD      (X3),A
        LD      A,(X2)
        CPL
        LD      (X4),A
        LD      HL,(X3)
        LD      D,L
        LD      B,H
        LD      HL,(Y1)
        LD      E,L
        LD      C,H
        CALL    LINE            ; 3. Linie
        LD      A,(MIRR)
        RRA                     ; H-Spiegel?
        JR      NC,NOSP2
        LD      HL,(X3)
        LD      D,L
        LD      B,H
        LD      HL,(Y3)
        LD      E,L
        LD      C,H
        CALL    LINE            ; 4. Linie
NOSP2:
        call    time
;
; Retten der aktuellen Koordinaten
;
        LD      DE,(ZEIGER)
        LD      HL,X1
        LD      BC,4
        LDIR
        LD      HL,(GRENZE)
        AND     A
        SBC     HL,DE
        JR      NZ,NEWZG
        LD      DE,MEM          ; Zeiger wieder von vorn
NEWZG:  LD      (ZEIGER),DE
;
; alte Linie(n) loeschen
;
        LD      HL,(ZEIGER)
        LD      D,(HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        LD      E,(HL)
        INC     HL
        LD      C,(HL)
        CALL    LINER           ; 1. Linie
        LD      A,(MIRR)
        RRA                     ; H-Spiegel?
        JR      NC,NOSP3
        LD      HL,(ZEIGER)
        LD      D,(HL)
        INC     HL
        LD      B,(HL)
        INC     HL
        LD      A,(HL)
        CPL
        LD      E,A
        INC     HL
        LD      A,(HL)
        CPL
        LD      C,A
        CALL    LINER           ; 2. Linie
NOSP3:  LD      A,(MIRR)
        RLA                     ; V-Spiegel?
        JR      NC,NOSP4
        LD      HL,(ZEIGER)
        LD      A,(HL)
        CPL
        LD      D,A
        INC     HL
        LD      A,(HL)
        CPL
        LD      B,A
        INC     HL
        LD      E,(HL)
        INC     HL
        LD      C,(HL)
        CALL    LINE            ; 3. Linie
        LD      A,(MIRR)
        RRA                     ; H-Spiegel
        JR      NC,NOSP4
        LD      HL,(ZEIGER)
        LD      A,(HL)
        CPL
        LD      D,A
        INC     HL
        LD      A,(HL)
        CPL
        LD      B,A
        INC     HL
        LD      A,(HL)
        CPL
        LD      E,A
        INC     HL
        LD      A,(HL)
        CPL
        LD      C,A
        CALL    LINE            ; 4. Linie
NOSP4:
        
;
; Koordinaten fuer naechste Linie
; aus den Zufallszahlen berechnen
;
        LD      HL,ZUF1         ; Richtung
        LD      DE,X1           ; Koordinaten
        LD      B,4             ; fuer 4 Werte
CALC:   LD      A,(DE)
        ADD     A,(HL)          ; neuer Wert
        BIT     7,(HL)
        JR      NZ,CALC2
        JR      NC,CALC3
        LD      A,-1            ; max. Wert (Umlenkpunkt)
        JR      CALC3
        ;
CALC2:  JR      C,CALC3
        XOR     A               ; min. Wert (Umlenkpunkt)
CALC3:  LD      (DE),A
        INC     HL
        INC     DE
        DJNZ    CALC
;
; Tastaturabfrage/Auswertung
;
        RST     20h             ; CSTS+CI
        db      4
        JP      Z,FADEN         ; keine Taste
        CP      '+'
        JR      Z,PLUS          ; (+) -> mehr Linien
        CP      '-'
        JR      Z,MINUS         ; (-) -> weniger Linien
        AND     5FH             ; upcase
        CP      'H'
        JR      Z,HSWI          ; (H) -> hor. Spiegelung ein/aus
        CP      'V'
        JR      Z,VSWI          ; (V) -> vert. Spiegelung ein/aus
        RET                     ; jede andere Taste bricht ab!
;
; zwei Linien mehr
;
PLUS:   LD      HL,MEM+128
        LD      DE,(GRENZE)
        AND     A
        SBC     HL,DE
        JP      Z,FADEN
        LD      HL,8
SET1:   ADD     HL,DE
        LD      (GRENZE),HL
        JP      FADEN1
;
; zwei Linien weniger
;
MINUS:  LD      HL,MEM+8
        LD      DE,(GRENZE)
        AND     A
        SBC     HL,DE
        JP      Z,FADEN
        LD      HL,-8
        JR      SET1
;
; hor. Spiegelung ein/aus
;
HSWI:   LD      A,(MIRR)
        XOR     1
        JR      SET2
;
; vert. Spiegelung ein/aus
;
VSWI:   LD      A,(MIRR)
        XOR     80H
SET2:   LD      (MIRR),A
        JP      FADEN1
        
;
; LINE-Routine 
;
; von:  D=Y1    E=X1
; nach: B=Y2    C=X2
;

LINE:           
        ld      h,b     ; y2
        ld      l,c     ; x2
        
        rept 3  ; y/8
        srl     h       ; y2
        srl     d       ; y1
        endm
        
        rept 3  ; x/8
        srl     l       ; x2
        srl     e       ; x1
        endm
        
        call    draw
        ret

LINES:  ld      hl, setchar
        ld      (hl),'*'
        jr      LINE

LINER:  ld      hl, setchar
        ld      (hl),' '
        jr      LINE    
        
        
; --- initialisierte Daten ---

ZYKLUS: DW      0               ; Zykluszaehler (Farbwechsel)
ZEIGER: DW      MEM             ; Zeiger
GRENZE: DW      MEM+16;50H      ; Grenze

X1:     DB      10              ; Koordinaten
X2:     DB      100
Y1:     DB      20
Y2:     DB      200
X3:     DB      256-10          ; Koordinaten negiert
X4:     DB      256-100
Y3:     DB      256-20
Y4:     DB      256-200

ZUF1:   DB      4               ; 4 Zufallszahlen
ZUF2:   DB      13
ZUF3:   DB      10
ZUF4:   DB      7

MIRR:   DB      0               ; hor./vert. Spiegel ein/aus

SIZE1   EQU     $-TOP           ; Groesse Programmsegment

; --- nicht zu initialisierende Daten ---

PTRX:   DS      12      ; Vergleichswerte Ringpufferzeiger

MEM:    DS      32*4    ; Koordinatenspeicher (32 Linien)

SIZE2   EQU     $-PTRX  ; Groesse Datensegment

; ------------------------------------------------------------
; Löscht Bildschirm
; ------------------------------------------------------------
cls:
        ld      hl, 0EC00h
        ld      (hl), ' '
        ld      de, 0EC01h
        ld      bc, 003ffh
        ldir
        ret
        
; ------------------------------------------------------------
; Setzt/löscht Punkt (32x32)
; BWS = 0EC00h
;       
; In:   H = Y,  L = X
; 
; Out:  ASCII-Punkt im BWS
; ------------------------------------------------------------  
setpoint:
        push    hl
        push    de

        ld      e,l
        ld      d,0
                        
        ld      l,d     ; Y*32
        rept    3
        srl     h
        rr      l
        endm
                        
        add     hl,de   ; Y*32 + X      
        
                        ; hl = 0000-03FF
        ld      a,h
        or      a,0ECh
        ld      h,a
        
                        ; hl = EC00-FFFF
        db      36h     ; op code ld (hl),...
setchar:
        db      '*'     

        pop     de
        pop     hl
        ret

; ------------------------------------------------------------
; 8-connected LINE (Bresenham)
; Gut für ASCII-Grafik, da hier möglichst schmale Linien 
; gezeichnet werden sollen. Jedes Pixel hat 8 Nachbarn, 
; die alle als Schrittrichtung erlaubt sind.
;
; Linie von DE -> nach HL
;
; In:   D = Start-Y, E = Start-X
;       H = Ziel-Y,  L = Ziel-X
;       
; Out:  ASCII-Linie im BWS
; ------------------------------------------------------------

draw:
        ex      de,hl          ; HL = Start (H=y0, L=x0)
                               ; DE = Ziel  (D=y1, E=x1)

; ----- 1. Delta X und Richtung bestimmen -----

        ld      a,e            ; Ziel-X
        sub     l              ; Ziel-X - Start-X
        ld      b,2Ch          ; Opcode: INC L
        jr      nc,x_pos

        neg                    ; Betrag |dx|
        ld      b,2Dh          ; Opcode: DEC L

x_pos:
        ld      (dx),a
        ld      a,b
        ld      (xstep_flat),a ; X-Schrittstellen patchen!
        ld      (xstep_steep),a

; ----- 2. Delta Y und Richtung bestimmen -----

        ld      a,d            ; Ziel-Y
        sub     h              ; Ziel-Y - Start-Y
        ld      b,24h          ; Opcode: INC H
        jr      nc,y_pos

        neg                    ; Betrag |dy|
        ld      b,25h          ; Opcode: DEC H

y_pos:
        ld      (dy),a
        ld      a,b
        ld      (ystep_steep),a; Y-Schrittstellen patchen!
        ld      (ystep_flat),a

; ----- 3. Hauptachse bestimmen: dx >= dy ? -----

        ld      a,(dy)
        ld      c,a
        ld      a,(dx)
        cp      c
        jr      c,steep_setup  ; wenn dx < dy -> steile Linie


; ============================================================
; Flache Linie: X ist Hauptachse (dx >= dy)
;   BC' = dx (Hauptdelta)
;   DE' = dy (Nebendelta)
;   HL' = Fehler = dx / 2
; ============================================================

flat_setup:
        exx
        ld      a,(dx)
        ld      c,a
        ld      b,0            ; BC' = dx

        ld      a,(dy)
        ld      e,a
        ld      d,0            ; DE' = dy

        ld      h,b
        ld      l,c
        srl     h
        rr      l              ; HL' = dx / 2
        exx
        
flat_loop:
        call    setpoint

skip_plot:      

        ld      a,l
        cp      e              ; Ziel-X erreicht?
        ret     z

xstep_flat:
        inc     l              ; DEC L

        exx
        or      a
        sbc     hl,de          ; Fehler -= dy
        jr      nc,flat_no_y

        add     hl,bc          ; Unterlauf: Fehler += dx
        exx
ystep_flat:
        inc     h              ; DEC H
        jr      flat_loop

flat_no_y:
        exx
        jr      flat_loop


; ============================================================
; Steile Linie: Y ist Hauptachse (dy > dx)
;   BC' = dy (Hauptdelta)
;   DE' = dx (Nebendelta)
;   HL' = Fehler = dy / 2
; ============================================================

steep_setup:
        exx
        ld      a,(dy)
        ld      c,a
        ld      b,0            ; BC' = dy

        ld      a,(dx)
        ld      e,a
        ld      d,0            ; DE' = dx

        ld      h,b
        ld      l,c
        srl     h
        rr      l              ; HL' = dy / 2
        exx

steep_loop:
        call    setpoint

        ld      a,h
        cp      d              ; Ziel-Y erreicht?
        ret     z

ystep_steep:
        inc     h              ; DEC H

        exx
        or      a
        sbc     hl,de          ; Fehler -= dx
        jr      nc,steep_no_x

        add     hl,bc          ; Unterlauf: Fehler += dy
        exx
xstep_steep:
        inc     l              ; DEC L
        jr      steep_loop

steep_no_x:
        exx
        jr      steep_loop

dx:     db      0
dy:     db      0

; ------------------------------------------------------------
; Verzögerung
; ------------------------------------------------------------

time:   push    af
        push    bc
        push    hl
        
        ld      hl,10
        
ti2:    ld      b,0
ti1:    djnz    ti1

        dec     hl
        ld      a,l
        cp      h
        jr      nz,ti2
        
        pop     hl
        pop     bc
        pop     af
        ret
        
        end