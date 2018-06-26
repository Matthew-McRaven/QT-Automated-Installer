#V
TEMPLATE = app
TARGET = "Example"
QT -= gui

CONFIG += c++11 console
CONFIG -= app_bundle



#Add this include to the bottom of your project to enable automated installer creation
#Set the following line to contain the path to the .ico file to be used as a icon for Windows

#win32:RC_ICONS += "Resources/myIcon.ico"
#Set the following line to contain the path to the .icns file to be used as a icon for Mac OS X
#macx:ICON = "Resources/myIcon.icns"

#Include the definitions file that sets all variables needed for the InstallerConfig Script
include("ProjectDefs.pri")

#Lastly, include and run the installer config script
include("Installer/InstallerConfig.pri")

DISTFILES += \
    Installer/packages/Example/installscript.js \
    Installer/packages/Example/package.xml \
    Installer/packages/Example/License.txt \
    Installer/config/control.js \
    Installer/config/configlinux.xml \
    Installer/config/configmacx.xml \
    Installer/config/configwin32.xml

SOURCES += \
    sampleprogram.cpp

