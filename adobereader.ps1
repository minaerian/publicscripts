# Define the paths to the MSI and MSP files
$msiPath = "https://kbkgavd.blob.core.windows.net/avdinstallers/AcroRdrDC2300120174_en_US/AcroRead.msi"
$mspPath = "https://kbkgavd.blob.core.windows.net/avdinstallers/AcroRdrDC2300120174_en_US/AcroRdrDCUpd2300120174.msp"

# Define the local paths where the files will be downloaded
$localMsiPath = "C:\Temp\AcroRead.msi"
$localMspPath = "C:\Temp\AcroRdrDCUpd2300120174.msp"

# Download the MSI and MSP files
Invoke-WebRequest -Uri $msiPath -OutFile $localMsiPath
Invoke-WebRequest -Uri $mspPath -OutFile $localMspPath

# Install Adobe Acrobat Reader with the MSP update
Start-Process -FilePath "msiexec" -ArgumentList "/i `"$localMsiPath`" /update `"$localMspPath`" /qn /norestart" -Wait -NoNewWindow
