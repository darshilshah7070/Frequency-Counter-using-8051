ORG 0000H
	
	MOV A,#38H              // 2lines and 5*7 matrix
	ACALL COMNWRT
	
	MOV A,#0EH             // display on cursor blinking
	ACALL COMNWRT
	
	MOV A,#01H            // clear display screen
	ACALL COMNWRT
	        
	MOV A,#06H            // increment cursor   
	ACALL COMNWRT 
	
	MOV A,#0CH            // display on,cursor off
	ACALL COMNWRT
	
	MOV A,#82H           //force cursor to beginning of 1st line
	ACALL COMNWRT
	
	
	//COUNTER
	SETB P3.5            // p3.5 as input
	MOV TMOD,#51H       // counter1 in mode 1 and timer 0 in mode 1
	MOV TL1,#00H        //intialize counter
	MOV TH1,#00H
	SETB TR1             //start counter
	                 
	MOV R0,#100         //DELAY OF 1 SECOND
	JJ:ACALL DELAY    
	DJNZ R0,JJ
	CLR TR1
	
	MOV R0,TH1           // Move higher byte to R0
	MOV R1,TL1           // Move lower byte to R1
	ACALL HEXTOBCD
	
	MOV A,#'F'
	ACALL DATAWRT
	
	MOV A,#'R'
	ACALL DATAWRT
	
	MOV A,#'E'
	ACALL DATAWRT
	
	MOV A,#'Q'
	ACALL DATAWRT
	
	MOV A,#'-'
	ACALL DATAWRT
	
	MOV A,R2
	ADD A,#48
	ACALL DATAWRT 
	
	MOV A,R3
	ADD A,#48
	ACALL DATAWRT 
	
	MOV A,R4
	ADD A,#48
	ACALL DATAWRT 
	
	MOV A,R5
	ADD A,#48
	ACALL DATAWRT 
	
	MOV A,R6
	ADD A,#48
	ACALL DATAWRT 
	MOV R0,#0
	MOV R1,#0
	MOV R2,#0
	MOV R3,#0
	MOV R4,#0
	MOV R5,#0
	MOV R6,#0
	MOV R7,#0
	MOV A,#0
	MOV B,#0
	MOV 40H,#0
	MOV 41H,#0
	MOV 50H,#0
	
	SSSS:SJMP SSSS
	
	HEXTOBCD:
	
	                            ;R0 IS HIGHER BYTE INPUT
	                            ;R1 IS LOWER BYTE INPUT
	                            ;R2,R3,R4,R5,R6 ARE OUTPUT ACCORDING TO ORDER
                                 ;registers 40H,41H.. are temp
	                             ;;50H IS ALSO TEMP FOR RECOVERY
	
	
	;10000-->2710H
	;1000-->3E8H
	;100-->64H
	;10-->AH
	
	
	             //H0  6 5535
	MOV 40H,R0
	MOV 41H,R1
	SS:CLR C
	MOV A,41H
	SUBB A,#10H
	MOV 41H,A
	MOV A,40H
	SUBB A,#27H
	MOV 40H,A
	JC H0
	INC R2
	SJMP SS
	H0:                     //HIGHER BYTE COUNTED
	
	                      //H1
	                     //RECOVERY  5 535
	MOV 40H,R0
	MOV 41H,R1
	CLR C
	 
	MOV 50H,R2
	MOV A,50H
	JZ REC1
	
	JJ1:CLR C
	MOV A,41H
	SUBB A,#10H
	MOV 41H,A
	MOV A,40H
	SUBB A,#27H
	MOV 40H,A
	DJNZ 50H,JJ1
	MOV R0,40H
	MOV R1,41H
	
	
	REC1:
	TT:CLR C
	MOV A,41H
	SUBB A,#0E8H
	MOV 41H,A
	MOV A,40H
	SUBB A,#03H
	MOV 40H,A
	JC H1
	INC R3
	SJMP TT
	H1:                  //H1 IS COUNTED
	
	
                         //H2
	                     //RECOVERY  5 35
	MOV 40H,R0
	MOV 41H,R1
	CLR C
	MOV 50H,R3
	MOV A,50H
	JZ REC2
	
	JJ2:CLR C
	MOV A,41H
	SUBB A,#0E8H
	MOV 41H,A
	MOV A,40H
	SUBB A,#03H
	MOV 40H,A
	DJNZ 50H,JJ2
	MOV R0,40H
	MOV R1,41H
	
	REC2:
	UU:CLR C
	MOV A,41H
	SUBB A,#64H
	MOV 41H,A
	MOV A,40H
	SUBB A,#00H
	MOV 40H,A
	JC H2
	INC R4
	SJMP UU
	H2:                //H2 IS COUNTED
	
	
	
	                           //H3
	                          //RECOVERY  35
	MOV 40H,R0
	MOV 41H,R1
	CLR C
	MOV 50H,R4
	MOV A,50H

	
	JJ3:CLR C
	MOV A,41H
	SUBB A,#064H
	MOV 41H,A
	MOV A,40H
	SUBB A,#00H
	MOV 40H,A
	DJNZ 50H,JJ3
	MOV R0,40H
	MOV R1,41H

	
	                 //R1 HAVE 8 BIT VALUE
	MOV A,R1
	MOV B,#10
	DIV AB
	MOV R5,A
	MOV R6,B
	RET
	
	
	
	
	
	
	                   //DELAY of 0.01 seconds
	DELAY:
	
	MOV TMOD,#51H
	MOV TH0,#0DBH
	MOV TL0,#0FFH
	SETB TR0
	XX:JNB TF0,XX
	CLR TF0
	CLR TR0
	RET
	
	
	
	                     //LCD FOR COMMAND
	COMNWRT:
ACALL READY	
	MOV P1,A
	CLR P2.0             //RS=0 for command
	CLR P2.1             // writing
	SETB P2.2             //enable from high to low
	ACALL DELAY_LCD
	CLR P2.2
	RET
	
	                        //LCD FOR DATA
	DATAWRT:
ACALL READY
	MOV P1,A             
	SETB P2.0              //RS=1 for data
	CLR P2.1               //writing
	SETB P2.2              // enable form high to low
	ACALL DELAY_LCD
	CLR P2.2
	RET
	
	
	DELAY_LCD:
	SETB PSW.4
	CLR PSW.3
	MOV R3,#50
	FF:MOV R4,#255
	KK: DJNZ R4,KK
	DJNZ R3,FF
	CLR PSW.4
	CLR PSW.3
	RET
	
	READY: 
	SETB P1.7    
	CLR P2.0               //Command register enable
	SETB P2.1              //reading  command register
	LL:CLR P2.2            // make enable low to high
	ACALL DELAY_LCD        // latch time
	SETB P2.2
	JB P1.7 ,LL            
	RET
	
	END

