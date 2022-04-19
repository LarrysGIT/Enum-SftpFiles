# Enum-SftpFiles
Cmdlets to handle local file and sftp

# Import the DLL from the repo before invoke the cmdlet
This wrap-up script is built based on the given version of WinScp.

`Add-Type -Path .\WinSCP_API_Sample\WinSCPnet.dll`

# Examples
### Import commands
```powershell
Add-Type -Path .\WinSCP_API_Sample\WinSCPnet.dll
. .\SftpCommands.ps1
```

### Initial a new SFTP session
```powershell
$session = New-SftpSession -HostName sftp.dns.name -Username sftpuser -Password sftppassword -AcceptAllCertificate
```

* Don't forget to close SFTP session like the following.

```powershell
Close-SftpSession -Session $session
```

### List SFTP objects
The following enums `File` only and `FileName` matches `2019-06-28`. e.g. `ThisIsAFile2019-06-28.txt`

`Filter parameters` are regular expression

```powershell
Enum-SftpFiles -HostName $SFTPServer -Session $session -RemotePath "/" -AcceptAllCertificate -Recurse -FileNameIncludeFilter "2019-06-28" -Directory:$false
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

LocalObject: Filesystem object, same from `Get-ChildItem` cmdlet

RemoteObject: WinScp API defined SFTP object

Result: 

| Name | Explaination |
| ---  | --- |
| LocalOnly | The object exists in local only |
| RemoteOnly | The object exists in remote only |
| DirectoryBoth | The object is a directory, exists on both local and remote |
| FileBoth | The object is a file, exists on both local and remote |
| DirectoryLocal,FileRemote | The object exists on both, however, it is a directory in local and a file on remote |
| FileLocal,DirectoryRemote | The object exists on both, however, it is a file in local and a directory on remote |
| SameLength | The object has the same length |
| DifferentLength | The object has different on local and remote |
| SameLastWriteTime | The object has the same last write time |
| DifferentLastWriteTime | The object last write time is different in local and remote |
| LocalNewer | The object in the local has a newer last write time |
| RemoteNewer | The object in the remote has a newer last write time |

Different: `Boolean`, an overall value indicates the object local and remote are different or not

### `Give-SftpCopySuggestion`

Accept the results from `Compare-SftpObject`, give suggestions to sync up local and remote

The example following indicates you should upload the localobject to remote to sync up

```powershell
$compares = Compare-SftpObject -Session $session -LocalPath $localPath -RemotePath $remotePath -Recurse -CompareSize -CompareLastWriteTime
Give-SftpCopySuggestion -CompareResults $compares

LocalObject RemoteObject Direction     Type
----------- ------------ ---------     ----
testdir1                 LocalToRemote New 

```

| Direction | Type | Explaination |
| --- | --- | --- |
| LocalToRemote | New | The object exists in local but not remote, should copy from local to remote |
| RemoteToLocal | New | The object exists in remote but not local, should copy from local to remote |
| LocalToRemote | NewerOverwrite | The object exists both local and remote, local is newer, should copy and overwrite remote |
| RemoteToLocal | NewerOverwrite | The object exists both remote and local, remote is newer, should copy and overwrite local |
| UnableToGiveSuggestion | UnableToGiveSuggestion | The object exists both local and remote, but different type, one a file, another is directory, you need to delete one first |
