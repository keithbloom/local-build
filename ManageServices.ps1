param (
	[string]$action = $(throw "-action required: Stop, Start or ReCreate")
)
	
function DoStop([hashtable]$service) {	
	
	$serviceToStop = Get-Service $service.Name | Select -First 1

	if ($serviceToStop.Status -eq 'Running')
	{
		write-host "Stopping:" $serviceToStop.Name
		stop-service $serviceToStop -force
		$serviceToStop.WaitForStatus('Stopped')
	}
	
	
	Write-host $serviceToStop.Name " has stopped"

}

function DoStart([hashtable]$service){

	$serviceToStart = Get-Service $service.Name | Select -First 1
	if($serviceToStart.Status -eq 'Stopped')
	{
		write-host "Starting: " $serviceToStart.Name
		start-service $serviceToStart
		$serviceToStart.WaitForStatus('Running', '00:00:20')
	}
	
	Write-host $serviceToStart.Name " has started"
}

function Create() {

	param($serviceDetails)
	Write-host "Adding " $serviceDetails.Name " at " $serviceDetails.FileName
	new-service -name $serviceDetails.Name -binaryPathName $serviceDetails.FileName -displayName $serviceDetails.Name -StartupType Manual -Description $serviceDetails.Name
}

function CreateWithDependents() {

}

function CreateAll(){
	foreach($s in $serviceList){
		Create $s
	}
}

function DeleteAll() {
	foreach($s in $serviceList){
		sc.exe delete $s.Name
	}
}

function StopAll() {
	write-host ":: Stopping Services ::"
	$reversedList = $serviceList | sort-object -Descending
	foreach($s in $reversedList) {
	
		DoStop $s
	}
}

function StartAll(){
	foreach($s in $serviceList){
		DoStart $s
	}
}

$root = "C:\ICAP\2014-30-12\Altex"

$serviceList = @{Name="Altex Configuration Service";FileName="$root\Configuration_Service.exe"},
				@{Name="Altex Data Logger Service";FileName="$root\DataLogger.exe"},
				@{Name="Altex Authentication Service";FileName="$root\Authentication Service.exe"},
				@{Name="Altex TCP Service";FileName="$root\TCPMessageServer.exe"},
				@{Name="Altex Generic Matching Engine";FileName="$root\AltexGenericMatchingEngine.exe"},
				@{Name="Altex Generic Order Book";FileName="$root\AltexGenericMatching.exe"},
				@{Name="Altex GUIBOS Gateway (Main)";FileName="$root\AltexIrsGuibosGateway.exe"}
				

if($action -eq 'Show')	{
	write-host "Service details"
	foreach($s in $serviceList)
	{
	
		& sc.exe qc $s.Name
	}
}
	
if($action -eq 'ReCreate'){
	write-host ":: Recreating all services ::"
	StopAll
	DeleteAll
	CreateAll
	StartAll
}

if($action -eq 'Start') {
	StartAll
}

if($action -eq 'Stop') {
	StopAll
}

