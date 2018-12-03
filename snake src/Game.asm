include "Hardware.asm"
include "Snake.asm"
include "Utils.asm"

SECTION "Setup", ROM0[$0100]

JP Start

SECTION "Main", ROM0[$0150]

Start:
    EI                          ; enable interrupts such as vblank
    LD SP, $FFFE                ; setup stack pointer to the top

    CALL TurnOffLcd             ; turn off the lcd

     LD A,%00000000         ; LCD Controller = Off (No picture on screen)
			                ; WindowBank = $9800 (Not used)
			                ; Window = OFF
			                ; BG Chr = $8000
			                ; BG Bank= $9800
			                ; Sprites= 8x8 (Size Assembly, 1=8x16)
			                ; Sprites= Off (Sprites on or off)
			                ; BG     = On
    ldh [$ff00+$40], a
    LD A, %11100100             ; define the pattern table from the darkest to the lightest
    LDH [rBGP], A
    LDH [rOCPD], A
    LDH [rOBP0], A
    LDH [rOBP1], A

    CALL ClearVram              ; call in utils, clear the graphic memory: all the sprites
    CALL ClearOam               ; call in utils, clear the sprite attribute table
    CALL ClearRam               ; call in utils, clear the ram
    
    CALL Load_Sprites_Into_VRAM ; call in game; put all the sprites inside the game into vram
    CALL Load_Map_Into_VRAM     ; call in game; put the map inside the game into vram

    CALL TurnOnLCD              ; turn back on the lcd 
    CALL AdjustWindowPosition   ; fix lcd being slightly moved
    CALL Init                   ; call in game; initialize the game
    
GameLoop:

    CALL Wait_vBlank            ; we wait for Vblank
    CALL Input                  ; set XAxis and YAxis
    CALL Update                 ; call in game, update the game

    JP GameLoop


Wait_vBlank:
    LD A, [rLY]         ;we load in the accomulator the current line of the lcd
    CP $90              ;we compare it with 144
    JP NZ, Wait_vBlank  ;untill we are not at lcd line 144 we wait in this loop
    RET

TurnOffLcd:
	CALL Wait_vBlank        ;call utils vBlank
	XOR a                   ;we set to zero the accomulator
	LD [rLCDC], A           ;we set everything to 0 turning off the lcd
	RET     

TurnOnLCD:
    LD HL,rLCDC     ; load the adress of the screen commands to hl
    LD [HL], $FF    ; load into the adress of the screen commands FF turning everything on
    RET

AdjustWindowPosition:
    LD A, [$FF4A]   ; $FF4A is the window Y position
    DEC A
    LD [$FF4A], A
    RET

Input
    LD A, $01
    LD [XAxis], A
    LD [YAxis], A
Input_Move_Left:
    LD A, [rP1]
    BIT 1, A
    JP NZ, Input_Check_Right
    LD HL, XAxis
    DEC [HL]
    RET
Input_Check_Right:
    BIT 0, A
    JP NZ, Input_Check_Up
    LD HL, XAxis
    INC [HL]
    RET
Input_Check_Up:
    BIT 2, A
    JP NZ, Input_Check_Down
    LD HL, YAxis
    DEC [HL]
    RET
Input_Check_Down:
    BIT 3, A
    JP NZ, End_Input
    LD HL, YAxis
    INC [HL]
    RET
End_Input:
    RET                

; -- THIS IS OUR PATTERN TABLE DEFINED ABOVE:
; -- DB $FF, $FF = darkest color            [ ◻ ◻ ◻ ◼ ]
; -- DB $00, $FF = middle dark color        [ ◻ ◻ ◼ ◻ ]
; -- DB $FF, $00 = middle clear color       [ ◻ ◼ ◻ ◻ ]
; -- DB $00, $00 = lightest color           [ ◼ ◻ ◻ ◻ ]
_Palettes_Table_NOCALL EQU $0000000000

SECTION "RAM", WRAM0[$C000]

XAxis: DS 1
YAxis: DS 1

MovemenentCounter: DS 1
SnakeDirection: DS 1
SnakeLength: DS 1
SnakeOldX: DS 1
SnakeOldY: DS 1
SnakeOldTailX: DS 1
SnakeOldTailY: DS 1
RandomPtr: DS 1

SECTION "OAM", WRAM0[$C100]