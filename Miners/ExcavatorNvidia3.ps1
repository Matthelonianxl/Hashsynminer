﻿$Path = ".\Bin\Excavator3\excavator.exe"
$Uri = "https://github.com/nicehash/excavator/releases/download/v1.4.4a/excavator_v1.4.4a_NVIDIA_Win64.zip"

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$Port = 3456 + (3 * 10000)
$arrSniff = $SplitsniffCC3  -split ','

$Algorithms = [PSCustomObject]@{
    
    #NeoScrypt = 'neoscrypt'
   
}

$Optimizations = [PSCustomObject]@{
    
    NeoScrypt = ''
   
}

$Algorithms | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name | ForEach {
    if ((Test-Path (Split-Path $Path)) -and $Pools.$(Get-Algorithm $_).Host) {
		$obj = @()
        $obj += [PSCustomObject]@{time = 0; commands = @([PSCustomObject]@{id = 1; method = "algorithm.add"; params = @("$_".ToLower(), "$($Pools.$(Get-Algorithm $_).Host):$($Pools.$(Get-Algorithm $_).Port)", "$($Pools.$(Get-Algorithm $_).User3):$($Pools.$(Get-Algorithm $_).Pass3)")})}
		for ($i = 0; $i -lt $arrSniff.Count ; $i++) {
			$obj += [PSCustomObject]@{time = 3; commands = @([PSCustomObject]@{id = 1; method = "worker.add"; params = @("0", "$($arrSniff[$i])")})}
		}	
        $obj += [PSCustomObject]@{time = 10; loop = 10; commands = @([PSCustomObject]@{id = 1; method = "algorithm.print.speeds"; params = @("0")})} 
		$obj | ConvertTo-Json -Depth 10 | Set-Content "$(Split-Path $Path)\$($Pools.$(Get-Algorithm $_).Name)_$(Get-Algorithm $_)_$($Pools.$(Get-Algorithm $_).User3)_Nvidia.json" -Force -ErrorAction Stop
    }

    [PSCustomObject]@{
        Type = 'NVIDIA3'
        Path = $Path
        Arguments = "-p $Port -i 0.0.0.0 -c $($Pools.$(Get-Algorithm $_).Name)_$(Get-Algorithm $_)_$($Pools.$(Get-Algorithm $_).User3)_Nvidia.json -na"
        HashRates = [PSCustomObject]@{$(Get-Algorithm $_) = $Stats."$($Name)_$(Get-Algorithm $_)_HashRate".Day}
        API = 'NiceHash'
        Port = $Port
        Wrap = $false
        URI = $Uri
        PrerequisitePath = "$env:SystemRoot\System32\msvcr120.dll"
        PrerequisiteURI = "http://download.microsoft.com/download/2/E/6/2E61CFA4-993B-4DD4-91DA-3737CD5CD6E3/vcredist_x64.exe"
    }
}
