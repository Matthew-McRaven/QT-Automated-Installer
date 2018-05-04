#Add this include to the bottom of your project to enable automated installer creation
#Set the following line to contain the path to the .ico file to be used as a icon for Windows
win32:RC_ICONS += "Resources/myIcon.ico"
#Set the following line to contain the path to the .icns file to be used as a icon for Mac OS X
macx:ICON = "Resources/myIcon.icns"
#Include the definitions file that sets all variables needed for the InstallerConfig Script
include("ProjectDefs.pri")

#Lastly, include and run the installer config script
include("Installer/InstallerConfig.pri")
