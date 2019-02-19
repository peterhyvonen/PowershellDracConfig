#cases IP, Reservation, Update
#Need to make Runspace and add Try/Catch
Function GetDHCPScopes {
Param ( )
    $scopes = Get-DhcpServerv4Scope
    return $scopes
}

Function Scan4Lease {
Param ( )
    $scopes = GetDHCPScopes
    foreach ($scope in $scopes) {
        $leases = Get-DhcpServerv4Lease -ScopeId $scope.ScopeId
        [IPAddress]$currentscope = $scope.ScopeID
        foreach ($lease in $leases) {
        $reservation = Get-DhcpServerv4Reservation -IPAddress $lease.IPAddress
        $result4name =  $reservation.Name.CompareTo($lease.HostName)
        $result4mac = $reservation.ClientId.CompareTo($lease.ClientId)
        $ip = $lease.IPAddress
            if ($result4name -eq 0 -and $result4mac -eq 0) {
                write-host "reservation found comparing $ip"
                UpdateReservation $currentscope $ip
            }
            else {
                write-host "reservation not found adding $ip"
                $ip = $lease.IPAddress
                AddReservation $currentscope $ip
            } 
        }
    }
}

Function Scan4IP {
Param ( )
    #Need to handle non /24 subnet masks
    $scopes = GetDHCPScopes
    foreach ($scope in $scopes) {
        $scope.ScopeID
        [IPAddress]$currentscope = $scope.ScopeID
        [string]$stringscope = $currentscope.ToString()
        $stringscope = $stringscope.TrimEnd(".0")
        $pingresults = 1..254 | % {"$stringscope.$($_): $(Test-Connection -count 1 -comp "$stringscope.$($_)" -quiet)"}
        $pingresults
        foreach ($pingresult in $pingresults) {
            write-host "$pingresult"
            if ($pingresult -like "*True*") {
                [string]$ip = $pingresult.Replace(": True", "")
                $ip
                #Look for Reservation
                if (Get-DhcpServerv4Lease -IPAddress $ip) {
                    write-host "reservation found comparing $ip"
                    UpdateReservation $currentscope $ip
                }
                else {
                    write-host "reservation not found adding $ip"
                    AddReservation $currentscope $ip
            }
        }
    }
}
}

Function AddReservation {
Param ($currentscope,$ip)
    #Need to add if DRAC Fails
    $dracresults = GetDRACInfo ($ip)
    if ($dracresults -like "RAC Information*") {
            $dracresults
            foreach ($dracresult in $dracresults) {  
                    if ($dracresult -like "MAC Address*") {
                        $mac = $dracresult
                        $mac = $mac -replace ".*= " 
                        $mac = $mac.Replace(":","")
                        $mac = $mac.Substring(0,12)
                        $mac = $mac.ToLower()
                    }
                    if ($dracresult -like "DNS RAC Name*") {
                        $name = $dracresult
                        $name = $name -replace ".*= "
                    }
                    if ($dracresult -like "DHCP Enabled*") {
                         $dhcp = $dracresult
                         if ($dhcp -like "*0") {
                            $state = "static"
                         }                           
                         if ($dhcp -like "*1") {
                            $state = "dhcp"
                         }                       

                    }
                    if ($dracresult -like "Service Tag*") {
                        $tag = $dracresult
                        $tag = $tag -replace ".*= "
                    }
                    
                    else {
                        #do nothing
                    }                
            }
            Write-Host "Adding $ip to $currentscope"
            Add-DhcpServerv4Reservation -ScopeID $currentscope -IPAddress $ip -ClientID $mac -Description "$tag $state" -Name $name
        }
        else {
            Write-Host "Drac not found"
        }

      }




Function UpdateReservation {
Param ($currentscope,$ip)
    $dracinfo = GetDRACInfo ($ip)
    if ($dracresults -like "RAC Information*") {
        $dracresults
        foreach ($dracresult in $dracresults) {  
            if ($dracresult -like "MAC Address*") {
                $mac = $dracresult
                $mac = $mac -replace ".*= " 
                $mac = $mac.Replace(":","")
                $mac = $mac.Substring(0,12)
                $mac = $mac.ToLower()
                }
                if ($dracresult -like "DNS RAC Name*") {
                    $name = $dracresult
                    $name = $name -replace ".*= "
                }
                if ($dracresult -like "DHCP Enabled*") {
                    $dhcp = $dracresult
                    if ($dhcp -like "*0") {
                        $state = "static"
                    }                           
                    if ($dhcp -like "*1") {
                        $state = "dhcp"
                    }                       
                }
                    if ($dracresult -like "Service Tag*") {
                        $tag = $dracresult
                        $tag = $tag -replace ".*= "
                    }
                    
                    else {
                        #do nothing
                    }                
            }
        }
    $reservation = Get-DHCPServerv4Reservation -IPAddress $ip 
    $description = "$tag $state"
    $bool0 = $reservation.ClientId.CompareTo($mac)
    write-host "Macs match $bool0"
    $bool1 = $reservation.Description.CompareTo($description)
    write-host "Description match $bool1"
    #Write-Host "Updating $ip om $currentscope"
    #Set-DhcpServerv4Reservation -ScopeID $currentscope -IPAddress $ip -ClientID $mac -Description "$tag $state" -Name $name
}

Function GetDRACInfo {
Param ($ip)
    #Need to make password secure
    #query drac
    $SwitchLogon = "root"
    $SecureStringAsPlainText = ""
    $SwitchCliCommand = "C:\Temp\idrac-command.txt"
    $path = "C:\Program Files (x86)\PuTTY\plink.exe"
    #$SecureStringAsPlainText = $SecurePassword | ConvertFrom-SecureString
    $dracresults = echo y | & $path -l $SwitchLogon  -pw $SecureStringAsPlainText  -m $SwitchCliCommand $_ $ip
       
        return ($dracresults)
}

#Start of Script
Scan4Lease
Scan4IP
