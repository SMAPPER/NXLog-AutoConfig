# NXLog-AutoConfig
NXLog autoconfig is a framework for automatically managing and configuring the NXLog agent.  It is designed as a functional proof of concept to automatically enable and configure logging on production systems.

To use this you will need a web server such as apache that you place all the files on.  Then with group policy create a scheduled task to run nxlog_master.ps1 once a day preferrably after hours.
