param([switch]$Elevated)

function Test-Admin { 
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent()) 
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)          }

    if ((Test-Admin) -eq $false) {
         if ($elevated) 
            { } 
         else { 
            Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))

              } 
    exit } 
$ver = '1.0'

function GetPEFiles
    { 
        Start-BitsTransfer -Source $($_FilesPackage) -Destination $_WorkingDirectory\Files.zip -TransferType Download -Description "Transfiriendo Archivos"
        Expand-Archive -LiteralPath $_WorkingDirectory\Files.zip -DestinationPath $_WorkingDirectory
        Remove-Item $_WorkingDirectory\Files.zip
    }

$_WorkingDirectory = "C:\Valutech\USBPrepare\"
$_FilesPackage = "\\b1fs\Shared\ITSupport\Disk Cloning\USBCreate\PEFiles.zip"

if(Test-Path "C:\valutech\USBPrepare\")
{
    $_CheckFiles = Get-ChildItem $_WorkingDirectory -Recurse

    if (!$_CheckFiles.Count -ge 1559)
    {
        Remove-Item $_WorkingDirectory -Recurse -Confirm:$false
        GetPEFiles
    }
}
else
{
    New-Item $_WorkingDirectory -itemtype directory
    GetPEFiles
}

$_WorkingDirectory = "C:\Valutech\USBPrepare"
if(Test-Path $_WorkingDirectory) {
        Write-host "Si Existe"
    }
   else {
        Write-host "No Existe"
    }

class UsbDisks
{
    $DiskNumber
    $index
    $FriendlyName
    $capacidad
}

$DiskIndex = 0 
$Disks = get-disk
$UsbDisks = New-Object System.Collections.ArrayList


foreach($Disk in $Disks)
{
    if($Disk.BusType -eq "USB")
    {
        $capacidadS = [Math]::Round($Disk.Size * .00000000099) + 1
        $UsbDisk = New-Object -TypeName UsbDisks
        $UsbDisk.Index = $DiskIndex
        $UsbDisk.DiskNumber = $Disk.DiskNumber
        $UsbDisk.capacidad = $capacidadS.ToString() + "GB"
        $UsbDisk.FriendlyName = $Disk.FriendlyName + " -- " + $UsbDisk.capacidad
        $UsbDisks.add($UsbDisk)
        $DiskIndex ++
    }
}

Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form
$Form.Font = $Font
$Form.Text = 'USB Imagen ' + $ver
$Form.Width = 350
$Form.Height = 150

#Controls
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Seleccione unidad:"
$label.Location = New-Object Drawing.Point 30,10
$Label.AutoSize = $True
$Form.Controls.Add($Label)

$boton1 = New-Object System.Windows.Forms.Button
$boton1.Text = "OK"
$boton1.Location = New-Object Drawing.Point 50,60
$boton1.Width = 100
$form.Controls.add($boton1)


$boton2 = New-Object System.Windows.Forms.Button
$boton2.Text = "Cancel"
$boton2.Location = New-Object Drawing.Point 180,60
$boton2.Width = 100
$form.Controls.add($boton2)

$ComboBox1 = New-Object System.Windows.Forms.ComboBox
$ComboBox1.Items.AddRange($UsbDisks.FriendlyName)
$ComboBox1.Location = New-Object Drawing.Point 15,30
$combobox1.Width = 300
$Combobox1.SelectedIndex = 0
$form.Controls.add($Combobox1)

$boton2.Add_Click({
$form.Close()
})

$boton1.add_Click({
    Get-Disk
    $SelectedDisk =  $UsbDisks[$combobox1.SelectedIndex].Disknumber
    
    Write-host "Disco seleccionado: " $SelectedDisk
    Get-Disk $SelectedDisk | Clear-Disk -removedata -Confirm:$false
    New-Partition -DiskNumber $SelectedDisk -Size 1000MB -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel WinPE
    New-Partition -DiskNumber $SelectedDisk -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel Archivos
    
    $WinPE = Get-WMIObject Win32_Volume | where{ $_.Label -eq 'WinPE'}
    $Argumentos = '/k ' + $($_WorkingDirectory +"Deployment Tools\DandISetEnv.bat") + " " + $WinPE.DriveLetter
    Start-Process -Wait -FilePath cmd -ArgumentList $Argumentos -PassThru
})

$Form.ShowDialog()





