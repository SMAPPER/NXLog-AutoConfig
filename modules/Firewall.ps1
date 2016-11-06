if(Test-Path "C:\Program Files (x86)\nxlog\nxlog.exe"){
  netsh firewall add allowedprogram "C:\Program Files (x86)\nxlog\nxlog.exe" "NXLog" ENABLE
} else {
  netsh firewall add allowedprogram "C:\Program Files\nxlog\nxlog.exe" "NXLog" ENABLE
}
