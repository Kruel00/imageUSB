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

$ListDisk = Get-disk | Sort-Object -Property Number

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
$ComboBox1.Items.AddRange($ListDisk.FriendlyName)
$ComboBox1.Location = New-Object Drawing.Point 15,30
$combobox1.Width = 300
$Combobox1.SelectedIndex = 1
$form.Controls.add($Combobox1)

$boton2.Add_Click({
$form.Close()
})

$boton1.add_Click({

    $Label.Text = $Combobox1.SelectedIndex.ToString()
})

$Form.ShowDialog()


