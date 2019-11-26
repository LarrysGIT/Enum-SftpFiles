# Enum-SftpFiles
Cmdlets to handle local file and sftp

# https://winscp.net/eng/docs/library
Download the API DLL from above url

Import the DLL before invoke the cmdlet

`Add-Type -Path WinSCPnet.dll`

# Examples
### Import commands
```powershell
Add-Type -Path WinSCPnet.dll
. .\SftpCommands.ps1
```

### Initial a new SFTP session
```powershell
$session = New-SftpSession -HostName sftp.dns.name -Username sftpuser -Password sftppassword -AcceptAllCertificate
```

* Create a dedicated SFTP session is suggested. Although pass username and password works too, initial the SFTP session is time costly.

* Don't forget to close SFTP session like the following.

```powershell
Close-SftpSession -Session $session
```

### List SFTP objects
The following enums `File` only and `FileName` matches `2019-06-28`. e.g. `ThisIsAFile2019-06-28.txt`

`Filter parameters` are regular expression

```powershell
Enum-SftpFiles -HostName $SFTPServer -Username $SFTPUser -Password $SFTPPass -RemotePath "/" -AcceptAllCertificate -Recurse -FileNameIncludeFilter "2019-06-28" -Directory:$false
```

### "Get/Download" objects from SFTP

```powershell
Download-SftpObject -Session $session -RemotePath "/somepath/test" -LocalPath "C:\Temp"
```

### "Put/Upload" objects to SFTP

```powershell
Upload-SftpObject -Session $session -LocalPath "C:\Temp" -RemotePath "/somepath/test"
```

### da da! Here is a new cmdlet recently wrote to support a new requirement

```powershell
Compare-SftpObject -Session $session -LocalPath .\ -RemotePath "/remotepath" -Recurse -CompareSize -CompareLastWriteTime
```

* This new cmdlet allows script to compare contents in a local path and a remote SFTP path by checking the path existence, size (file) and last modified time (file).

* Q: Why not compare files by hash? A: To do it, need to download the data from SFTP then get the hash, time costly. For now, simply not supported.

* Q: What's the purpose of this cmdlet? A: Check the following scenario.

```
~ Rachael: Hey! Larry! Can you send a folder in the share to SFTP, so the team in XXX can pick it up? (XXX team is unable to access our share, just business restriction)
~ Me: Sure!
    Upload-SftpObject is the one, makes life easy for everyone (problem solved for now)

<<<2 months passed>>>

~ Rachael: Hey! Larry! The thing you setup 2 months ago worked, but my team has found it is getting slower and slower, can you take a look please?
~ Me: Sure!
    In past 2 months, the local share has been populated with a large amount of data, the Upload-SftpObject cmd copies everything, including files unchanged.
    Compare-SftpObject is the one, I use the cmdlet to get files have different size, path or last modified time. Selectively use Upload-SftpObject to upload only changed data to SFTP.
```
