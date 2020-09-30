Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "INF (*.inf)| *.inf"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

Function Get-Deployscript
{
$psfile = $csvpath + "\PrintDriverDeploy.ps1"
'$PSVersion = $PSVersionTable.PSVersion.Major' | out-file -filepath $psfile
'if ($PSVersion -lt 3)' | out-file -filepath $psfile -Append
'	{' | out-file -filepath $psfile -Append
'   write-error "Powershell Version 3 or higher not dectected"' | out-file -filepath $psfile -Append
'   exit 1' | out-file -filepath $psfile -Append
'	}' | out-file -filepath $psfile -Append
'$printers = import-csv $PSScriptRoot“\deploydriver.csv”' | out-file -filepath $psfile -Append
'ForEach ($printer in $printers)' | out-file -filepath $psfile -Append
'{' | out-file -filepath $psfile -Append
'$inffile = $($printer.Inffile)' | out-file -filepath $psfile -Append
'$infmodel = $($printer.Infmodel)' | out-file -filepath $psfile -Append
'}' | out-file -filepath $psfile -Append
'$paramstring = ""' | out-file -filepath $psfile -Append

$lijn = '$paramstring += ''/f "''+$PSScriptroot+"\"+$inffile+''" /h x64 /ia /m "'+"'"+'+'+'$infmodel'+'+'+"'"+'" /q'''
$lijn | out-file -filepath $psfile -Append

'$deploystring = "printui.exe "+$paramstring' | out-file -filepath $psfile -Append
'Invoke-Expression $deploystring' | out-file -filepath $psfile -Append
}

$inputfile = Get-FileName "C:\temp"

#Specific test for Ricoh
$modelarray = get-content -path $inputfile | where-object {$_ -like '*DrvName*=*"*'} | %{$_.split('"')[1]}

if ($null -eq $modelarray)
{
$modelarray = get-content -path $inputfile | where-object {$_ -like '*"*=*'} | %{$_.split('"')[1]}
}

if ($null -eq $modelarray)
{
Add-Type -AssemblyName PresentationCore,PresentationFramework
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Error
$MessageBody = "Error processing INF file"
$MessageTitle = "Error"
 
$Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
Return
}

$printermodel = $modelarray | Select-Object -Unique | out-gridview -outputmode single -Title "Select Printer Model..."
$printerfile = split-path -leaf $inputfile
$csvpath = split-path -Path $inputfile

$csvContents = @() # Create the empty array that will eventually be the CSV file

$row = New-Object System.Object # Create an object to append to the array
$row | Add-Member -MemberType NoteProperty -Name "Inffile" -Value $printerfile
$row | Add-Member -MemberType NoteProperty -Name "InfModel" -Value $printermodel

$csvContents += $row # append the new data to the array#
$csvfile = $csvpath + "\deploydriver.csv"

$csvContents | Export-CSV -path $csvfile -NoTypeInformation

Get-Deployscript