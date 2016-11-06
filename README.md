# NXLog-AutoConfig
NXLog autoconfig is a framework for automatically managing and configuring the NXLog agent.  It is designed as a functional proof of concept to automatically enable and configure logging on production systems.

To use this you will need a web server such as apache that you place all the files on.  Then with group policy create a scheduled task to run nxlog_master.ps1 once a day preferrably after hours.

Currently the binaries and installer folder are empty due to Microsoft not allowing redistribution of their free binaries.  I will be creating scripts in the future that can be ran to perform the initial setup.

You will need to find and download the following files into the binaries folder:

autorunsc.exe
dnscmd.exe
iis7psprov_x64.msi
iis7psprov_x86.msi
sha1deep.exe
sha1deep64.exe
Sysmon.exe
sysmon.xml

You will also need to download the latest edition of NXLog CE and place it into installers
