# Enum-SftpFiles
A cmdlet to enum sftp

# https://winscp.net/eng/docs/library
Download the API DLL from above url

Import the DLL before invoke the cmdlet

`Add-Type -Path WinSCPnet.dll`

# Example
Filter parameters are regular expression

The following enums `File` only and `FileName` matches `2019-06-28`. e.g. `ThisIsAFile2019-06-28.txt`

`Enum-SftpFiles -HostName $SFTPServer -Username $SFTPUser -Password $SFTPPass -RemotePath "/" -AcceptAllCertificate -Recurse -FileNameIncludeFilter "2019-06-28" -Directory:$false`

