function Set-AccountPicture {
    [cmdletbinding(SupportsShouldProcess=$true)]
    PARAM(
        [Parameter(Position=0, ParameterSetName='PicturePath')]
        [string]$UserName = ('{0}\{1}' -f $env:UserDomain, $env:UserName),

        [Parameter(Position=1, ParameterSetName='PicturePath')]
        [string]$PicturePath,

        [Parameter(Position=0, ParameterSetName='UsePictureFromAD')]
        [switch]$UsePictureFromAD
    )
    
    Begin {
        Add-Type -TypeDefinition @'
        using System; 
        using System.Runtime.InteropServices; 
        namespace WinAPIs { 
            public class UserAccountPicture { 
                [DllImport("shell32.dll", EntryPoint = "#262", CharSet = CharSet.Unicode, PreserveSig = false)] 
                public static extern void SetUserTile(string username, int notneeded, string picturefilename); 
            }
        }
'@ -IgnoreWarnings
    }

    Process {
        if ($pscmdlet.ShouldProcess($UserName, "SetAccountPicture")) {
            switch ($PsCmdlet.ParameterSetName) {

                'PicturePath' {
                    if (Test-Path -Path $PicturePath -PathType Leaf) {
                        [WinAPIs.UserAccountPicture]::SetUserTile($UserName, 0, $PicturePath)
                    } else {
                        Write-Error ('Picture file {0} does not exist!' -f $PicturePath)
                    }
                    break
                }

                'UsePictureFromAD' {
                    $PicturePath = '{0}\{1}_{1}.jpeg' -f $env:Temp, $env:UserDomain, $env:UserName
                    $photo = ([ADSISEARCHER]"samaccountname=$($env:username)").findone().properties.thumbnailphoto
                    $photo | Set-Content -Path $PicturePath -Encoding byte
                    $UserName = '{0}\{1}' -f $env:UserDomain, $env:UserName
                    [WinAPIs.UserAccountPicture]::SetUserTile($UserName, 0, $PicturePath)
                    break
                }

            }
        }
    }
    End { }
}

Invoke-WebRequest "https://upload.wikimedia.org/wikipedia/commons/3/33/Nicolas_Cage_2011_CC.jpg" -OutFile C:\temp\test.jpg

#Set-AccountPicture -UserName 'CONTOSO\martin' -PicturePath 'C:\Temp\martin.jpeg'
Set-AccountPicture -UserName (Get-WMIObject -class Win32_ComputerSystem).username -PicturePath 'C:\temp\test.jpg'

#set the current logged-on user the picture from his thumbnailphoto attribute in ActiveDirectory
#Set-AccountPicture -UsePictureFromAD –Verbose

