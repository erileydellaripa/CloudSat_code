; NAME:
 ; COLORBAR
 ;
 ; PURPOSE:
 ; The purpose of this routine is to add a color bar to the current
 ; graphics window.
 ;
 ; CATEGORY:
 ; Graphics, Widgets.
 ;
 ; CALLING SEQUENCE:
 ; COLORBAR
 ;
 ; INPUTS:
 ; None.
 ;
 ; KEYWORD PARAMETERS:
 ;
 ; BOTTOM: The lowest color index of the colors to be loaded in
 ; the bar.
 ;
 ; CHARSIZE: The character size of the color bar annotations. Default is 1.0.
 ;
 ; COLOR: The color index of the bar outline and characters. Default
 ; is !P.Color..
 ;
 ; DIVISIONS: The number of divisions to divide the bar into. There will
 ; be (divisions + 1) annotations. The default is 6.
 ;
 ; FONT: Sets the font of the annotation. Hershey: -1, Hardware:0, True-Type: 1.
 ;
 ; FORMAT: The format of the bar annotations. Default is '(I5)'.
 ;
 ; MAX: The maximum data value for the bar annotation. Default is
 ; NCOLORS.
 ;
 ; MIN: The minimum data value for the bar annotation. Default is 0.
 ;
 ; MINOR: The number of minor tick divisions. Default is 2.
 ;
 ; NCOLORS: This is the number of colors in the color bar.
 ;
 ; POSITION: A four-element array of normalized coordinates in the same
 ; form as the POSITION keyword on a plot. Default is
 ; [0.88, 0.15, 0.95, 0.95] for a vertical bar and
 ; [0.15, 0.88, 0.95, 0.95] for a horizontal bar.
 ;;
 ; RANGE: A two-element vector of the form [min, max]. Provides an
 ; alternative way of setting the MIN and MAX keywords.
 ;
 ; RIGHT: This puts the labels on the right-hand side of a vertical
 ; color bar. It applies only to vertical color bars.
 ;
 ; TITLE: This is title for the color bar. The default is to have
 ; no title.
 ;
 ; TOP: This puts the labels on top of the bar rather than under it.
 ; The keyword only applies if a horizontal color bar is rendered.
 ;
 ; VERTICAL: Setting this keyword give a vertical color bar. The default
 ; is a horizontal color bar.
 ;
 ; COMMON BLOCKS:
 ; None.
 ;
 ; SIDE EFFECTS:
 ; Color bar is drawn in the current graphics window.
 ;
 ; RESTRICTIONS:
 ; The number of colors available on the display device (not the
 ; PostScript device) is used unless the NCOLORS keyword is used.
 ;
 ; EXAMPLE:
 ; To display a horizontal color bar above a contour plot, type:
 ;
 ; LOADCT, 5, NCOLORS=100
 ; CONTOUR, DIST(31,41), POSITION=[0.15, 0.15, 0.95, 0.75], $
 ; C_COLORS=INDGEN(25)*4, NLEVELS=25
 ; COLORBAR, NCOLORS=100, POSITION=[0.15, 0.85, 0.95, 0.90]
 ;
 ; MODIFICATION HISTORY:
 ; Written by: David Fanning, 10 JUNE 96.
 ; 10/27/96: Added the ability to send output to PostScript. DWF
 ; 11/4/96: Substantially rewritten to go to screen or PostScript
 ; file without having to know much about the PostScript device
 ; or even what the current graphics device is. DWF
 ; 1/27/97: Added the RIGHT and TOP keywords. Also modified the
 ; way the TITLE keyword works. DWF
 ; 7/15/97: Fixed a problem some machines have with plots that have
 ; no valid data range in them. DWF
 ; 12/5/98: Fixed a problem in how the colorbar image is created that
 ; seemed to tickle a bug in some versions of IDL. DWF.
 ; 1/12/99: Fixed a problem caused by RSI fixing a bug in IDL 5.2. Sigh... DWF.
 ; 3/30/99: Modified a few of the defaults. DWF.
 ; 3/30/99: Used NORMAL rather than DEVICE coords for positioning bar. DWF.
 ; 3/30/99: Added the RANGE keyword. DWF.
 ; 3/30/99: Added FONT keyword. DWF
 ; 5/6/99: Many modifications to defaults. DWF.
 ; 5/6/99: Removed PSCOLOR keyword. DWF.
 ; 5/6/99: Improved error handling on position coordinates. DWF.
 ; 5/6/99. Added MINOR keyword. DWF.
 ; 5/6/99: Set Device, Decomposed=0 if necessary. DWF.
 ;-

 PRO COLORBAR, BOTTOM=bottom, CHARSIZE=charsize, COLOR=color, DIVISIONS=divisions, $
    FORMAT=format, POSITION=position, MAX=max, MIN=min, NCOLORS=ncolors, $
    TITLE=title, VERTICAL=vertical, TOP=top, RIGHT=right, MINOR=minor, $
    RANGE=range, FONT=font, TICKLEN=ticklen, _EXTRA=extra, Major=major

    ; Return to main level on error.

 On_Error,1

    ; Is the PostScript device selected?

 postScriptDevice = (!D.NAME EQ 'PS' OR !D.NAME EQ 'PRINTER')

    ; Which release of IDL is this?

 thisRelease = Float(!Version.Release)

     ; Check and define keywords.

 IF N_ELEMENTS(ncolors) EQ 0 THEN BEGIN

    ; Most display devices to not use the 256 colors available to
    ; the PostScript device. This presents a problem when writing
    ; general-purpose programs that can be output to the display or
    ; to the PostScript device. This problem is especially bothersome
    ; if you don't specify the number of colors you are using in the
    ; program. One way to work around this problem is to make the
    ; default number of colors the same for the display device and for
    ; the PostScript device. Then, the colors you see in PostScript are
    ; identical to the colors you see on your display. Here is one way to
    ; do it.

    IF postScriptDevice THEN BEGIN
       oldDevice = !D.NAME

          ; What kind of computer are we using? SET_PLOT to appropriate
          ; display device.

       thisOS = !VERSION.OS_FAMILY
       thisOS = STRMID(thisOS, 0, 3)
       thisOS = STRUPCASE(thisOS)
       CASE thisOS of
          'MAC': SET_PLOT, thisOS
          'WIN': SET_PLOT, thisOS
          ELSE: SET_PLOT, 'X'
       ENDCASE

          ; Here is how many colors we should use.

       ncolors = !D.TABLE_SIZE
       SET_PLOT, oldDevice
     ENDIF ELSE ncolors = !D.TABLE_SIZE
 ENDIF
 IF N_ELEMENTS(bottom) EQ 0 THEN bottom = 0B
 IF N_ELEMENTS(charsize) EQ 0 THEN charsize = 1.0
 IF N_ELEMENTS(format) EQ 0 THEN format = '(I5)'
 IF N_ELEMENTS(color) EQ 0 THEN color = !P.Color
 IF N_ELEMENTS(min) EQ 0 THEN min = 0
 IF N_ELEMENTS(max) EQ 0 THEN max = ncolors
 IF N_ELEMENTS(ticklen) EQ 0 THEN ticklen = 0.2
 IF N_ELEMENTS(minor) EQ 0 THEN minor = 2
 IF N_ELEMENTS(range) NE 0 THEN BEGIN
    min = range[0]
    max = range[1]
 ENDIF
 IF N_ELEMENTS(divisions) EQ 0 THEN divisions = 6
 IF N_ELEMENTS(major) NE 0 THEN divisions = major
 IF N_ELEMENTS(font) EQ 0 THEN font = -1
 IF N_ELEMENTS(title) EQ 0 THEN title = ''

 IF KEYWORD_SET(vertical) THEN BEGIN
    bar = REPLICATE(1B,20) # BINDGEN(ncolors)
    IF N_ELEMENTS(position) EQ 0 THEN BEGIN
       position = [0.88, 0.1, 0.95, 0.9]
    ENDIF ELSE BEGIN
       IF position[2]-position[0] GT position[3]-position[1] THEN BEGIN
          position = [position[1], position[0], position[3], position[2]]
       ENDIF
       IF position[0] GE position[2] THEN Message, "Position coordinates can't be reconciled."
       IF position[1] GE position[3] THEN Message, "Position coordinates can't be reconciled."
    ENDELSE
 ENDIF ELSE BEGIN
    bar = BINDGEN(ncolors) # REPLICATE(1B, 20)
    IF N_ELEMENTS(position) EQ 0 THEN BEGIN
       position = [0.1, 0.88, 0.9, 0.95]
    ENDIF ELSE BEGIN
       IF position[3]-position[1] GT position[2]-position[0] THEN BEGIN
          position = [position[1], position[0], position[3], position[2]]
       ENDIF
       IF position[0] GE position[2] THEN Message, "Position coordinates can't be reconciled."
       IF position[1] GE position[3] THEN Message, "Position coordinates can't be reconciled."
    ENDELSE
 ENDELSE

    ; Scale the color bar.

  bar = BYTSCL(bar, TOP=ncolors-1) + bottom

    ; Get starting locations in NORMAL coordinates.

 xstart = position(0)
 ystart = position(1)

    ; Get the size of the bar in NORMAL coordinates.

 xsize = (position(2) - position(0))
 ysize = (position(3) - position(1))

    ; Display the color bar in the window. Sizing is
    ; different for PostScript and regular display.

 IF postScriptDevice THEN BEGIN

    TV, bar, xstart, ystart, XSIZE=xsize, YSIZE=ysize, /Normal

 ENDIF ELSE BEGIN

    bar = CONGRID(bar, CEIL(xsize*!D.X_VSize), CEIL(ysize*!D.Y_VSize), /INTERP)

         ; Decomposed color off if device supports it.

    CASE StrUpCase(!D.NAME) OF
         'X': BEGIN
             IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
             Device, Decomposed=0
             ENDCASE
         'WIN': BEGIN
             IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
             Device, Decomposed=0
             ENDCASE
         'MAC': BEGIN
             IF thisRelease GE 5.2 THEN Device, Get_Decomposed=thisDecomposed
             Device, Decomposed=0
             ENDCASE
         ELSE:
    ENDCASE

    TV, bar, xstart, ystart, /Normal

 ENDELSE

    ; Annotate the color bar.

 IF KEYWORD_SET(vertical) THEN BEGIN

    IF KEYWORD_SET(right) THEN BEGIN

       PLOT, [min,max], [min,max], /NODATA, XTICKS=1, $
          YTICKS=divisions, XSTYLE=1, YSTYLE=9, $
          POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
          YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', YTICKLEN=ticklen , $
          YRANGE=[min, max], FONT=font, _EXTRA=extra, YMINOR=minor

       AXIS, YAXIS=1, YRANGE=[min, max], YTICKFORMAT=format, YTICKS=divisions, $
          YTICKLEN=ticklen, YSTYLE=1, COLOR=color, CHARSIZE=charsize, $
          FONT=font, YTITLE=title, _EXTRA=extra, YMINOR=minor

    ENDIF ELSE BEGIN

       PLOT, [min,max], [min,max], /NODATA, XTICKS=1, $
          YTICKS=divisions, XSTYLE=1, YSTYLE=9, YMINOR=minor, $
          POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
          YTICKFORMAT=format, XTICKFORMAT='(A1)', YTICKLEN=ticklen , $
          YRANGE=[min, max], FONT=font, YTITLE=title, _EXTRA=extra

       AXIS, YAXIS=1, YRANGE=[min, max], YTICKFORMAT='(A1)', YTICKS=divisions, $
          YTICKLEN=ticklen, YSTYLE=1, COLOR=color, CHARSIZE=charsize, $
          FONT=font, _EXTRA=extra, YMINOR=minor

    ENDELSE

 ENDIF ELSE BEGIN

    IF KEYWORD_SET(top) THEN BEGIN

       PLOT, [min,max], [min,max], /NODATA, XTICKS=divisions, $
          YTICKS=1, XSTYLE=9, YSTYLE=1, $
          POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
          YTICKFORMAT='(A1)', XTICKFORMAT='(A1)', XTICKLEN=ticklen, $
          XRANGE=[min, max], FONT=font, _EXTRA=extra, XMINOR=minor

       AXIS, XTICKS=divisions, XSTYLE=1, COLOR=color, CHARSIZE=charsize, $
          XTICKFORMAT=format, XTICKLEN=ticklen, XRANGE=[min, max], XAXIS=1, $
          FONT=font, XTITLE=title, _EXTRA=extra, XCHARSIZE=charsize, XMINOR=minor

    ENDIF ELSE BEGIN

       PLOT, [min,max], [min,max], /NODATA, XTICKS=divisions, $
          YTICKS=1, XSTYLE=1, YSTYLE=1, TITLE=title, $
          POSITION=position, COLOR=color, CHARSIZE=charsize, /NOERASE, $
          YTICKFORMAT='(A1)', XTICKFORMAT=format, XTICKLEN=ticklen, $
          XRANGE=[min, max], FONT=font, XMinor=minor, _EXTRA=extra

     ENDELSE

 ENDELSE

    ; Restore Decomposed state if necessary.

 CASE StrUpCase(!D.NAME) OF
    'X': BEGIN
       IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
       ENDCASE
    'WIN': BEGIN
       IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
       ENDCASE
    'MAC': BEGIN
       IF thisRelease GE 5.2 THEN Device, Decomposed=thisDecomposed
       ENDCASE
    ELSE:
 ENDCASE

 END
