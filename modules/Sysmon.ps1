
#Install Sysmon
if($script:architecture -eq "AMD64"){
    Write-Host "Running Sysmon Module 64 bit"
    #if service exists - update config
    if(Get-Service -Name Sysmon* -ErrorAction SilentlyContinue){
            C:\Temp\nxlog\bin\sysmon64.exe –accepteula –c C:\Temp\nxlog\bin\sysmon.xml
    }
    else { # if no service exists - install sysmon
            C:\Temp\nxlog\bin\sysmon64.exe –accepteula –i C:\Temp\nxlog\bin\sysmon.xml
    }
}else {
    Write-Host "Running Sysmon Module 32 bit"
    if(Get-Service -Name Sysmon* -ErrorAction SilentlyContinue){
            C:\Temp\nxlog\bin\sysmon.exe –accepteula –c C:\Temp\nxlog\bin\sysmon.xml
    }
    else { # if no service exists - install sysmon
            C:\Temp\nxlog\bin\sysmon.exe –accepteula –i C:\Temp\nxlog\bin\sysmon.xml
    }
}
 
#NXLog
$caption = (Get-WmiObject -class Win32_OperatingSystem).Caption
if(($caption -match "2003") -or ($caption -match "XP")){
    $win_module = "im_mseventlog"
} else {
    $win_module = "im_msvistalog"
}

$conf += "<Input sysmon>
"
$conf += "    Module      $win_module
"
$conf += '
    <QueryXML>
        <QueryList>
            <Query Id="0">
		<Select Path="Microsoft-Windows-Sysmon/Operational">*</Select>
            </Query>
        </QueryList>
    </QueryXML>
    <Exec>
      if $Category == undef $Category = 0;
        $EventTimeStr = strftime($EventTime, "YYYY-MM-DDThh:mm:ss.sUTC");
        if $EventType == "CRITICAL"
        {
            $EventTypeNum = 1;
            $EventTypeStr = "Critical";
        }
        else if $EventType == "ERROR"
        {
            $EventTypeNum = 2;
            $EventTypeStr = "Error";
        }
        else if $EventType == "INFO"
        {
            $EventTypeNum = 4;
            $EventTypeStr = "Informational";
        }
        else if $EventType == "WARNING"
        {
            $EventTypeNum = 3;
            $EventTypeStr = "Warning";
        }
        else if $EventType == "VERBOSE"
        {
            $EventTypeNum = 5;
            $EventTypeStr = "Verbose";
        }
    else if $EventType == "AUDIT_SUCCESS"
        {
            $EventTypeNum = 8;
            $EventTypeStr = "Success Audit";
        }
    else if $EventType == "AUDIT_FAILURE"
        {
            $EventTypeNum = 16;
            $EventTypeStr = "Failure Audit";
        }
        else
        {
            $EventTypeNum = 0;
            $EventTypeStr = "Audit";
        }
        if $OpcodeValue == 0 $Opcode = "Info";
        if $TaskValue == 0 $TaskValue = "None";

        $Message = "AgentDevice=WindowsLog" +
            "\tAgentLogFile=" + $Channel +
           "\tSource=" + $SourceName +
            "\tComputer=" + hostname_fqdn() +
            "\tOriginatingComputer=" + $Hostname +
            "\tUser=" + $AccountName +
            "\tDomain=" + $Domain +
        "\tEventID=" + $EventID +
            "\tEventIDCode=" + $EventID +
        "\tEventTypeName=" + $EventType +
            "\tEventType=" + $EventTypeNum +
            "\tEventCategory=" + $Category +
            "\tRecordNumber=" + $RecordNumber +
            "\tTimeGenerated=" + $EventTimeStr +
            "\tTimeWritten=" + $EventTimeStr +
            "\tLevel=" + $EventTypeStr +
            "\tKeywords=" + $Keywords +
            "\tTask=" + $TaskValue +
            "\tOpcode=" + $Opcode +
            "\tMessage=" + $Message;
        $Hostname = hostname();
        delete($SourceName);
        delete($Severity);
        delete($SeverityValue);
        to_syslog_bsd();
    </Exec>
</Input>

<Route sysmon>
    Path    sysmon => collector
</Route>
'