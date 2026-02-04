. vconf preset
. put me in root of project
vconf   START 0

        . imports
        . -----------------------------------------------------------------------------------------
        . loop main function
        EXTREF main
        . v functions
        EXTREF c_i,c_a,c_o,c_I,c_A,c_h,c_l,c_k,c_j,c_g,c_G,c_w,c_b,c_0,c_dlr,c_y,c_d,c_p,cmd
        . inout interface
        EXTREF ioinit,cl,cr,cu,cd,crsrnl,ctop,cbtm,cfirst,clast,cprev,rch,pch,map_ch,map_ln,input,shiftr,shiftl,shiftd,drawnp
        EXTREF chnull,chesc,chent,chcrsr,chspac,chback,chshft,wnull,wesc,went,wcrsr,wspace,wback,wshift
        . map
        EXTREF mput,mget,mfun
        . stack
        EXTREF spush,spop,sp
        . -----------------------------------------------------------------------------------------

        . adding to map and going to main loop
        . -----------------------------------------------------------------------------------------
        . add ur function for '@'
        . A = character to do function
        . B = function
        LDA #0x40       . '@'
        LDB #func       . function
        +JSUB mput

        +J main          . go to main (loop)
        . -----------------------------------------------------------------------------------------

        . functions
        . -----------------------------------------------------------------------------------------
func        +STL @sp
            +JSUB spush
            +STA @sp
            +JSUB spush
            . add more if ur using other registers

            . example of printing '@' to cursor
            LDA #0x40
            +JSUB pch

func_end    +JSUB spop
            +LDA @sp
            +JSUB spop
            +LDL @sp
            RSUB
        . -----------------------------------------------------------------------------------------

        END vconf
