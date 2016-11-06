# For this module to work you must first manually create a file called connection_string.txt
# and place it in your NXLog conf folder (Example: C:\program files (x86)\nxlog\conf\connection_string.txt)
#
# Then create a 32-bit ODBC connection preferrable using a read only account that only has access to the
# EPOEvents table
#
# The connection_string.txt file must be in the format similar to below:
# ConnectionString DSN=mcafee;Database=database_name;UID=username;PWD=password;
# 
# Change mcafee, database_name, username, and password to match your organization
# The DNS name with whatever you called the DSN, the database_name with your ePO database name, UID with
# your database username, and finally PWD password with your password:


$architecture = $ENV:PROCESSOR_ARCHITECTURE
$connectionString = ""

if($architecture -eq "AMD64"){
    if(Test-Path("C:\Program Files (x86)\nxlog\conf\connection_string.txt")){
        $connectionString = Get-Content "C:\Program Files (x86)\nxlog\conf\connection_string.txt"
    }
} else {
    if(Test-Path("C:\Program Files\nxlog\conf\connection_string.txt")){
        $connectionString = Get-Content "C:\Program Files (x86)\nxlog\conf\connection_string.txt"
    }
}

if($connectionString -ne ""){

    $conf += '<Input mcafee>
    Module      im_odbc
    '
    $conf += $connectionString
    $conf += "
    SavePos     TRUE
    SQL         SELECT AutoID AS id,AutoGUID,ServerID,ReceivedUTC,DetectedUTC,AgentGUID,Analyzer,AnalyzerName,AnalyzerVersion,AnalyzerHostName,convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[AnalyzerIPV4] + 2147483648))),1,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[AnalyzerIPV4] + 2147483648))),2,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[AnalyzerIPV4] + 2147483648))),3,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[AnalyzerIPV4] + 2147483648))),4,1))) AS AnalyzerIPV4,AnalyzerIPV6,AnalyzerMAC,AnalyzerDATVersion,AnalyzerEngineVersion,AnalyzerDetectionMethod,SourceHostName,convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[SourceIPV4] + 2147483648))),1,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[SourceIPV4] + 2147483648))),2,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[SourceIPV4] + 2147483648))),3,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[SourceIPV4] + 2147483648))),4,1))) AS SrcIP,SourceIPV6,SourceMAC,SourceUserName,SourceProcessName,SourceURL,TargetHostName,convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[TargetIPV4] + 2147483648))),1,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[TargetIPV4] + 2147483648))),2,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[TargetIPV4] + 2147483648))),3,1)))+'.'+convert(varchar(3),convert(tinyint,substring(convert(varbinary(4),convert(bigint,([EPOEvents].[TargetIPV4] + 2147483648))),4,1))) AS DstIP,TargetIPV6,TargetMAC,TargetUserName,TargetPort,TargetProtocol,TargetProcessName,TargetFileName,ThreatCategory,ThreatEventID,ThreatSeverity,ThreatName,ThreatType,ThreatActionTaken,ThreatHandled,TheTimestamp,TenantId FROM EPOEvents
    Exec to_json();
</Input>

<Output mcafee_out>
    Module      om_tcp
    Host        "
    $conf += $script:logstashHost
    $conf += '
    Port        7003
</Output>
 
<Route mcafee>
    Path mcafee => mcafee_out
</Route>

    '
}
