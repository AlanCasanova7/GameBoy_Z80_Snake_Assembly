SECTION "Snake", ROM0

Load_Sprites_Into_VRAM:
    LD HL, _VRAM        ; vram is where we write our tiles

    LD BC, Clear_Tile    ; load our tile data into bc
    LD E, $10           ; load 16 into E, e will be our counter inside "SetTile"
    call SetTile        ; call in Utils loop used to set all the bits into the hr

	LD BC, Test_Tile    ; load our tile data into bc
    LD E, $10           ; load 16 into E, e will be our counter inside "SetTile"
    call SetTile        ; call in Utils loop used to set all the bits into the hr

	LD BC, Snake_Tile    ; load our tile data into bc
    LD E, $10           ; load 16 into E, e will be our counter inside "SetTile"
    call SetTile        ; call in Utils loop used to set all the bits into the hr

	; LD BC, Body_Tile    ; load our tile data into bc
    ; LD E, $10           ; load 16 into E, e will be our counter inside "SetTile"
    ; call SetTile        ; call in Utils loop used to set all the bits into the hr

Load_Map_Into_VRAM:
    LD BC, Map          ; same as sprite 
    LD DE, $400         ; load 1024 because map is bigger than sprite stupid.
    LD HL, _SCRN1       ; load into hl $9C00, this is the adress where the map starts
    call SetMap         ; call in utils the load map loop

Init:
    LD HL, SnakeDirection
    LD A, $00
    LD [HL], A
    LD HL, RandomPtr
    LD [HL], A

    LD HL, SnakeLength
    LD A, $05
    LD [HL], A

    LD A, $50
    ; first sprite
	LD [$FE00], A       ; posY
	LD [$FE00+$01], A   ; posX
    LD A, $03
	LD [$FE00+$02], A   ; number of the tile the sprite will have
	LD [$FE00+$03], A   ; flags of the sprite
    
    LD A, $58
    LD [$FE04], A       ; posY
    LD A, $50
	LD [$FE04+$01], A   ; posX
    LD A, $03
	LD [$FE04+$02], A   ; number of the tile the sprite will have
	LD [$FE04+$03], A   ; flags of the sprite

    LD A, $60
    LD [$FE08], A       ; posY
    LD A, $50
	LD [$FE08+$01], A   ; posX
    LD A, $03
	LD [$FE08+$02], A   ; number of the tile the sprite will have
	LD [$FE08+$03], A   ; flags of the sprite
        
    LD A, $68
    LD [$FE0C], A       ; posY
    LD A, $50
	LD [$FE0C+$01], A   ; posX
    LD A, $03
	LD [$FE0C+$02], A   ; number of the tile the sprite will have
	LD [$FE0C+$03], A   ; flags of the sprite

    LD A, $70
    LD [$FE10], A       ; posY
    LD A, $50
	LD [$FE10+$01], A   ; posX
    LD A, $03
	LD [$FE10+$02], A   ; number of the tile the sprite will have
	LD [$FE10+$03], A   ; flags of the sprite

    LD A, $78
    LD [$FE14], A       ; posY
    LD A, $50
	LD [$FE14+$01], A   ; posX
    LD A, $03
	LD [$FE14+$02], A   ; number of the tile the sprite will have
	LD [$FE14+$03], A   ; flags of the sprite
    RET

Update:
    CALL Set_Direction
    LD HL, MovemenentCounter
    INC [HL]
    LD A, [HL]
    CP $0F
    JP NZ, End_Update
    CALL Move
    LD HL, MovemenentCounter
    LD A, $00
    LD [HL], A
End_Update:
    RET

Set_Direction:          ;00 right, 01 left, 02 down, 03 up
    LD HL, YAxis
    LD A, [HL]
Set_Direction_Up:
    CP $00
    JP NZ, Set_Direction_Down
    LD HL, SnakeDirection
    LD A, $03
    LD [HL], A
Set_Direction_Down:
    CP $02
    JP NZ, Set_Direction_Left
    LD HL, SnakeDirection
    LD A, $02
    LD [HL], A
Set_Direction_Left:
    LD HL, XAxis
    LD A, [HL]
    CP $00
    JP NZ, Set_Direction_Right
    LD HL, SnakeDirection
    LD A, $01
    LD [HL], A
Set_Direction_Right:
    CP $02
    JP NZ, End_Set_Direction
    LD HL, SnakeDirection
    LD A, $00
    LD [HL], A
End_Set_Direction:
    RET

Move:          ;00 right, 01 left, 02 down, 03 up
    LD HL, $FE00+$01
    LD A, [HL]
    LD HL, SnakeOldX
    LD [HL], A

    LD HL, $FE00
    LD A, [HL]
    LD HL, SnakeOldY
    LD [HL], A

    LD HL, SnakeDirection
    LD A, [HL]
    CP $00
    JP NZ, Move_Left
    LD HL, _OAMRAM+$01
    LD A, [HL]
    SCF
    CCF
    ADC A, $08
    LD [HL], A
    JP end_Move
Move_Left:
    LD HL, SnakeDirection
    LD A, [HL]
    CP $01
    JP NZ, Move_Down
    LD HL, _OAMRAM+$01
    LD A, [HL]
    SCF
    CCF
    SBC A, $08
    LD [HL], A
    JP end_Move
Move_Down:
    LD HL, SnakeDirection
    LD A, [HL]
    CP $02
    JP NZ, Move_Up
    LD HL, _OAMRAM
    LD A, [HL]
    SCF
    CCF
    ADC A, $08
    LD [HL], A
    JP end_Move
Move_Up:
    LD HL, SnakeDirection
    LD A, [HL]
    CP $03
    JP NZ, end_Move
    LD HL, _OAMRAM
    LD A, [HL]
    SCF
    CCF
    SBC A, $08
    LD [HL], A
end_Move:
    call Check_Tile
    call Move_Body_Snake
    RET
Move_Body_Snake:
    LD B, $FE
    LD A, [SnakeLength]
    SLA A
    SLA A
    LD C, A
    LD D, A

    LD A, [BC]
    LD [SnakeOldTailY], A
    INC BC
    LD A, [BC]
    LD [SnakeOldTailX], A

    LD A, D
    ;CALL TurnOffLcd
Move_Body_Snake_Loop:
    LD C, A
    SCF
    CCF
    SBC A, $04
    LD E, A
    LD D, B
    LD A, [DE]
    LD [BC], A
    LD A, E
    SCF
    CCF
    ADC A, $05
    LD C, A
    SCF
    CCF
    SBC A, $04
    LD E, A
    LD A, [DE]
    LD [BC], A
    LD A, E
    DEC A
    CP A, $04
    JP NZ, Move_Body_Snake_Loop
    LD HL, $FE04+$01
    LD A,  [SnakeOldX]
    LD [HL], A
    LD HL, $FE04
    LD A,  [SnakeOldY]
    LD [HL], A
    RET

Check_Tile:
    LD BC, $FE00
    LD A, [BC]
    
    SCF
    CCF
    SBC A, $0C

    SRL A
    SRL A
    SRL A

    LD H, $00
    LD L, A     ; H HAS OUR Y POSITION
    
    SLA L
    SLA L
    SLA L
    SLA L
    JP NC, Continue1
    INC H
    INC H
Continue1:
    SLA L
    JP NC, Continue2
    INC H
Continue2:
    ; NOW I SHOULD HAVE MY Y * 32 STORED IN HL, I NEED TO GET MY X AND ADD IT TO IT

    LD BC, $FE00+$01
    LD A, [BC]

    SCF
    CCF
    SBC A, $04

    SRL A
    SRL A
    SRL A
    LD B, $00
    LD C, A

    SCF
    CCF
    ADD HL, BC
    
    LD BC, _SCRN1
    ADD HL, BC
    ; THIS SHOULD GIVE ME THE TILE I'M CURRENTLY SITTING INTO BETWEEN 0 AND 1023

    LD A, [HL]
    CP A, $01
    JP NZ, CheckFruit
    CALL TurnOffLcd ;add piece
CheckFruit:
    CP A, $02
    JP NZ, End_Check_Tile
    CALL AddSegment
End_Check_Tile:
    RET
AddSegment
    LD [HL], $00
    ; LD BC, $03
    ; ADD HL, BC
    ; LD [HL], $02
RandomNumber:
        PUSH HL
        ;INCREASE INDEX
        LD A, [RandomPtr]
        INC A
        LD [RandomPtr], A
        ;END INCREASE INDEX
        LD HL, RandTable
        ADD A, L
        LD L, A
        JR NC, skip
        INC H
skip:  
        LD A, [HL]
        POP HL

    LD HL, _SCRN1
    LD B, $00
    LD C, A
    ADD HL, BC
    LD [HL], $02

    LD HL, SnakeLength
    INC [HL]

    LD B, $FE
    LD A, [SnakeLength]
    SLA A
    SLA A
    LD C, A

    LD HL, SnakeOldTailY
    LD A, [HL]
    ; first sprite
	LD [BC], A       ; posY
    INC BC
	LD [BC], A   ; posX
    LD A, $03
    INC BC
	LD [BC], A   ; number of the tile the sprite will have
    INC BC
	LD [BC], A   ; flags of the sprite
    RET
Clear_Tile:
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Test_Tile:
DB $FF, $FF, $C1, $C1, $00, $A1, $00, $91, $89, $00, $85, $00, $83, $83, $FF, $FF

Snake_Tile:
DB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

Map:
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
DB 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

RandTable:
        db        $01, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $40
        ; db      $F8,$03,$0F,$53,$7D,$8F,$57,$FB,$48,$26,$F2,$4A,$3D,$E4,$1D,$D9
        ; db      $9D,$DC,$2F,$F5,$92,$5C,$CC,$00,$73,$15,$BF,$B1,$BB,$EB,$9E,$2E
        ; db      $32,$FC,$4B,$CD,$A7,$E6,$C2,$10,$11,$80,$52,$B2,$DA,$77,$4F,$EC
        ; db      $13,$54,$64,$ED,$94,$8C,$C6,$9A,$19,$9F,$75,$FA,$AA,$8D,$FE,$91
        ; db      $01,$23,$07,$C1,$40,$18,$51,$76,$3C,$BD,$2A,$88,$2D,$F1,$8A,$72
        ; db      $F6,$98,$35,$97,$68,$93,$B3,$0C,$82,$4E,$CB,$39,$D8,$5F,$C7,$D4
        ; db      $CE,$AE,$6D,$A3,$7C,$6A,$B8,$A6,$6F,$5E,$E5,$1B,$F4,$B5,$3A,$14
        ; db      $78,$FD,$D0,$7A,$47,$2C,$A8,$1E,$EA,$2B,$9C,$86,$83,$E1,$7B,$71
        ; db      $F0,$FF,$D1,$C3,$DB,$0E,$46,$1C,$C9,$16,$61,$55,$AD,$36,$81,$F3
        ; db      $DF,$43,$C5,$B4,$AF,$79,$7F,$AC,$F9,$37,$E7,$0A,$22,$D3,$A0,$5A
        ; db      $06,$17,$EF,$67,$60,$87,$20,$56,$45,$D7,$6E,$58,$A9,$B0,$62,$BA
        ; db      $E3,$0D,$25,$09,$DE,$44,$49,$69,$9B,$65,$B9,$E0,$41,$A4,$6C,$CF
        ; db      $A1,$31,$D6,$29,$A2,$3F,$E2,$96,$34,$EE,$DD,$C0,$CA,$63,$33,$5B
        ; db      $70,$27,$F7,$1F,$BE,$12,$B6,$50,$BC,$4D,$28,$C8,$84,$30,$A5,$4C
        ; db      $AB,$E9,$8E,$E8,$7E,$C4,$89,$8B,$0B,$24,$85,$3E,$38,$04,$D2,$90

