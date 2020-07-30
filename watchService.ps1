Add-Type -AssemblyName System.Web
#The localHost
$localHost = $env:computername

# start the following Windows service:
$serviceName = 'cbdhsvc_3c8994f';

#How often shoud the skript try to start the service
$tries = 3
$countTries = 2
$sleepTime = 30

#Url
$backEnd = 'https://myBackend.com/log'
$hn = '?hostName=' + [System.Web.HttpUtility]::UrlEncode($localHost)
$sn = '&serviceName=' + [System.Web.HttpUtility]::UrlEncode($serviceName)
$starting = '&status=startin'
$running = '&status=running'
$stopped = '&status=-stopped'
$alert = '$status=alert'

$service = Get-Service -Name $serviceName
write-host 'watch service' $serviceName
while (($service.Status -ne 'Running') -and ($countTries -lt $tries))
{
    $url = $backEnd + $hn + $sn + $stopped
    Invoke-WebRequest -URI $url
    Start-Service $serviceName
    write-host $service.status
    write-host '(' $countTries ')' 'Try starting service: ' $serviceName
    $url = $backEnd + $hn + $sn + $starting
    Invoke-WebRequest -URI $url
    Start-Sleep -seconds $sleepTime
    $service.Refresh()
    if ($service.Status -ne 'Running')
    {
        $countTries = $countTries + 1
    }
}

if ($countTries -eq $tries)
{
    #Alert - Can't restart service.
    $url = $backEnd + $hn + $sn + $alert
    Invoke-WebRequest -URI $url
} else {
    #Service is running
    $url = $backEnd + $hn + $sn + $running
    Invoke-WebRequest -URI $url
}