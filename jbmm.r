
REBOL [ Title: "Basic Mind Music" 
	author: JGC
	note: "Play "
	Version: 0.3
]

;;
;; Initial setup 
;;
do %jresources/ieee.r
xsig: xatt: xmed: yhgam: 5
ysigp: yattp: ymedp: yhgamp: 0
count: 1
average1: [0 0 0 0 0 0]
data: make binary! 1000
namefile: %jresources/tosleep.csv
lightedport: 7000
host_name: system/network/host
lightedip: host_name
jliveipOUT: 127.0.0.1
jliveportOUT: 13856 
oscipOUT: "127.0.0.1"
oscportOUT: 8000
ledlvl: 10
lan: 0
osc: 0
forceset: 0
basemultiplier: 2
multiplier: basemultiplier
	

Get_Os: does [
	switch system/version/4 [
		3 [os: "Windows" countos: "n"]
		2 [os: "MacOSX" countos: "c"]
		4 [os: "Linux" countos: "c"]
		5 [os: "BeOS" countos: "c"]
		7 [os: "NetBSD" countos: "c"]
		9 [os: "OpenBSD" countos: "c"]
		10 [os: "SunSolaris" countos: "c"]
	]
]
;;
;; jBMM Engine
;; 
doengine: does [
					data: 0
					if lan = 1 [
						newval: [count ysig yatt ymed yhgam yhgam yhgam yhgam yhgam yhgam yhgam yhgam]
				    	newdata: reform newval
				    	print newval
				    	insert outport newdata
				    	]
				    if osc = 1 [doosc]
					attlight: remove/part to-hex to-integer yatt 6
					h: to-integer multiplier * yhgam
					hval/text: h
					show hval
					;print ajoin [yhgam " " multiplier " " h]
					;print h
			    	average1/5: yhgam
			    	average1/6: ( average1/1 + average1/2 + average1/3 + average1/4 + average1/5 ) / 5
			    	either average1/6 > to-decimal ledlvl [hgambciled/data: true] [hgambciled/data: false]
					count: count + 1
					tcount/text: form count
					status/text: "Connected. Improve signal to calibrate"
					if any [ymed <> 0 forceset = 1]    
									[status/text: "Calibrated"
									]
					if yhgam = average1/3 [status/text: "Error TGC"]
					show tcount
					show hgambciled
					hgamval/text: yhgam
					show hgamval
]

;;
;; Controllers UI
;;
controllers: layout [
	anti-alias on
	backdrop effect [gradient 1x1 0.0.0 50.50.50] 
	at 20x10 text "Basic Mind Music" white
	at 230x13 hgambciled: led green
	at 20x35 status: info bold "jBMM v0.1. Start to connect" 220x25 font-color white 
;; Live recording buttons
    at 185x135 button 70 50.50.50 edge [size: 1x1] "Save" [
		saveprefs
		status/text: "Preferences saved"
		show status]
	at 180x10 hgamval: text "0000" gray 
	at 130x10 hval: text "0000" gray       
	at 20x70 tcount: text "00000" snow
	at 90x70 tsignal: text "000" snow 
	at 100x100 button 70 50.50.50 edge [size: 1x1] "Stop" [
		status/font/color: snow
		status/text: "Ready"
		show status
		tcount/text: "000"
		show tcount
		close tp
		]
	at 185x100 button 70 50.50.50 edge [size: 1x1] "Quit" [quit]		

;; Prefs buttons
	
		at 185x70 jlivebtn: button 70 50.50.50 edge [size: 1x1] "pDATA" [
										either lan <> 1 [
													lan: 1
       												outport: open/lines/no-wait tcp://localhost:13856
       												status/text: "Send Data ON"
       												show status]
       												[
       												lan: 0
       												close outport
       												status/text: "Send Data Off"
       												show status
       												]
       									]		
       			
		at 20x135 text "VirtualLED lvl" snow 
		at 120x135 toledlvl: field 45 to-string ledlvl

		
;;       						
;; RECORD from Headset data
;;
	at 20x100 button 70 50.50.50 edge [size: 1x1] "Start" [
	if os = "MacOSX" [
					if any [lightedip = "localhost" lightedip = "127.0.0.1" lightedip = host_name] [
									print "test local"
									]
					print "test MAC"
					;checktgc
				  	]
		status/text: "connect.."
		show status
		tp: open/binary/no-wait tcp://localhost:13854
		show status
		forever [  
			wait tp 
			data: copy tp
			signal: copy/part skip data 3 1
			ysig: to-integer signal
			tsignal/text: form ysig
			show tsignal
			attention: copy/part skip data 5 1
			yatt: to-integer attention
			meditation: copy/part skip data 7 1
			ymed: to-integer meditation
			hgam: copy/part skip data 38 4
			yhgam: from-ieee hgam
			either ysig < 200  
			[doengine]
			[status/text: "WRONG SIGNALS"
			]
		show status
		]
		
		]
]

Set_TimeOut: func [newto] [
	oldto: system/schemes/default/timeout
	system/schemes/default/timeout: newto
]

Restore_TimeOut: does [
	system/schemes/default/timeout: oldto 
]

; Read prefs
readprefs: does [

;jBMM prefs
					print "Preferences read"
					prefs-data: read/lines %jresources/jBMM.conf
					allplage: length? prefs-data
					data-line: pick prefs-data 1  
					data-line: pick prefs-data 2        
					prefline: parse/all data-line " "
	    			lightedip: prefline/1
	    			data-line: pick prefs-data 3           
					prefline: parse/all data-line " "
	    			ledlvl: prefline/1
	    			toledlvl/text: ledlvl
	    			show toledlvl
				]
				
; save prefs
saveprefs: does [filename: probe to-file "jresources/jBMM.conf"
;jBMM prefs
				delete filename	
				print "Preferences saved"
				write/lines filename "Preferences jBMM"
				write/append filename reduce [form lightedip]   
				write/append filename "^/"
				write/append filename reduce [form toledlvl/text]   
				write/append filename "^/"
				readprefs
				]
				
;

Get_OS
readprefs
;check TGC server ?
checktgc: does [testtgc:open/binary/no-wait tcp://localhost:13854
				if error? try [insert testlighted "read"] [status/text: "TGC connexion error"
														  show status]
				]


;;
;; Start UIs
;;
		  
view/new controllers
do-events

