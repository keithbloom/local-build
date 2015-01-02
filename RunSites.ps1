$tool="C:\Program Files\IIS Express\iisexpress.exe"
$cmdLine = "/apppool:'Clr4IntegratedAppPool'"

[xml]$sites = Get-Content ~\Documents\IISExpress\config\applicationhost.config
[array]$siteNames = $sites.configuration | Select-Xml -XPath "//site[contains(@name, 'WCF')]" | % {$_.Node.Name}

foreach($siteName in $siteNames) 
{
	$CommandLine = "$cmdLine /site:$siteName"
	Write-Host $CommandLine
	
	Start-Process $tool -ArgumentList $CommandLine 
}
