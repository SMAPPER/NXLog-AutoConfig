# Enable DHCP logging if DHCP Service is detected
if(Get-Service -Name DHCPServer -ErrorAction SilentlyContinue){
    Write-Host "Running DHCP Module - Detected DHCP Service"
    Set-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\DhcpServer\Parameters -Name ActivityLogFlag -Value 1 -Force
    if(Get-Service -Name DHCPServer | Where-Object {$_.status -eq "running"}){
        Start-Service DHCPServer
    }
    C:\Windows\System32\netsh.exe dhcp server set auditlog C:\WINDOWS\System32\dhcp
    C:\Windows\System32\netsh.exe dhcp server set detectconflictretry 1
    Restart-Service DHCPServer
    $conf += '
<Input dhcp>
  Module im_file
  '
  if($script:architecture -eq "AMD64"){
    $conf += 'File "C:\Windows\Sysnative\dhcp\DhcpSrvLog*.log"'
  } else {
    $conf += 'File "C:\Windows\system32\dhcp\DhcpSrvLog*.log"'
  }
  $conf += '
  SavePos TRUE
  InputType LineBased
  Exec $Message = $raw_event;
  Exec $NXLogHostname = '
  $conf += "'"
  $conf += $env:computername
  $conf += "';"
  $conf += '
  Exec to_json();
</Input>

<Route dhcp>
   Path dhcp => collector
</Route>
'
}
