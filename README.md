# NXLog-AutoConfig

This script is based on Justin Henderson's [NXLog-AutoConfig](https://github.com/SMAPPER/NXLog-AutoConfig) repo.

With no customisation, the script will install Sysmon with the [SwiftOnSecurity](https://github.com/SwiftOnSecurity/sysmon-config) config, generate a NXLog config to start pulling the Sysmon and Windows Security events.

If the script detects certain processes/services running, it will run additional modules to extend the NXLog config (currently IIS Web logs, Windows DNS and Windows DHCP).

## Setup

1. Clone the repo into the root of a web server that can be contacted by the endpoints you want to enroll into monitoring.

```
git clone https://github.com/svch0stz/NXLog-AutoConfig
```
2. Customise the variables in the headers of  `nxlog_master.ps1`:

```
Param (
  [string]$Version = "1.0",
  [string]$WebHost = "webhost.domain.com" # << REPLACE HERE
  [string]$MSILocation = "http://$WebHost/NXLog-AutoConfig/nxlog.msi",
  [string]$script:webFileLocation = "http://$WebHost/NXLog-AutoConfig",
  [string]$script:logcollector = "logger.domain.com", # << REPLACE HERE
  [string]$script:scriptPath = "C:\Temp\nxlog"
)
```
3. Download the required binaries using:
```
cd NXLog-AutoConfig
./download_binaries.ps1
```
Or manually download the following into the directories displayed below:

- autorunsc.exe (Autoruns CLI 32bit: https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns)
- autorunsc64.exe (Autoruns CLI 64bit: https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns)
- sha1deep.exe (SHA1Deep 32bit: https://github.com/jessek/hashdeep)
- sha1deep64.exe (SHA1Deep 64bit: https://github.com/jessek/hashdeep)
- sysmon.exe (Sysmon 32bit: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- sysmon64.exe (Sysmon 64bit: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- sysmon.xml (Swift on Security Sysmon Config: https://github.com/SwiftOnSecurity/sysmon-config)
- nxlog.msi (NXLog Community Edition: https://nxlog.co/products/nxlog-community-edition/download)
- iis7psprov_x86.msi (IIS powershell Snap-in 32bit)
- iis7psprov_x64.msi (IIS powershell Snap-in 64bit)

#### Target Folder Structure Setup
```
NXLog-AutoConfig/
│   download_binaries.ps1
│   LICENSE
│   nxlog.msi
│   nxlog_master.ps1
│   README.md
│
├───binaries
│       autorunsc.exe
│       autorunsc64.exe
│       bin.txt
│       iis7psprov_x64.msi
│       iis7psprov_x86.msi
│       sha1deep.exe
│       sha1deep64.exe
│       sysmon.exe
│       sysmon.xml
│       sysmon64.exe
│
└───modules
        Autoruns.ps1
        DHCP.ps1
        DNS.ps1
        Firewall.ps1
        IIS.ps1
        mcafee.ps1
        module.txt
        NXLog.ps1
        Sysmon.ps1
        Windows.ps1
```

## Start Enrolling

Run the following on the target host in PowerShell to start sending logs:
```
IEX (New-Object Net.WebClient).DownloadString('http://webserver.domain.com/nxlog/nxlog_master.ps1');
```

## Notes and Tips

- If you run the script as part of a GPO or scheduled task, it will update the sysmon config and run Autorunsc again. 

- To not run certain modules (eg Autoruns), remove the entry in `modules/modules.txt` file.

- If you update a module, you will need to run sha1deep and update the hashfile list - `bin.txt` for the contents of `binaries/` and `modules.txt` for the contents of `modules/`.

#### TODO
- Set Windows auditing policies before sending Windows events
- Work on other modules
- Update hash files automatically (bin.txt and modules.txt)