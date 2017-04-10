    processor 16F690
    org 0

    cblock 0x20
        COUNT1
        COUNT2
        COUNT3
        ANODE_COUNTER
    endc

; See "Section 27. Device Configuration Bits" of the "PICmicro™ Mid-Range MCU
; Family Reference Manual"
; (http://ww1.microchip.com/downloads/en/DeviceDoc/33023a.pdf).

; _INTRC_OSC_NOCLKOUT: we want to use the internal oscillator to drive the PIC,
; so that we don't need to connect a crystal, see "Section 2. Oscillator".

; _WDT_OFF: disable the watchdog timer, which if enabled would reset the PIC
; every 18ms, see "Section 26. Watchdog Timer and Sleep Mode".
;
; _PWRTE_ON: enable the power-up timer, which instructs the MPU to wait about
; 72ms to give time for Vdd to reach a stable voltage, see "9.3.3 POWER-UP TIMER
; (PWRT)".
;
; _MCLRE_OFF: if "Master Clear" is enabled, pin 4/GP3 is the reset pin, so
; you'd need to supply Vdd on that pin. By disabling this, GP3 becomes available
; for I/O.

    #include <p16f690.inc>
    __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_ON & _MCLRE_OFF


; The PIC assembler will warn every time you try to use a register that isn't
; in Bank 0. The warning is annoying and unnecessary.
    errorlevel -302

; Sensible defaults for GPIO - all 0.
    bcf     STATUS, RP0
    bcf     STATUS, RP1
    clrf    PORTA
    clrf    PORTB
    clrf    PORTC

; All analog inputs should instead be available as GPIO.
    bsf     STATUS, RP1
    clrf    ANSEL
    clrf    ANSELH

; GPIO as output for LEDs, input for switch.
    bsf     STATUS, RP0
    bcf     STATUS, RP1
    clrf    TRISA
    movlw   b'00010000'
    movwf   TRISB
    clrf    TRISC
; Enable PORT{A,B} individual pull-up resistors. On reset, WPU{A,B} should be
; all 1's, but still need to set the global flag in OPTIONS.
    bcf     OPTION_REG, NOT_RABPU

; Back to Bank 0 so that we have access to GPIO.
    bcf     STATUS, RP0

    movlw   0
    movwf   ANODE_COUNTER
loop

; Wait a little bit..

    movlw   0x08
    movwf   COUNT1
    movlw   0x10
    movwf   COUNT2
    movlw   0x01
    movwf   COUNT3
Delay_0
    decfsz  COUNT1, f
    goto    $+2
    decfsz  COUNT2, f
    goto    $+2
    decfsz  COUNT3, f
    goto    Delay_0
    goto    $+1
    nop
    movlw   63
    movwf   COUNT1

; Increment ANODE_COUNTER and set LED pins accordingly.

    incf    ANODE_COUNTER, 1

    btfsc   ANODE_COUNTER, 0
    bsf     PORTA, 0
    btfss   ANODE_COUNTER, 0
    bcf     PORTA, 0

    btfsc   ANODE_COUNTER, 1
    bsf     PORTA, 2
    btfss   ANODE_COUNTER, 1
    bcf     PORTA, 2

    btfsc   ANODE_COUNTER, 2
    bsf     PORTC, 0
    btfss   ANODE_COUNTER, 2
    bcf     PORTC, 0

    btfsc   ANODE_COUNTER, 3
    bsf     PORTC, 1
    btfss   ANODE_COUNTER, 3
    bcf     PORTC, 1

    btfsc   ANODE_COUNTER, 4
    bsf     PORTC, 2
    btfss   ANODE_COUNTER, 4
    bcf     PORTC, 2

    btfsc   ANODE_COUNTER, 5
    bsf     PORTA, 5
    btfss   ANODE_COUNTER, 5
    bcf     PORTA, 5

    btfsc   ANODE_COUNTER, 6
    bsf     PORTA, 4
    btfss   ANODE_COUNTER, 6
    bcf     PORTA, 4

    btfsc   ANODE_COUNTER, 7
    bsf     PORTA, 3
    btfss   ANODE_COUNTER, 7
    bcf     PORTA, 3

; If the button is being pressed, reset counter.

    btfss   PORTB, 4
    clrf    ANODE_COUNTER

; Repeat this forever.
    goto    loop

    end
