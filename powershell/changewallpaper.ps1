Function Set-WallPaper($Value)
{
 Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $value
 rundll32.exe user32.dll, UpdatePerUserSystemParameters
}

Invoke-WebRequest "https://novotomo.files.wordpress.com/2015/06/jcid.jpg" -OutFile C:\temp\test.jpg

Set-WallPaper "C:\temp\test.jpg"

