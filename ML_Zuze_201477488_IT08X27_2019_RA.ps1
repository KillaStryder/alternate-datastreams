Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Alternate Data Stream Locator'
$main_form.Width = 850
$main_form.Height = 600
$main_form.AutoSize = $true
$main_form.StartPosition = 'CenterScreen'
$main_form.BackColor = '#9e9c96'
$path
$isCkecked = $true

$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Multiselect = $true
        Title = 'Select files to open' 
        SupportMultiDottedExtensions = $true 
     }
$saveFolder = New-Object System.Windows.Forms.saveFiledialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Filter = "Log Files|*.Log|Text File|*.txt| All Files| *.*"
        Title = 'Save As'
        ShowHelp = $true 
        
     }
    

$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.SelectedPath = "C:\"
$folderBrowser.ShowNewFolderButton = $false
$folderBrowser.Description = "Select a directory"



function Find-Folders {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $loop = $true
    while($loop)
    {
        if ($folderBrowser.ShowDialog() -eq "OK")
        {
            $txtLocation.Text = $folderBrowser.SelectedPath
            $btnLocate.Enabled = $true
            $loop = $false
            $path = $folderBrowser.SelectedPath
            Write-Host "Folder Selected " $isFolder
            $path = 1

        }else
        { 
            $path = 0
            return
        }
    }

}

$txtLocation = New-Object System.Windows.Forms.TextBox
$txtLocation.Location = New-Object System.Drawing.Point(220,40)
$txtLocation.Width = 300

$txtLocation.Add_Click(
{ 
   $txtLocation.Text = ''
   $msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to open a file or folder. Yes for file search. No for folder search?','ADS File Selection','YesNoCancel', 'Question')

  switch  ($msgBoxInput) 
  {

  'Yes' 
  {
    $path = 2
    $FileBrowser.ShowDialog()
    If($fileBrowser.FileNames -like "*\*")
    {  
        $txtLocation.Text = $fileBrowser.FileNames 
        $path = $fileBrowser.FileNames
        $btnLocate.Enabled = $true
        $path = 2

    }else
    {
        $txtLocation.Text = ''
        $btnLocate1.Enabled = $false
        $path = 0
    }

  }

  'No' 
  {
    $path = 1
    Find-Folders
    

  }

  'Cancel' {
    $btnLocate.Enabled = $false
    $path = 0
  }

  }
})

$lblLocation = New-Object System.Windows.Forms.Label
$lblLocation.Text = "Choose The file(s) you'd like to search"
$lblLocation.Location = New-Object System.Drawing.Point(20,40)
$lblLocation.AutoSize = $true

$chkData = New-Object System.Windows.Forms.CheckBox
$chkData.Location = New-Object System.Drawing.Point(540,35)
$chkData.Size = New-Object System.Drawing.Size(180,30)
$chkData.Text = "Include files with primary stream only"
$chkData.Checked = $true

$chkData.Add_CheckStateChanged(
{
  $isChecked = $chkData.Checked
  Write-Host "Is Checked" $isChecked  
})


$btnLocate = New-Object System.Windows.Forms.Button
$btnLocate.Enabled = $false
$btnLocate.Location = New-Object System.Drawing.Size(700,40)
$btnLocate.Size = New-Object System.Drawing.Size(120,25)
$btnLocate.Text = 'Locate'


$btnLocate.Add_Click(
{
    $lstFiles.Items.Clear()
    $main_form.Controls.Add($btnDelete)
    $main_form.Controls.Add($btnRemove)
    $main_form.Controls.Add($btnClear)
    $main_form.Controls.Add($btnSave)
    $main_form.Controls.Add($btnCopy)
    $main_form.Controls.Add($drpDelete)
    
    $lstFiles.Enabled = $true
    $btnClear.Enabled = $true
    $btnSave.Enabled = $true
    $btnCopy.Enabled = $false
    $btnDelete.Enabled = $false
    $btnRemove.Enabled = $false
    $iloop = 0
    switch ($txtLocation.Text)
    {
        $fileBrowser.FileNames
        {
            foreach($filePath in $fileBrowser.FileNames)
            {
                foreach($file in Get-Item -Path $filePath -Stream *)
                {
                    if($chkData.Checked -ne $true)
                    {
                        if($file.Stream -ne ':$DATA')
                        {
                            $lstFiles.Items.Add($file.FileName)
                            Write-Host $file
                            Write-Host "File" $file.FileName
                            $iloop += 1
                        }
                    }else
                    {
                        $lstFiles.Items.Add($file.FileName)
                        Write-Host $file
                        Write-Host "File" $file.FileName
                        $iloop += 1
                    } 
                }
            }
     
        }
        $folderBrowser.SelectedPath 
        {
            Write-Host $isFolder
            $filePath = $folderBrowser.SelectedPath + '*' 
            Write-Host "File Path = " $filePath
            foreach($file in Get-Item -Path $filePath -Stream *)
            {
                if($chkData.Checked -ne $true)
                {
                    if($file.Stream -ne ':$Data')
                    {
                        $lstFiles.Items.Add($file.FileName)
                        Write-Host $file
                        Write-Host "File" $file.FileName
                        $iloop += 1
                    }
                }else
                {
                    $lstFiles.Items.Add($file.FileName)
                    Write-Host $file
                    Write-Host "File" $file.FileName
                    $iloop += 1
                }
            
            }
      
        }
        
    }
    if($iloop -eq 0)
    {
        $lstFiles.Enabled = $false
        $lstFiles.Items.Add("No File(s) Available")
    }
    

})

$lstFiles = New-Object System.Windows.Forms.ListBox
$lstFiles.Location = New-Object System.Drawing.Point(450,70)
$lstFiles.Width = 350
$lstFiles.Height = 400
$lstFiles.Enabled = $false

$lstFiles.Add_Click(
{
    $i = 0
    Write-Host $lstFiles.SelectedItem.ToString()
    $streams = ''
    $streamInfo =''
    $displayInfo = Get-Item -Path $lstFiles.SelectedItem.ToString() -Stream *
    $drpDelete.Items.Clear()
    foreach($stream in $displayInfo.Stream)
    {
        
        $drpDelete.Items.Add($stream)
        Write-Host $stream
            if($stream -eq "zone.identifier")
            {
                $streamContent = Get-Content -Path $lstFiles.SelectedItem.ToString() -Stream zone.identifier
                Switch($streamContent.ZoneTransfer)
                {
                    0
                    {
                        
                        $streamInfo += " ZoneID: `r`n" + $streamContent + ": My Computer `r`n `r`n"
                    }
                    1
                    {
                        $streamInfo += " ZoneID: `r`n" + $streamContent + ": Local Intranet Zone `r`n `r`n"
                    }
                    2
                    {
                        $streamInfo += " ZoneID: `r`n" + $streamContent + ": Internet Zone `r`n `r`n"
                    }
                    3
                    {
                        $streamInfo += " ZoneID: `r`n" + $streamContent + ": Restricted Sites Zone `r`n `r`n"
                    }

                }

                $streamInfo +=  $stream + " Contents: `r`n" + $streamContent + "`r`n `r`n"
            }
            if($lstFiles.SelectedItem.ToString() -like "*/*.exe")
            {
                if($stream -eq "$DATA")
                {
                    $streamInfo +=  $stream + " Contents: `r`n Contains some execution code. Cannot view content `r`n `r`n"
                }
            }
            else
            {
                if($streamContent -ne "")
                {
                  $streamContent = Get-Content -Path $lstFiles.SelectedItem.ToString() -Stream $stream
                  $streamInfo +=  $stream + " Contents: `r`n" + $streamContent + "`r`n `r`n"
                }
                else
                {
                    $streamInfo +=  $stream + " Contents: `r`n This Stream is Empty"  + "`r`n `r`n"
                }

            }    
        
        if ($i -gt 0)
        {
            $streams += ", " + $stream
        }else
        {
            $streams = $stream
        }
        $i += 1
        Write-Host $i
             
    }
    if($i -eq 1)
    {
        $btnDelete.Enabled = $false
        $btnRemove.Enabled = $false
    }
    if($drpDelete.Text = "")
    {
        $btnDelete.Enabled = $false
        $btnRemove.Enabled = $false
    }
    
    $lblDisplay.Text += "`r`n `r`n" + "File Name: " + $displayInfo.FileName + "`n" + "Streams: " + $streams + "`n" + 'Length: ' + $displayInfo.Length + "`r`n"
    $lblDisplay.Text += $streamInfo + "--------------`r`n `r`n"
    
})

$lblDisplay = New-Object System.Windows.Forms.Label
$lblDisplay.Location = New-Object System.Drawing.Point(30,70)
$lblDisplay.Width = 400
$lblDisplay.Height = 400
$lblDisplay.BackColor = "#000000"
$lblDisplay.ForeColor = "#ffffff"
$lblDisplay.Text = "File Information:"

$drpDelete = New-Object System.Windows.Forms.ComboBox
$drpDelete.Location = New-Object System.Drawing.Size(470,470)
$drpDelete.Width = 300

$drpDelete.Add_SelectedIndexChanged(
{
    if($drpDelete.Text -ne "")
    {
        $btnDelete.Enabled = $true
        $btnRemove.Enabled = $true
        $btnCopy.Enabled = $true
    }
})

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Enabled = $false
$btnClear.Location = New-Object System.Drawing.Size(40,500)
$btnClear.Size = New-Object System.Drawing.Size(120,25)
$btnClear.Text = 'Clear'
$btnClear.Add_Click(
{
    $lblDisplay.Text = "File Information:"
})

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Enabled = $false
$btnSave.Location = New-Object System.Drawing.Size(300,500)
$btnSave.Size = New-Object System.Drawing.Size(120,25)
$btnSave.Text = 'Save'

$btnSave.Add_Click(
{
   $saveFolder.ShowDialog()
   $info = "File Creation: " + (Get-Date).ToString() + "`r`n `r`n" + $lblDisplay.Text
   New-Item -ItemType 'file' -Path $saveFolder.FileName -Value $info -Force
})

$btnDelete = New-Object System.Windows.Forms.Button
$btnDelete.Enabled = $false
$btnDelete.Location = New-Object System.Drawing.Size(450,500)
$btnDelete.Size = New-Object System.Drawing.Size(120,25)
$btnDelete.Text = 'Clear Stream'
$btnDelete.Add_Click(
{
    if($drpDelete.Text -ne '')
    {
        $streamName = $drpDelete.Text
        $msgBoxInput =  [System.Windows.MessageBox]::Show('Are you sure that you want to remove the contents of the stream ' + $streamName + "? `r`n (You cannot recover the contents once removed)",'Clear contents','YesNoCancel','Warning')
        switch  ($msgBoxInput) 
        {

            'Yes' 
            {
                
                Clear-Content $lstFiles.SelectedItem.ToString() -Stream $streamName
                $drpDelete.Text = ''
                $lblDisplay.Text += $streamName + " stream contents have been removed `r`n `r`n"
            }
            'No'
            {
                $drpDelete.Text = ''
            }
            'Cancel'
            {
                $drpDelete.Text = ''
            }
        }
    }
    $btnDelete.Enabled = $false
    $btnRemove.Enabled = $false
})


$btnCopy = New-Object System.Windows.Forms.Button
$btnCopy.Enabled = $false
$btnCopy.Location = New-Object System.Drawing.Size(575,500)
$btnCopy.Size = New-Object System.Drawing.Size(120,25)
$btnCopy.Text = 'Copy Contents'
$btnCopy.Add_Click(
{
    if($drpDelete.Text -ne '')
    {
        $streamName = $drpDelete.Text
        $saveFolder.ShowDialog()
        $streamContents = Get-Content -Path $lstFiles.SelectedItem.ToString() -Stream $streamName
        New-Item -Path $saveFolder.FileName -Value $streamContents -Force
    }
})



$btnRemove = New-Object System.Windows.Forms.Button
$btnRemove.Enabled = $false
$btnRemove.Location = New-Object System.Drawing.Size(700,500)
$btnRemove.Size = New-Object System.Drawing.Size(120,25)
$btnRemove.Text = 'Delete Stream'
$btnRemove.Add_Click(
{
    if($drpDelete.Text -ne '')
    {
        $streamName = $drpDelete.Text
        $msgBoxInput =  [System.Windows.MessageBox]::Show('Are you sure you want to delete the stream ' + $streamName + "? `r`n (You will not be able to recover the stream once deleted)",'ADS Deletion','YesNoCancel','Warning')
        switch  ($msgBoxInput) 
        {

            'Yes' 
            {
                Remove-Item $lstFiles.SelectedItem.ToString() -Stream $streamName
                $drpDelete.Text = ''
                $drpDelete.Items.Remove($streamName)
                $lblDisplay.Text += $streamName + " stream  has been deleted `r`n `r`n"
            }
            'No'
            {
                $drpDelete.Text = ''
            }
            'Cancel'
            {
                $drpDelete.Text = ''
            }
        }
    }
  
    $btnDelete.Enabled = $false
    $btnRemove.Enabled = $false
})


$main_form.Controls.Add($lblLocation)
$main_form.Controls.Add($btnLocate)
$main_form.Controls.Add($txtLocation)
$main_form.Controls.Add($chkData)
$main_form.Controls.Add($lblDisplay)
$main_form.Controls.Add($lstFiles)

$main_form.ShowDialog()




  
    