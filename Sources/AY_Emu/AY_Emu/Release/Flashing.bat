@echo off
cd /d "%~dp0"

set Path=%Path%;D:\ST\Spectrum\AVRDUDESS-2.20-portable

avrdude -c arduino_as_isp -P COM20 -b 19200  -p lgt328p -U lfuse:w:0xE2:m -U hfuse:w:0xDF:m -U efuse:w:0xFD:m -U flash:w:AY_Emu.hex:a   
pause
  
REM avrdude.exe -c arduino_as_isp -p lgt328p -P COM20 -b 19200 -U lfuse:w:0xFF:m -U hfuse:w:0xFF:m -U efuse:w:0xFF:m 
