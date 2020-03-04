
# Download API lib from https://winscp.net/eng/docs/library
# Add-Type -Path WinSCPnet.dll

function Enum-SftpFiles()
{
    PARAM(
        [WinSCP.Session]$Session,
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [string]$RemotePath,
        [switch]$File = $true,
        [switch]$Directory = $true,
        [string]$FileNameIncludeFilter,
        [string]$FileNameExcludeFilter,
        [string]$DirectoryNameIncludeFilter,
        [string]$DirectoryNameExcludeFilter,
        [switch]$Recurse,
        [int]$Deepth = [int]::MaxValue,
        [switch]$AcceptAllCertificate
    )
    if(!$Session)
    {
        if(!$HostName -or !$Username -or !$Password)
        {
            throw "Please provide at least one of [Session] and ([HostName],[Username],[Password])"
            return
        }
    }
    if(!$CurrentDeepth -or $CurrentDeepth -le 0)
    {
        $CurrentDeepth = 0
    }
    $CurrentDeepth++
    $CloseSession = $false
    if(!$Session)
    {
        $CloseSession = $true
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            UserName = $Username
            Password = $Password
            GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
        }
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
    }
    if($Session.FileExists($RemotePath))
    {
        $fs_objects = $Session.ListDirectory($RemotePath)
    }
    else
    {
        $fs_objects = @()
    }
    foreach($f in $fs_objects.Files)
    {
        if($f.IsThisDirectory -or $f.IsParentDirectory){continue}
        if($f.IsDirectory)
        {
            if($Directory)
            {
                if($DirectoryNameIncludeFilter)
                {
                    if($f.Name -imatch $DirectoryNameIncludeFilter)
                    {
                        if($DirectoryNameExcludeFilter)
                        {
                            if($f.Name -notmatch $DirectoryNameExcludeFilter)
                            {
                                $f
                            }
                        }
                        else
                        {
                            $f
                        }
                    }
                }
                else
                {
                    $f
                }
            }
            if($Recurse -and $CurrentDeepth -lt $Deepth)
            {
                Enum-SftpFiles -Session $Session -HostName $HostName -RemotePath $f.FullName -Directory:$Directory -File:$File -FileNameIncludeFilter $FileNameIncludeFilter -DirectoryNameIncludeFilter $DirectoryNameIncludeFilter -Recurse:$Recurse -UserName $Username -Password $Password -AcceptAllCertificate:$AcceptAllCertificate -FileNameExcludeFilter $FileNameExcludeFilter -DirectoryNameExcludeFilter $DirectoryNameExcludeFilter
            }
        }
        else
        {
            if($File)
            {
                if($FileNameIncludeFilter)
                {
                    if($f.Name -imatch $FileNameIncludeFilter)
                    {
                        if($FileNameExcludeFilter)
                        {
                            if($f.Name -notmatch $FileNameExcludeFilter)
                            {
                                $f
                            }
                        }
                        else
                        {
                            $f
                        }
                    }
                }
                else
                {
                    $f
                }
            }
        }
    }
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
}

function Download-SftpObject()
{
    PARAM(
        [WinSCP.Session]$Session,
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [string]$RemotePath,
        [string]$LocalPath,
        [switch]$AcceptAllCertificate
    )
    if(!$Session)
    {
        if(!$HostName -or !$Username -or !$Password)
        {
            throw "Please provide at least one of [Session] and ([HostName],[Username],[Password])"
            return
        }
    }
    $CloseSession = $false
    if(!$Session)
    {
        $CloseSession = $true
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            UserName = $Username
            Password = $Password
            GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
        }
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
    }
    $r = $Session.GetFiles($RemotePath, $LocalPath, $false)
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
    return $r
}

function Upload-SftpObject()
{
    PARAM(
        [WinSCP.Session]$Session,
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [string]$LocalPath,
        [string]$RemotePath,
        [switch]$AcceptAllCertificate
    )
    if(!$Session)
    {
        if(!$HostName -or !$Username -or !$Password)
        {
            throw "Please provide at least one of [Session] and ([HostName],[Username],[Password])"
            return
        }
    }
    $CloseSession = $false
    if(!$Session)
    {
        $CloseSession = $true
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            UserName = $Username
            Password = $Password
            GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
        }
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
    }
    $r = $Session.PutFiles($LocalPath, $RemotePath, $false)
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
    return $r
}

function New-SftpSession()
{
    PARAM(
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [switch]$AcceptAllCertificate
    )
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = $HostName
        UserName = $Username
        Password = $Password
        GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
    }
    $Session = New-Object WinSCP.Session
    $Session.Open($sessionOptions)
    return $Session
}

function Close-SftpSession()
{
    PARAM(
        [WinSCP.Session]$Session
    )
    try{$session.Close()}catch{}
    try{$session.Dispose()}catch{}
}

function Compare-SftpObject()
{
    PARAM(
        [WinSCP.Session]$Session,
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [string]$LocalPath,
        [string]$RemotePath,
        [switch]$Recurse,
        [switch]$CompareSize = $true,
        [switch]$CompareLastWriteTime,
        [switch]$File = $true,
        [switch]$Directory = $true,
        [switch]$OutputDifferenceOnly,
        [switch]$AcceptAllCertificate
    )
    $LocalPath = [io.path]::GetFullPath($LocalPath) # in case relative path like "."
    $LocalPath = $LocalPath -ireplace "\\$"
    if($RemotePath -ne "/"){
        $RemotePath = $RemotePath -ireplace "/$"
    }
    if(!$Session)
    {
        if(!$HostName -or !$Username -or !$Password)
        {
            throw "Please provide at least one of [Session] and ([HostName],[Username],[Password])"
            return
        }
    }
    $CloseSession = $false
    if(!$Session)
    {
        $CloseSession = $true
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            UserName = $Username
            Password = $Password
            GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
        }
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
    }
    if($File -and $Directory)
    {
        $localObjects = @(Get-ChildItem -Path $LocalPath -Recurse:$Recurse -Force) + @(Get-Item -Path $LocalPath)
    }
    elseif($File -and !$Directory)
    {
        $localObjects = Get-ChildItem -Path $LocalPath -File -Recurse:$Recurse -Force
    }
    elseif(!$File -and $Directory)
    {
        $localObjects = @(Get-ChildItem -Path $LocalPath -Directory -Recurse:$Recurse -Force) + @(Get-Item -Path $LocalPath)
    }
    else
    {
        $localObjects = @()
    }
    $remoteObjects = Enum-SftpFiles -Session $Session -RemotePath $RemotePath -Recurse:$Recurse -File:$File -Directory:$Directory

    class ComparedObject
    {
        [object]$LocalObject = $null
        [object]$RemoteObject = $null
        [string[]]$Result = @()
        [bool]$Different = $false
    }

    # Direction: based on local objects, check remote objects
    $CheckedRemoteObjects = @()
    foreach($localobject in $localObjects)
    {
        $ComparedObject = New-Object ComparedObject
        $ComparedObject.LocalObject = $localobject
        $matched = $false
        $localobjectFullName_Relative = $localobject.FullName.Remove(0, $LocalPath.Length).TrimStart("\").Replace("\\", "\")
        $localobjectMappedToRemote = New-Object -TypeName PSObject -Property @{"FullName" = "$RemotePath/$($localobjectFullName_Relative.Replace('\', '/'))".Replace("//", "/")}
        foreach($remoteobject in $remoteObjects)
        {
            if($remoteobject.FullName -eq $localobjectMappedToRemote.FullName)
            {
                # local and remote objects have the same relative path
                $matched = $true
                break
            }
        }
        if($matched)
        {
            $CheckedRemoteObjects += $remoteobject.FullName
            $ComparedObject.RemoteObject = $remoteobject
            if($ComparedObject.LocalObject.Mode -match "^d")
            {
                # Local object is a directory
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # both are directory
                    $ComparedObject.Result += "DirectoryBoth"
                }
                else
                {
                    # remote is a file
                    $ComparedObject.Result += "DirectoryLocal,FileRemote"
                    $ComparedObject.Different = $true
                }
            }
            else
            {
                # Local object is a file
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # remote is a directory
                    $ComparedObject.Result = "FileLocal,DirectoryRemote"
                    $ComparedObject.Different = $true
                }
                else
                {
                    # both are file
                    $ComparedObject.Result += "FileBoth"
                    if($CompareSize)
                    {
                        if($ComparedObject.LocalObject.Length -eq $ComparedObject.RemoteObject.Length)
                        {
                            # same file length
                            $ComparedObject.Result += "SameLength"
                        }
                        else
                        {
                            # different file length
                            $ComparedObject.Result += "DifferentLength"
                            $ComparedObject.Different = $true
                        }
                    }
                    if($CompareLastWriteTime)
                    {
                        if($ComparedObject.LocalObject.LastWriteTime.ToString("yyyyMMddHHmmss") -eq $ComparedObject.RemoteObject.LastWriteTime.ToString("yyyyMMddHHmmss"))
                        {
                            # same LastWriteTime
                            $ComparedObject.Result += "SameLastWriteTime"
                        }
                        else
                        {
                            $ComparedObject.Result += "DifferentLastWriteTime"
                            if($ComparedObject.LocalObject.LastWriteTime -ge $ComparedObject.RemoteObject.LastWriteTime)
                            {
                                $ComparedObject.Result += "LocalNewer"
                            }
                            else
                            {
                                $ComparedObject.Result += "RemoteNewer"
                            }
                            $ComparedObject.Different = $true
                        }
                    }
                }
            }
        }
        else
        {
            $ComparedObject.Result += "LocalOnly"
            $ComparedObject.RemoteObject = $localobjectMappedToRemote
            $ComparedObject.Different = $true
        }
        $ComparedObject
    }
    # Direction: based on remote objects, check local objects
    foreach($remoteobject in $RemoteObjects)
    {
        if($CheckedRemoteObjects -contains $remoteobject.FullName)
        {
            # checked already, no need to do again
            Continue
        }
        $ComparedObject = New-Object ComparedObject
        $ComparedObject.RemoteObject = $remoteobject
        $matched = $false
        $remoteobjectFullName_Relative = $remoteobject.FullName.Remove(0, $RemotePath.Length).TrimStart("/").Replace("//", "/")
        $remoteobjectMappedToLocal = New-Object -TypeName PSObject -Property @{"FullName" = "$LocalPath\$($remoteobjectFullName_Relative.Replace('/', '\'))".Replace("//", "/")}
        foreach($localobject in $LocalObjects)
        {
            if($localobject.FullName -eq $remoteobjectMappedToLocal.FullName)
            {
                # local and remote objects have the same relative path
                $matched = $true
                break
            }
        }
        if($matched)
        {
            $ComparedObject.LocalObject = $localobject
            if($ComparedObject.LocalObject.Mode -match "^d")
            {
                # Local object is a directory
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # both are directory
                    $ComparedObject.Result += "DirectoryBoth"
                }
                else
                {
                    # remote is a file
                    $ComparedObject.Result += "DirectoryLocal,FileRemote"
                    $ComparedObject.Different = $true
                }
            }
            else
            {
                # Local object is a file
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # remote is a directory
                    $ComparedObject.Result = "FileLocal,DirectoryRemote"
                    $ComparedObject.Different = $true
                }
                else
                {
                    # both are file
                    $ComparedObject.Result += "FileBoth"
                    if($CompareSize)
                    {
                        if($ComparedObject.LocalObject.Length -eq $ComparedObject.RemoteObject.Length)
                        {
                            # same file length
                            $ComparedObject.Result += "SameLength"
                        }
                        else
                        {
                            # different file length
                            $ComparedObject.Result += "DifferentLength"
                            $ComparedObject.Different = $true
                        }
                    }
                    if($CompareLastWriteTime)
                    {
                        if($ComparedObject.LocalObject.LastWriteTime.ToString("yyyyMMddHHmmss") -eq $ComparedObject.RemoteObject.LastWriteTime.ToString("yyyyMMddHHmmss"))
                        {
                            # same LastWriteTime
                            $ComparedObject.Result += "SameLastWriteTime"
                        }
                        else
                        {
                            $ComparedObject.Result += "DifferentLastWriteTime"
                            if($ComparedObject.LocalObject.LastWriteTime -ge $ComparedObject.RemoteObject.LastWriteTime)
                            {
                                $ComparedObject.Result += "LocalNewer"
                            }
                            else
                            {
                                $ComparedObject.Result += "RemoteNewer"
                            }
                            $ComparedObject.Different = $true
                        }
                    }
                }
            }
        }
        else
        {
            $ComparedObject.Result += "RemoteOnly"
            $ComparedObject.LocalObject = $remoteobjectMappedToLocal
            $ComparedObject.Different = $true
        }
        $ComparedObject
    }
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
}

function Give-SftpCopySuggestion
{
    PARAM(
        [object[]]$CompareResults
    )
    class CopySuggestion
    {
        [object]$LocalObject = $null
        [object]$RemoteObject = $null
        [string]$Direction = $null
        [string]$Type = $null
    }
    # objects in local but not remote, no need to copy everything
    $LocalOnlys = $CompareResults | ?{$_.Result -imatch "LocalOnly"} | Sort-Object -Property @{E = {$_.LocalObject.FullName}}
    for($i = 0; $i -lt $LocalOnlys.Count; $i++)
    {
        if(!$LocalOnlys[$i]){continue}
        for($j = $i + 1; $j -lt $LocalOnlys.Count; $j++)
        {
            if($LocalOnlys[$j].LocalObject.FullName -like "$($LocalOnlys[$i].LocalObject.FullName)\*")
            {
                $LocalOnlys[$j] = $null
            }
        }
        $CopySuggestion = New-Object CopySuggestion
        $CopySuggestion.LocalObject = $LocalOnlys[$i].LocalObject
        $CopySuggestion.RemoteObject = $LocalOnlys[$i].RemoteObject
        $CopySuggestion.Direction = "LocalToRemote"
        $CopySuggestion.Type = "New"
        $CopySuggestion
    }
    # objects in remote but not local, no need to copy everything
    $RemoteOnlys = $CompareResults | ?{$_.Result -imatch "RemoteOnly"} | Sort-Object -Property @{E = {$_.RemoteObject.FullName}}
    for($i = 0; $i -lt $RemoteOnlys.Count; $i++)
    {
        if(!$RemoteOnlys[$i]){continue}
        for($j = $i + 1; $j -lt $RemoteOnlys.Count; $j++)
        {
            if($RemoteOnlys[$j].RemoteObject.FullName -like "$($RemoteOnlys[$i].RemoteObject.FullName)\*")
            {
                $RemoteOnlys[$j] = $null
            }
        }
        $CopySuggestion = New-Object CopySuggestion
        $CopySuggestion.LocalObject = $RemoteOnlys[$i].LocalObject
        $CopySuggestion.RemoteObject = $RemoteOnlys[$i].RemoteObject
        $CopySuggestion.Direction = "RemoteToLocal"
        $CopySuggestion.Type = "New"
        $CopySuggestion
    }
    # objects in local is newer
    $LocalNewers = $CompareResults | ?{$_.Result -imatch "LocalNewer"}
    for($i = 0; $i -lt $LocalNewers.Count; $i++)
    {
        $CopySuggestion = New-Object CopySuggestion
        $CopySuggestion.LocalObject = $LocalNewers[$i].LocalObject
        $CopySuggestion.RemoteObject = $LocalNewers[$i].RemoteObject
        $CopySuggestion.Direction = "LocalToRemote"
        $CopySuggestion.Type = "NewerOverwrite"
        $CopySuggestion
    }
    # objects in remote is newer
    $RemoteNewers = $CompareResults | ?{$_.Result -imatch "RemoteNewer"}
    for($i = 0; $i -lt $RemoteNewers.Count; $i++)
    {
        $CopySuggestion = New-Object CopySuggestion
        $CopySuggestion.LocalObject = $RemoteNewers[$i].LocalObject
        $CopySuggestion.RemoteObject = $RemoteNewers[$i].RemoteObject
        $CopySuggestion.Direction = "RemoteToLocal"
        $CopySuggestion.Type = "NewerOverwrite"
        $CopySuggestion
    }
    # objects exist in both local and remote, however, one is file, another is directory
    $UnableToGiveSuggestions = $CompareResults | ?{$_.Result -imatch "DirectoryLocal,FileRemote|FileLocal,DirectoryRemote"}
    for($i = 0; $i -lt $UnableToGiveSuggestions.Count; $i++)
    {
        $CopySuggestion = New-Object CopySuggestion
        $CopySuggestion.LocalObject = $LocalNewers[$i].LocalObject
        $CopySuggestion.RemoteObject = $LocalNewers[$i].RemoteObject
        $CopySuggestion.Direction = "UnableToGiveSuggestion"
        $CopySuggestion.Type = "UnableToGiveSuggestion"
        $CopySuggestion
    }
}

function Move-SftpObject
{
    PARAM(
        [WinSCP.Session]$Session,
        [string]$HostName,
        [string]$Username,
        [string]$Password,
        [string]$RemotePathSource,
        [string]$RemotePathDestination,
        [switch]$AcceptAllCertificate
    )
    if(!$Session)
    {
        if(!$HostName -or !$Username -or !$Password)
        {
            throw "Please provide at least one of [Session] and ([HostName],[Username],[Password])"
            return
        }
    }
    $CloseSession = $false
    if(!$Session)
    {
        $CloseSession = $true
        $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
            Protocol = [WinSCP.Protocol]::Sftp
            HostName = $HostName
            UserName = $Username
            Password = $Password
            GiveUpSecurityAndAcceptAnySshHostKey = $AcceptAllCertificate
        }
        $Session = New-Object WinSCP.Session
        $Session.Open($sessionOptions)
    }
    $r = $Session.MoveFile($RemotePathSource, $RemotePathDestination)
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
    return $r
}