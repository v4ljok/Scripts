function Get-Distance {
    param (
        [double]$latitude1, [double]$longitude1,
        [double]$latitude2, [double]$longitude2
    )

    $earthRadius = 6371 
    $deltaLatitude = ($latitude2 - $latitude1) * [Math]::PI / 180
    $deltaLongitude = ($longitude2 - $longitude1) * [Math]::PI / 180
    $a = [Math]::Sin($deltaLatitude/2) * [Math]::Sin($deltaLatitude/2) +
         [Math]::Cos($latitude1 * [Math]::PI / 180) * [Math]::Cos($latitude2 * [Math]::PI / 180) *
         [Math]::Sin($deltaLongitude/2) * [Math]::Sin($deltaLongitude/2)
    $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1-$a))
    return $earthRadius * $c 
}

$busStops = Import-Csv -Path './stops.txt'

$stopNameInput = Read-Host "Enter the name of the bus stop"
$searchRadiusInput = [double](Read-Host "Enter the search radius in kilometers")

$matchingBusStops = $busStops | Where-Object { $_.stop_name -eq $stopNameInput }

if ($matchingBusStops.Count -eq 0) {
    Write-Host "No matching bus stops found for the name $stopNameInput."
    return
}

if ($matchingBusStops.Count -gt 1) {
    Write-Host "Multiple bus stops found for the name $stopNameInput. Please choose a stop:"
    $matchingBusStops | ForEach-Object { Write-Host "Area: $($_.stop_area), Stop ID: $($_.stop_id)" }
    $selectedStopIdInput = Read-Host "Enter the stop ID of the desired stop"
    $selectedBusStop = ($matchingBusStops | Where-Object { $_.stop_id -eq $selectedStopIdInput })[0]
} else {
    $selectedBusStop = $matchingBusStops[0]
}

$nearbyBusStops = $busStops | Where-Object {
    $distance = Get-Distance $selectedBusStop.stop_lat $selectedBusStop.stop_lon $_.stop_lat $_.stop_lon
    $distance -le $searchRadiusInput
} | Sort-Object { Get-Distance $selectedBusStop.stop_lat $selectedBusStop.stop_lon $_.stop_lat $_.stop_lon }

$nearbyBusStops | ForEach-Object {
    Write-Host "Bus Stop Name: $($_.stop_name), Area: $($_.stop_area), Distance: $($_.stop_lat) km"
}