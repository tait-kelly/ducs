reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 00000001 /f
netsh advFirewall firewall add rule name="SJU1" dir=in action=allow remoteip=any protocol=TCP profile=private,domain localport=135,445
netsh advFirewall firewall add rule name="SJU2" dir=in action=allow remoteip=any protocol=UDP profile=private,domain localport=137
netsh advFirewall firewall add rule name="SJU3" dir=in action=allow remoteip=any protocol=icmpv4 profile=private,domain 
netsh advFirewall firewall set rule group="Windows Remote Management" new enable=yes
netsh advFirewall firewall set rule group="Windows Remote Management (Compatibility)" new enable=yes
netsh advFirewall firewall set rule group="Windows Management Instructions (WMI)" new enable=yes
netsh advfirewall firewall set rule group="remote administration" new enable=yes
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v forceguest /t REG_DWORD /d 00000000 /f

