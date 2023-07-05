ORG 100H

.MODEL SMALL ; 64kb

.DATA
    ; 0DH,0AH ---> in order to go to the next line

    welcome db "Welcome!"    
    
    programmer db "Programmer: Pooria-Sarkhanzade (9821973123)",0DH,0AH,"$"   
    
    enterString db 0DH,0AH,"Enter a string: ",0DH,0AH,"$"    
    
    askUser db "---------------------------------------------",0DH,0AH,"Do you wish to continue or terminate ? (Y/N)",0DH,0AH,"---------------------------------------------","$"
    
    newLine db 0DH,0AH,"$"
    
    output db "Output :",0DH,0AH,"$"
                 
                 
    ; storing strings by using INT21H/0AH             
    string1 db 50 ; maximum length of string
            db ? ; length of entered string by user
            db 51 dup(0) ; memory to store string, letters
            
    string2 db 50
            db ?
            db 51 dup(0)
            
    string3 db 50
            db ?
            db 51 dup(0)
                  
                  
    count equ 3
 

; MACRO for getting strings from the user 
GET_STRING MACRO str
    XOR DX,DX
    
    LEA DX,enterString
    MOV AH,9H
    INT 21H
    
    XOR DX,DX
    XOR AX,AX         
    XOR DX,DX
            
    LEA DX,str
    MOV AH,0AH
    INT 21H
    
    MOV AH,09H
    LEA DX,newLine
    INT 21H   
ENDM

; MACRO for adding "$" to the end of each string in order to print them out with INT21/9H
TRIM_STRING MACRO string
LOCAL L
    
    XOR SI,SI
    XOR CX,CX
    
    LEA SI,string + 1
    INC [SI]
    MOV CL,[SI]
    
    XOR SI,SI
    
    LEA SI,string + 2 ; OR ---> MOV SI,OFFSET string + 2
    
    L:
        INC SI
        LOOP L
    
    ; adding 0DH,0AH for going to the next line and also in order to print the string with INT21H/9H, we must add "$" to the end of the string 
    MOV [SI],0DH
    INC SI
    MOV [SI],0AH
    INC SI
    MOV [SI],"$"
ENDM

; MACRO for printing out the strings
PRINT_STRING MACRO string
    XOR DX,DX
        
    MOV AH,9H
    LEA DX,string + 2
    INT 21H       
ENDM

; going to the next line
NEW_LINE MACRO
    MOV AH,9H
    LEA DX,newLine
    INT 21H        
ENDM

; clearing screen if user selected "continue" in the end of program
; we will use the service '06h' from INT 10H
CLEAR_SCREEN MACRO
    MOV AH,6H
    MOV AL,0H
    MOV BH,7H
    MOV CH,0H
    MOV CL,0H
    MOV DH,25
    MOV DL,79
    INT 10H        
ENDM
  
.CODE
    MAIN:
        MOV AX,@DATA
        MOV DS,AX
        
        XOR AX,AX
        
        ; clear screen
        CLEAR_SCREEN
        
        ; reseting all registers
        XOR AX,AX
        XOR BX,BX
        XOR CX,CX
        XOR DX,DX
        
        ; printing Welcome message colorfully !
        LEA SI,welcome
        MOV CX,8H
        MOV BL,01001110B ; 1111(white-background RED) 1(font-weight) 110(font-color YELLOW)
        PRINT_WELOME:
            MOV AH,9H
            ; using stack, pushing CX to there to avoid getting mixing up between 'Loop'-CX AND 'INT10H/2H'-CX
            PUSH CX
            MOV CX,1
        
            MOV AL,[SI]
            INT 10H
            
            ; using INT10H/2H in order to print characters with specific color
            MOV AH,2H
            INC DL
            INT 10H 
            
            INC SI
            
            POP CX
            LOOP PRINT_WELOME
            
            MOV DL,0H
            MOV DH,2H
            INT 10H
            
            XOR AX,AX
            XOR BX,BX
            XOR CX,CX
            XOR DX,DX                 
        
        ; printing Programmer
        MOV AH,9H
        LEA DX,programmer
        INT 21H
        
        ; getting strings from user
        GET_STRING string1
        GET_STRING string2
        GET_STRING string3
        
        ; adding "$" to end of each string
        TRIM_STRING string1
        TRIM_STRING string2
        TRIM_STRING string3
        
        ; going to the next line
        NEW_LINE
        
        XOR DX,DX ; OR -> MOV DX,0H OR -> SUB DX,DX
         
        LEA DX,output
        INT 21H
        
        XOR DX,DX
        
        ; going to the next line
        NEW_LINE
        
        ; printing all strings in the same order that user entered
        PRINT_STRING string1
        PRINT_STRING string2
        PRINT_STRING string3
        
        XOR AX,AX
        XOR BX,BX
        XOR DX,DX
        XOR CX,CX
        
        ; going to the next line
        NEW_LINE
        
        ; asking user that if he wants to continue or terminate the program
        MOV AH,9H
        LEA DX,askUser
        INT 21H
        
        MOV AH,0H
        INT 16H
        
        ; if "Y" we will execute the program again if "N" we will terminate the program with INT21/4CH
        CMP AL,"Y"
        JNE TERMINATE
        JE MAIN


TERMINATE:
    MOV AH,4CH
    INT 21H                             
        
END MAIN                              