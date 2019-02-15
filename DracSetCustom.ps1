Function SetDRACInfo {
Param ($netname, $SecurePassword)
    #Need to make password secure
    #query drac
    $SwitchLogon = "root"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $SecureStringAsPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $SwitchCliCommand = "C:\Temp\idrac-command.txt"
    $SwitchCliCommand2 = "C:\Temp\idrac-setjob4reboot.txt"
    $path = "C:\Program Files (x86)\PuTTY\plink.exe"
    echo y | & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand $_ $netname
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand2 $_ $netname   
        return ($netname)
}

Function SetHardReset {
Param ($netname, $SecurePassword)
    #Need to make password secure
    #query drac
    $SwitchLogon = "root"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $SecureStringAsPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $SwitchCliCommand = "C:\Temp\idrac-command.txt" #racadm racreset hard
    $path = "C:\Program Files (x86)\PuTTY\plink.exe"
    echo y | & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand $_ $netname   
        return ($netname)
}

Function SetVirtualDisk{
Param ($netname, $SecurePassword)
    #Need to make password secure
    #query drac
    $SwitchLogon = "root"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $SecureStringAsPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $SwitchCliCommand1 = "C:\Temp\idrac-vdisk.txt" #racadm raid get vdisks
    $SwitchCliCommand2 = "C:\Temp\idrac-createvd.txt" #racadm raid createvd:RAID.Integrated.1-1 -rl r1 -pdkey:Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1,Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1
    $SwitchCliCommand3 = "C:\Temp\idrac-setraidjob.txt" #racadm jobqueue create RAID.Integrated.1-1
    $SwitchCliCommand4 = "C:\Temp\idrac-reboot.txt" #racadm serveraction hardreset
    $path = "C:\Program Files (x86)\PuTTY\plink.exe"
    echo y | & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand2 $_ $netname
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand3 $_ $netname  
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand4 $_ $netname 
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand1 $_ $netname  
        return ($netname)
}

Function SetVideo {
Param ($netname, $SecurePassword)
    #Need to make password secure
    #query drac
    $SwitchLogon = "root"
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $SecureStringAsPlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    $SwitchCliCommand1 = "C:\Temp\idrac-setvideo.txt" #racadm set bios.integrateddevices.embvideo Enabled
    $SwitchCliCommand2 = "C:\Temp\idrac-setbiosjob.txt" #racadm jobqueue create BIOS.Setup.1-1
    $SwitchCliCommand3 = "C:\Temp\idrac-reboot.txt" #racadm serveraction hardreset
    $path = "C:\Program Files (x86)\PuTTY\plink.exe"
    echo y | & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand1 $_ $netname
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand2 $_ $netname  
    & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand3 $_ $netname 
        return ($netname)
}

Function GetDracSettings {

}

Function OpenFile {
    $netnames = Get-Content "C:\temp\netnames.txt"
    $SecurePassword = Read-Host 'password' -AsSecureString
    foreach ($netname in $netnames) {
       SetDRACInfo $netname $SecurePassword    
    }
}

OpenFile