$ImageFiles = Get-WMIObject Win32_Volume | where{ $_.Name -eq 'T:\'}
$ImageFiles.DriveLetter = $null
$ImageFiles.Put()

Get-Disk 5 | Clear-Disk -removedata -Confirm:$false
New-Partition -DiskNumber 5 -Size 1000MB | Format-Volume -FileSystem FAT32 -NewFileSystemLabel WinPE
Get-Partition -DiskNumber 5 -PartitionNumber 1 | Set-Partition -NewDriveLetter T
New-Partition -DiskNumber 5 -UseMaximumSize | Format-Volume -FileSystem FAT32 -NewFileSystemLabel Archivos
Get-Partition -DiskNumber 5 -PartitionNumber 2 | Set-Partition -NewDriveLetter S


New-Partition -DiskNumber 5 -Size -UseMaximumSize -DriveLetter T| Format-Volume -FileSystem NTFS -NewFileSystemLabel Archivos



Get-Volume -DriveLetter W | Get-Partition 1 | Remove-PartitionAccessPath -AccessPath S:\

Get-Partition -DiskNumber 5 -PartitionNumber 1 | Set-Partition -NewDriveLetter T

Get-WMIObject Win32_Volume

$WinPE = Get-WMIObject Win32_Volume | where{ $_.Name -eq 'S:\'}
$WinPE.DriveLetter = $null
$WinPE.Put()

$ImageFiles = Get-WMIObject Win32_Volume | where{ $_.Name -eq 'T:\'}
$ImageFiles.DriveLetter = $null
$ImageFiles.Put()


$Drive = Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter = 'T:'"
$Drive | Select-Object -Property SystemName, Label, DriveLetter



$Drive = Get-CimInstance -ClassName Win32_Volume
$Drive | Format-Table *


$Drive = Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter = 'X:'"
$Drive | Set-CimInstance -Property @{DriveLetter = 'M:'; Label = 'GD Master'}

Start-Process -Wait -FilePath 'C:\"Program Files (x86)"\"Windows Kits"\10\"Assessment and Deployment Kit"\"Deployment Tools"\DandISetEnv.bat' -ArgumentList /q -PassThru
