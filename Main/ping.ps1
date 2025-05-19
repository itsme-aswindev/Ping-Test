$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$serversFile = Join-Path $scriptPath "servers.txt"
$reportFile = Join-Path $scriptPath "ping.html"

function Get-ServerStats {
    param ($server)

    $result = @{
        Server   = $server
        Status   = "Offline"
        CPU      = "-"
        Memory   = "-"
        Uptime   = "-"
        DriveC   = "-"
    }

    if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
        $result.Status = "Online"

        try {
            $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server
            $cpu = Get-WmiObject -Class Win32_Processor -ComputerName $server | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
            $uptime = (Get-Date) - $os.ConvertToDateTime($os.LastBootUpTime)
            $uptimeDays = [math]::Round($uptime.TotalDays, 1)

            $totalMem = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
            $freeMem = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
            $usedMemPct = [math]::Round((($totalMem - $freeMem) / $totalMem) * 100, 2)

            $drive = Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='C:'"
            $usedDrivePct = if ($drive) {
                [math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 2)
            } else {
                "-"
            }

            $result.CPU = $cpu
            $result.Memory = $usedMemPct
            $result.Uptime = $uptimeDays
            $result.DriveC = $usedDrivePct
        } catch {
            $result.Status = "Error"
        }
    }

    return $result
}

function Get-Color {
    param ($value, $warn, $crit)

    if ($value -eq "-") { return "black" }
    elseif ($value -ge $crit) { return "red" }
    elseif ($value -ge $warn) { return "orange" }
    else { return "black" }
}

function Generate-HTML {
    $servers = Get-Content -Path $serversFile
    $results = @()

    foreach ($server in $servers) {
        $results += Get-ServerStats -server $server
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $html = @"
<html>
<head>
    <title>Server Health Report</title>
    <style>
        body { font-family: Arial; background-color: #f9f9f9; color: #333 }
        table { border-collapse: collapse; width: 100%; margin-top: 20px }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center }
        th { background-color: #333; color: white }
    </style>
</head>
<body>
    <h2>Server Health Report</h2>
    <p>Last Updated: $timestamp</p>
    <table>
        <tr>
            <th>Server</th>
            <th>Status</th>
            <th>CPU (%)</th>
            <th>Memory (%)</th>
            <th>Drive C: (%)</th>
            <th>Uptime (days)</th>
        </tr>
"@

    foreach ($r in $results) {
        $cpuColor = Get-Color $r.CPU 70 90
        $memColor = Get-Color $r.Memory 70 90
        $driveColor = Get-Color $r.DriveC 80 95

        $html += "<tr>"
        $html += "<td>$($r.Server)</td>"
        $html += "<td>$($r.Status)</td>"
        $html += "<td style='color:$cpuColor'>$($r.CPU)</td>"
        $html += "<td style='color:$memColor'>$($r.Memory)</td>"
        $html += "<td style='color:$driveColor'>$($r.DriveC)</td>"
        $html += "<td>$($r.Uptime)</td>"
        $html += "</tr>"
    }

    $html += @"
    </table>
</body>
</html>
"@

    $html | Out-File -FilePath $reportFile -Encoding UTF8
}

# Initial generation
Generate-HTML

# Auto-loop every 5 minutes
while ($true) {
    Start-Sleep -Seconds 300
    Generate-HTML
}
