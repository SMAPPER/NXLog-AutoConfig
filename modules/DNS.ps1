# Enable DNS Logging If DNS Service is detected
if(Get-Service -Name DNS -ErrorAction SilentlyContinue){
   Write-Host "Running DNS Module - Detected DNS Service"
    if(!(Test-Path "C:\WINDOWS\system32\LogFiles\DNS")){
        New-Item -ItemType Directory -Path "C:\WINDOWS\system32\LogFiles\DNS"
    }
    $parameter = '/Config /LogLevel 0x8000f321 /LogFilePath "C:\WINDOWS\system32\LogFiles\DNS\dns.log" /LogFileMaxSize 0xffffffff'
    $parameters = $parameter.Split(" ")
    & "$script:binPath\dnscmd.exe" $parameters
    Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\DNS\Parameters -Name LogFilePath -Value "C:\WINDOWS\system32\LogFiles\DNS\dns.log" -Force
    Restart-Service DNS
    
    $conf += '    
<Input dns>
  Module im_file
  File "C:\WINDOWS\system32\LogFiles\DNS\dns*.log"
  SavePos TRUE
  Exec $Message = $raw_event;
  Exec $NXLogHostname = '
  $conf += "'"
  $conf += $env:computername
  $conf += "';"
  $conf += '
  Exec convert_fields("AUTO", "utf-8");
  Exec to_json();
</Input>

<Route dns>
   Path dns => collector
</Route>
'
}
