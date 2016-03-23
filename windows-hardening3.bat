@echo off

cd /D %~dp0

::goto win7-svr08
ver | FIND "5.2.3790" && goto xp-srv03
ver | FIND "6.1.76" && goto win7-svr08
echo "Could not determine windows version" & goto end


::###################################################
:xp-srv03
:: Automatic script to disable useless crap under winXP/Srv2003

set xp=Alerter ClipSrv BITS Dfs TrkSrv Fax MSFtpsvc^
		helpsvc ImapiService Nla NntpSvc SysmonLog WmdmPmSN^
		Spooler RasAuto RasMan RDSessMgr RemoteRegistry SCardSvr^
		SNMP SNMPTRAP sacsvr TapiSvr TlntSvr Themes UPS^
		AudioSrv stisvc WZCSVC

		
		
for %%b in (%xp%) do (
	echo %%b
	net stop %%b || echo "failed to stop %%b" >> %~dp0\hardening-log.txt
	sc config "%%b" start= disabled || echo "failed to disable %%a" >> %~dp0\hardening-log.txt
)


goto end



::#############################################################
:: Automatic script to disable useless crap on windows 7/srv 2008
:win7-svr08


::Names of services to stop

set win7tcp=135 445 137

set win7upd=137 138

set win7=SensrSvc BITS wbengine bthserv PeerDistSvc defragsvc Fax^
		fdPHost FDResPub HomeGroupListener HomeGroupProvider SharedAccess^
		lltdsvc Mcx2Svc MSiSCSI MMCSS NetTcpPortSharing napagent WPCSvc^
		PNRPsvc p2psvc p2pimsvc PNRPAutoReg Spooler QWAVE RasAuto RasMan^
		SessionEnv TermService UmRdpService rpcapd RemoteRegistry RemoteAccess^
		ShellHWDetection SCardSvr SCPolicySvc sppuinotify SSDPSRV^
		TabletInputService TapiSrv Themes TPAutoConnSvc TPVCGateway^
		AudioSrv AudioEndpointBuilder WbioSrvc idsvc 
		

for %%a in (%win7%) do (
	echo %%a
	net stop %%a || echo "failed to stop %%a" >> %~dp0\hardening-log.txt
	sc config "%%a" start= disabled || echo "failed to disable %%a" >> %~dp0\hardening-log.txt
)

:: Block TCP Ports
for %%t in (%win7tcp%) do (
	echo %%t
	netsh advfirewall firewall add rule name="%%t" protocol=TCP dir=out remoteport=%%t action=block
	netsh advfirewall firewall add rule name="%%t" protocol=TCP dir=in localport=%%t action=block
	echo "Added FIrewall rule for port %%t" >> %~dp0\hardening-log.txt
)

:: Block UDP Ports
for %%u in (%win7udp%) do (
	echo %%t
	netsh advfirewall firewall add rule name="%%u" protocol=UDP dir=out remoteport=%%t action=block
	netsh advfirewall firewall add rule name="%%u" protocol=UDP dir=in localport=%%t action=block
	echo "Added FIrewall rule for port %%u" >> %~dp0\hardening-log.txt
)



goto end



::###############################################################
:end
pause

