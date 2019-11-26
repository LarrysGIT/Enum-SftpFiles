
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

    $fs_objects = $Session.ListDirectory($RemotePath)
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
        [switch]$AcceptAllCertificate
    )
    $LocalPath = [io.path]::GetFullPath($LocalPath) # in case relative path like "."
    $LocalPath = $LocalPath -ireplace "\\$", "\"
    $RemotePath = $RemotePath -ireplace "/$", "/"
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
        $localObjects = Get-ChildItem -Path $LocalPath -Recurse:$Recurse -Force
    }
    elseif($File -and !$Directory)
    {
        $localObjects = Get-ChildItem -Path $LocalPath -File -Recurse:$Recurse -Force
    }
    elseif(!$File -and $Directory)
    {
        $localObjects = Get-ChildItem -Path $LocalPath -Directory -Recurse:$Recurse -Force
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
    }
    # Direction: based on local objects, check remote objects
    $CheckedRemoteObjects = @()
    foreach($localobject in $localObjects)
    {
        $ComparedObject = New-Object ComparedObject
        $ComparedObject.LocalObject = $localobject
        $matched = $false
        $localobjectFullName_Relative = $localobject.FullName.Remove(0, $LocalPath.Length).TrimStart("\")
        foreach($remoteobject in $remoteObjects)
        {
            $remoteobjectFullName_Relative = $remoteobject.FullName.Remove(0, $RemotePath.Length).TrimStart("/").Replace("/", "\")
            if($localobjectFullName_Relative -eq $remoteobjectFullName_Relative)
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
                }
            }
            else
            {
                # Local object is a file
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # remote is a directory
                    $ComparedObject.Result = "FileLocal,DirectoryRemote"
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
                        }
                    }
                    if($CompareLastWriteTime)
                    {
                        if($ComparedObject.LocalObject.LastWriteTime -eq $ComparedObject.RemoteObject.LastWriteTime)
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
                        }
                    }
                }
            }
        }
        else
        {
            $ComparedObject.Result += "LocalOnly"
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
        $remoteobjectFullName_Relative = $remoteobject.FullName.Remove(0, $RemotePath.Length).TrimStart("/")
        foreach($localobject in $LocalObjects)
        {
            $localobjectFullName_Relative = $localobject.FullName.Remove(0, $LocalPath.Length).TrimStart("\").Replace("\", "/")
            if($localobjectFullName_Relative -eq $remoteobjectFullName_Relative)
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
                }
            }
            else
            {
                # Local object is a file
                if($ComparedObject.RemoteObject.IsDirectory)
                {
                    # remote is a directory
                    $ComparedObject.Result = "FileLocal,DirectoryRemote"
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
                        }
                    }
                    if($CompareLastWriteTime)
                    {
                        if($ComparedObject.LocalObject.LastWriteTime -eq $ComparedObject.RemoteObject.LastWriteTime)
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
                        }
                    }
                }
            }
        }
        else
        {
            $ComparedObject.Result += "RemoteOnly"
        }
        $ComparedObject
    }
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
}
