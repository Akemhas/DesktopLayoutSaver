;***********************************************************************************************************************
;                                         ColorBox
;    Minimalist modal MsgBox replacement with font settings, background color,
;    optional timeout and allowing use until 5 buttons.
;    With more than 1 button, return selected button value
;              (1-Yes  - also true for 2 buttons | 0-No  - also false for 2 buttons |    2-Cancel for 3 buttons
;               3-Extra for 4 buttons, 4-Plus for 5 buttons )
;**********************************************************************************************************************
ColorBox(Tit = "Message", Mess="Pause", NBut=1,TOut=0, DefL=1, Text1L:="Yes", Text2L = "No", Text3L="Cancel", Text4L="Extra", Text5L = "Plus"
	, FontL="One Sans", FontOpt="cBlack w500 s10",WindowColor="", CallerGui="")
; Tit - Windows title
; Mess- Message with 1 or more lines (using 'r'n (CR/LF) inside string to change line)
; NBut - Default 1 button, but accept until 5 buttons.
; TOut - Timeout in seconds, default 0 (No Timeout)
; DefL - Default button number from 1 to NBut buttons. Default 1. <Enter> return default button. 0 no default, in that case <Enter> does nothing
; Text1L - 1nd Button text. Default "OK" with 1 button or "Yes" with 2  buttons or more - Return 1
; Text2L - 2nd Button text. Default "No" - Return 0
; Text3L - 3nd Button text. Default "Cancel" - Return 2
; Text4L - 4nd Button text. Default "Extra" - Return 3
; Text5L - 5nd Button text. Default "Plus" - Return 4
; FontL - Font name (default "Lucida Console")
; FontOpt - Font options,  default is blue with weight 500 (more than normal less than bold). One can specify "italic", "bold", "underline", etc.
; Window Color - Default: light silver, can be any color like "black", "blue", etc.
; CallerGui  - If that message was started from a caller Modal GUI, it demands to be disabled at the beginning and enabled again at the end.
{
	Static ETimeOut ; Variable shared with timeout section
	Local RetLoc, HasGui, NInd, MaxBut=5

	ETimeOut := false
	RetLoc := 1
	HasGui := (CallerGui<>"")
	Labels := ["Yes","No","Canc","Xtra","Plus"]

	if (HasGui)
		Gui, %CallerGui%:+Disabled

	Gui, ColorBox:Destroy
	Gui, ColorBox:Color,%WindowColor%

	Gui, ColorBox:Font,%FontOpt%,%FontL%
	Gui, ColorBox:Add,Text,,%Mess%
	Gui, ColorBox:Font

	GuiControlGet,Text, ColorBox:Pos,Static1

	if (TOut<>0) ; Prepare for default answer also in timeout event
		if (DefL<=1)
			RetLoc := DefL=0 ? -1 : 1 ; Return -1 (No default) or 1 (OK)
		else
			Loop % MaxBut-1 {
				NInd := A_Index+1 ; Return 0 (2 buttons and default 2nd Button) or (Button Number-1) if Default 3nd button and so on
				if ( DefL=NInd and NBut>=NInd )
					RetLoc := ( DefL=2 ? 0 : NInd-1 )
			}

	if (TOut<>0) ; Prepare for default answer also in timeout event
		RetLoc := DefL=0 ? -1 : ( DefL=1 ? 1 : (DefL = 2 and NBut>=2 ? 0 : ( DefL = 3 and NBut=3 ? 2 : DefL ) ) )

	Loop % NBut {
		if ( (Text1L = "Yes") and (NBut=1) )
			Text1L := "OK"
		if (A_Index=1) ; TextW: Non-documented variable that stores text width
			Gui, ColorBox:Add,Button,% (DefL=1 or NBut=1 ? "Default " : "") . "y+10 w75 gYes xp+" (TextW / 2) - 38 * NBut , %Text1L%
		else
			Gui, ColorBox:Add,Button,% (DefL=A_Index ? "Default " : "") . "yp+0 w75 g" . Labels[A_Index] . " x+" 10, % Text%A_Index%L
	}

	Gui, ColorBox:-SysMenu +OwnDialogs +AlwaysOnTop ; Clean and modal window message. No Minimize, maximize, close icon and AHK icon.
	Gui, ColorBox:Show,,%Tit%

	If (TOut<>0) ; TimeOut in seconds
		SetTimer TimeOut, % TOut*1000

	Gui, ColorBox:+LastFound ;  Last selected window
	WinWaitClose ;  Wait for the GUI window closes. Make it strictly modal.

	if (HasGui)
		Gui, %CallerGui%:-Disabled ; Enable caller GUI back

	SetTimer TimeOut, Off
	return RetLoc

	Yes: ; First button
		Gui, ColorBox:Destroy
		RetLoc := 1
	return

	No: ; Second button
		Gui, ColorBox:Destroy
		RetLoc := 0
	return

	Canc: ; Third button
		Gui, ColorBox:Destroy
		RetLoc := 2
	return

	XTra: ; Fourth button
		Gui, ColorBox:Destroy
		RetLoc := 3
	return

	Plus: ; Fifth button
		Gui, ColorBox:Destroy
		RetLoc := 4
	return

	TimeOut: ; Timeout section
		Gui, ColorBox:Destroy
		ETimeOut := True ; Share just static variables with enclosing function
	return
}