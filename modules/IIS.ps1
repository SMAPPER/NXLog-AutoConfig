# This module is designed to configure auditing and logging for IIS
# 
# NOTE:
# If you have IIS 7.0 servers you should download iis7psprov_x64.msi and iis7psprov_x86.msi
# from Microsoft and put on your web distribution point under the binaries folder
#
# If you have IIS 6.0 servers you have to manually configure logging on each site.  They should
#
# Set fields to whatever fields you'd like to collect 
# You MUST verify the order they are listed matches a real IIS log file
# To do so open a log typically located at C:\inetpub\logs\logfiles\ and look at
# the Fields line at the top of the file
if(Get-Service -Name W3SVC -ErrorAction SilentlyContinue){
    $fields = "Date,Time,ServerIP,Method,UriStem,UriQuery,ServerPort,UserName,ClientIP,UserAgent,Referer,Host,HttpStatus,HttpSubStatus,Win32Status,TimeTaken"

    # This section breaks up the $fields listed above and generates the NXLog section required to collect the fields correctly
    $fields_array = $fields.Split(",")
    $nxlogFields = "Fields "
    $nxlogFieldTypes = "FieldTypes "
    $fields_array | ForEach-Object {
        # Set fields listed in $integerFields as integers
        $integerFields = "ServerPort", "HttpStatus", "HttpSubStatus", "Win32Status", "TimeTaken"
        $field = '$' + $_
        if($integerFields -contains $_){
            $type = "integer"
        } else {
            $type = "string"
        }
        $nxlogFields += "$field, "
        $nxlogFieldTypes += "$type, "
    }
    $nxlogFields = $nxlogFields.Substring(0,($nxlogFields.Length-2))
    $nxlogFieldTypes = $nxlogFieldTypes.Substring(0,($nxlogFieldTypes.Length-2))

    [regex]$r="[^0-9$]"
    $IISVersion = ""
    # IIS Section
    if(Test-Path -Path "HKLM:\SOFTWARE\Microsoft\InetStp"){
        $IISVersion = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp\ | Select SetupString
    }
    if($IISVersion -eq "IIS 7.0"){
        $WebClient = New-Object System.Net.WebClient
        if($script:architecture -eq "AMD64"){
            $WebClient.DownloadFile("$script:webFileLocation\binaries\iis7psprov_x64.msi","$script:binPath\iis7psprov_x64.msi")
            & "msiexec.exe" @('/i', "$script:binPath\iis7psprov_x64.msi", '/qn')
            Sleep -Seconds 60
        } else {
            $WebClient.DownloadFile("$script:webFileLocation\binaries\iis7psprov_x86.msi","$script:binPath\iis7psprov_x86.msi")
            & "msiexec.exe" @('/i', "$script:binPath\iis7psprov_x86.msi", '/qn')
            Sleep -Seconds 60
        }
    }
    if($IISVersion | Select-String -Pattern "IIS"){
        if ($script:conf | Select-String -Pattern "Extension w3c"){
            Write-Host "w3c extension already exists"
        } else {
            $script:conf += '

    <Extension w3c>
    Module xm_csv
    '
    $script:conf += $nxlogFields
    $script:conf += '
    '
    $script:conf += $nxlogFieldTypes
    $script:conf += '
    Delimiter " "
    </Extension>

    <Output iis_out>
        Module	om_tcp
        Host		'
        $script:conf += $script:logstashHost
        $script:conf += '
        Port        7001
    </Output>
    '
        }

        If ($IISVersion -match "IIS 6.0") {
            Write-Host "Running version IIS 6.0"
            Get-ChildItem C:\WINDOWS\system32\LogFiles -ErrorAction SilentlyContinue |  Where-Object {$_.Name -match "W3SVC"} | ForEach-Object { 
                $SiteID = $_.Name.Replace("W3SVC","") -creplace '[^0-9]', ""
                $site = "W3SVC" + $SiteID
                $script:conf +='    
            <Input ' + $site + '>
            Module    im_file
    	    File	"C:\\windows\\system32\\logfiles\\W3SVC' + $SiteID + '\\ex*""
            SavePos  TRUE
     
            Exec if $raw_event =~ /^#/ drop();				\
               else							\
               {							\
                    w3c->parse_csv();					\
                    $EventTime = parsedate($date + " " + $time);	\
                    $raw_event = to_json();				\
               }
        </Input>

        <Route ' + $site + '>
    	    Path		' + $site + ' => iis_out
        </Route>
        '
            }
        }
        If ($IISVersion -match "IIS 7.5" -Or $IISVersion -match "IIS 7.0" -Or $IISVersion -match "IIS 8.5") {
            Import-Module WebAdministration
            # This sets the default logging fields for new sites
            Set-WebConfigurationProperty -Filter System.Applicationhost/Sites/SiteDefaults/logfile -Name LogExtFileFlags -Value $fields
            # This sets the logging fields for existing sites
            Get-ChildItem IIS:\Sites | ForEach-Object {
                $siteName = $_.Name
                $site = Get-ItemProperty "IIS:\Sites\$siteName"
                $site.logFile.logExtFileFlags = $fields
                $site | Set-Item
            }
            Get-ChildItem C:\inetpub\logs\LogFiles -ErrorAction SilentlyContinue |  Where-Object {$_.Name -match "W3SVC"} | ForEach-Object { 
                $SiteID = $_.Name.Replace("W3SVC","") -creplace '[^0-9]', ""
                $site = "W3SVC" + $SiteID
                $script:conf += '    
    <Input ' + $site + '>
    Module    im_file
    File	"C:\\inetpub\\logs\\logfiles\\W3SVC' + $SiteID + '\\u_ex*""
    SavePos  TRUE
 
    Exec if $raw_event =~ /^#/ drop();				\
       else							\
       {							\
        w3c->parse_csv();					\
        $EventTime = parsedate($date + " " + $time);	\
        $raw_event = to_json();				\
       }
    </Input>

    <Route ' + $site + '>
	    Path		' + $site + ' => iis_out
    </Route>
    '
            }
        }
    }
}
