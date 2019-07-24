
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
    $RemotePath = $RemotePath.TrimEnd("/")
    $LocalPath = $LocalPath.TrimEnd("\")
    $LocalPath = "${LocalPath}\"
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
    $LocalPath = $LocalPath.TrimEnd("\")
    $RemotePath = $RemotePath.TrimEnd("/")
    $RemotePath = "${RemotePath}/"
    $r = $Session.PutFiles($LocalPath, $RemotePath, $false)
    if($CloseSession)
    {
        try{$session.Close()}catch{}
        try{$session.Dispose()}catch{}
    }
    return $r
}
