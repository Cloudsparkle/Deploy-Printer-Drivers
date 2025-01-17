$PSVersion = $PSVersionTable.PSVersion.Major
if ($PSVersion -lt 3)
	{
   write-error "Powershell Version 3 or higher not dectected"
   exit 1
	}
$printers = import-csv $PSScriptRoot“\deploydriver.csv”
ForEach ($printer in $printers)
{
$inffile = $($printer.Inffile)
$infmodel = $($printer.Infmodel)
}
$paramstring = ""
$paramstring += '/f "'+$PSScriptroot+"\"+$inffile+'" /h x64 /ia /m "'+$infmodel+'" /q'
$deploystring = "printui.exe "+$paramstring
Invoke-Expression $deploystring
