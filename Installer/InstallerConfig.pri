#############################
#Global Config Changes
#############################
#Prevent Windows from trying to parse the project three times per build.
#This interferes with the deployment script, and makes debugging hard since Qt attempts to debug the optimized program.
CONFIG -= debug_and_release \
    debug_and_release_target

#############################
#Extra functions
#############################
#Clean path
defineReplace(cpl){
    #Adjust the input path so that the correct slashes are used for the host shell $$psc OS
    return($$system_path($$1))
}
#Clean path with force quote
defineReplace(cpq){
    return(\"$$cpl($$1)\")
}
#############################
#Platform Specific Global Setup
#############################
win32{
    psc = "&"
    TARGET_EXT = ".exe"
    NEEDS_QTIFW = "true"
}
else:macx{
    psc = ";"
    TARGET_EXT = ".app"
    !isEmpty(MAC_USE_DMG_INSTALLER):NEEDS_QTIFW = "false"
    else:NEEDS_QTIFW = "true"
}
else:linux{
    psc= ""
    TARGET_EXT = ""
    NEEDS_QTIFW = "true"
}

#############################
#Global Variables
#############################
QtDir = $$clean_path($$[QT_INSTALL_LIBS]/..)
QtInstallerBin=$$clean_path($$QtDir/../../tools/Qtinstallerframework/3.0/bin)
REPO_DIR=""
PLATFORM_ICONS=""
PLATFORM_DATA=""
INSTALLER_CONFIG_FILE=""
DEPLOY_QT_FILE = ""

#############################
#Installer Code
#############################

#Check that all needed dependencies are installed. If not, prevent further code from dealing with lack of dependencies.
equals(NEEDS_QTIFW,"true"):!exists($$QtInstallerBin/Repogen){
    CONFIG -= program-installer program-package
    warning("The current build configuration needs QT IFW 3.0 to be installed, but it is not present.\n Please install it via the QT maintenance tool.")
}

#If program is being built in installer mode, ensure that the packages are created if needed
CONFIG(program-installer):{
    CONFIG(macx:!isEmpty(MAC_USE_DMG_INSTALLER)){
        #In the case of using a DMG installer on Mac, there is no reason to create package data
    }
    else:exists($$QtInstallerBin/Repogen){
        CONFIG *= program-package #Add package flag in case it isn't already present
    }
}

#Set flags for packaging utility
CONFIG(program-package){
    win32{
        REPO_DIR = $$cpq($$OUT_PWD/Repository/win32)
        INSTALLER_COMMANDS += "copy_packages"
        INSTALLER_COMMANDS += "bundle_packages"
        INSTALLER_COMMANDS += "package_program"
        DEPLOY_QT_PROG = $$cpq($$QtDir/bin/windeployqt)
        DEPLOY_TOOL_ARGS = "--no-translations --no-system-d3d-compiler"
    }
    else:macx:!isEmpty(MAC_USE_DMG_INSTALLER){
        CONFIG -= program-package #Using the repogen tool makes no sense if using a DMG based installer
    }
    else:macx{
        REPO_DIR=$$cpq($$OUT_PWD/Repository/macx)
        INSTALLER_COMMANDS += "copy_packages"
        INSTALLER_COMMANDS += "bundle_packages"
        INSTALLER_COMMANDS += "package_program"
        DEPLOY_QT_PROG = $$cpq($$QtDir/bin/macdeployqt)
        DEPLOY_TOOL_ARGS = ""
    }
    else:linux{
        REPO_DIR=$$cpq($$OUT_PWD/Repository/linux)
        INSTALLER_COMMANDS += "copy_packages"
        INSTALLER_COMMANDS += "bundle_packages"
        INSTALLER_COMMANDS += "package_program"
    }
}

#Set flags for binary creator tool
CONFIG(program-installer){
    macx:!isEmpty(MAC_USE_DMG_INSTALLER){
        INSTALLER_COMMANDS += "macx_dmg_installer"
        DEPLOY_QT_PROG = $$cpq($$QtDir/bin/macdeployqt)
        DEPLOY_TOOL_ARGS = ""
    }
    else:macx{
        INSTALLER_COMMANDS += "qt_ifw_installer"

        PLATFORM_DATA = $$MAC_DATA
        PLATFORM_ICONS = $$MAC_ICONS
        INSTALLER_CONFIG_FILE = $$cpq($$PWD/config/configmacx.xml)
    }
    else:win32{
        INSTALLER_COMMANDS += "qt_ifw_installer"

        PLATFORM_DATA = $$WINDOWS_DATA
        PLATFORM_ICONS = $$WINDOWS_ICONS
        INSTALLER_CONFIG_FILE = $$cpq($$PWD/config/configwin32.xml)
    }
    else:linux{
        #Set up variables for Linux for the QTIFW installer
    }
}

#Copy packages over to /Installer/Packages
contains(INSTALLER_COMMANDS, "copy_packages"){
    QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/) $$psc \
        $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/packages) $$psc
    #Copy over packages meta info
    for(PACKAGE,TARGET_PACKAGES.PACKAGES){
        #For each target package, copy it over into the installer
        QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/packages/$$PACKAGE/meta) $$psc
        win32:QMAKE_POST_LINK += $${QMAKE_COPY_DIR} $$cpq($$PWD/packages/$$PACKAGE) $$cpq($$OUT_PWD/Installer/packages/$$PACKAGE/meta) $$psc
        else:QMAKE_POST_LINK += $${QMAKE_COPY_DIR} $$cpq($$PWD/packages/$$PACKAGE/) $$cpq($$OUT_PWD/Installer/packages/$$PACKAGE/meta) $$psc
        QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/packages/$$PACKAGE/data) $$psc
    }

    #Copy over target file as a directory
    contains(TARGET_EXT,".app"): {
        QMAKE_POST_LINK +=  $${QMAKE_COPY_DIR} $$cpq($$OUT_PWD/$$TARGET$$TARGET_EXT) $$cpq($$OUT_PWD/Installer/packages/$$TARGET/data/) $$psc
    }
    #Copy over target file as a file
    else:{
        QMAKE_POST_LINK +=  $${QMAKE_COPY} $$cpq($$OUT_PWD/$$TARGET$$TARGET_EXT) $$cpq($$OUT_PWD/Installer/packages/$$TARGET/data/) $$psc
    }
    #Copy over extra packages data
    for(extraTarget,TARGET_PACKAGES.EXTRA_DATA){
        QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/packages/$$eval($$extraTarget"."PACKAGE_NAME)/data) $$psc
        for(datItem,$$eval(extraTarget).DATA){
            QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$datItem) $$cpq($$OUT_PWD/Installer/packages/$$eval($$extraTarget"."PACKAGE_NAME)/data) $$psc
        }
    }
}

#Bundle all dependencies needed to run the program using the platform dependant qt deploy tool
contains(INSTALLER_COMMANDS,"bundle_packages"){
    #Needs to be extended to work for all packages
    #Execute windeployqt to copy needed binaries (dlls, etc).
    #See documentation here:
    #http://doc.qt.io/qt-5/windows-deployment.html
    QMAKE_POST_LINK += $$DEPLOY_QT_PROG $$DEPLOY_TOOL_ARGS $$cpq($$OUT_PWD/Installer/packages/$$TARGET/data/$$TARGET$$TARGET_EXT) $$psc
}

#Repository creation code segement. This will always execute if building a QT IFW Installer.
contains(INSTALLER_COMMANDS,"package_program"){
    QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$REPO_DIR) $$psc
    QMAKE_POST_LINK += $$cpq($$QtInstallerBin/repogen) --update-new-components -p $$cpq($$OUT_PWD/Installer/packages) $$REPO_DIR $$psc
}

#Installer creation for Mac DMG
contains(INSTALLER_COMMANDS,"macx_dmg_installer"){

    #Create directory structure
    QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/) $$psc
    #Copy over project output
    QMAKE_POST_LINK += $${QMAKE_COPY_DIR} $$cpq($$OUT_PWD/$$TARGET$$TARGET_EXT) $$cpq($$OUT_PWD/Installer/) $$psc
    #Bundle output with its dependencies
    QMAKE_POST_LINK += $$cpq($$QtDir/bin/macdeployqt) $$cpq($$OUT_PWD/Installer/$$TARGET$$TARGET_EXT)$$psc
    #Add a link to the application Directory
    QMAKE_POST_LINK += ln -s /Applications $$OUT_PWD/Installer/Applications$$psc
    for(name,UNIVERSAL_DATA){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$OUT_PWD/Installer/ $$psc
    }
    for(name,MAC_DATA){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$OUT_PWD/Installer/ $$psc
    }
    #Use HDIUtil to make a folder into a read/write image
    QMAKE_POST_LINK += hdiutil create -volname $$TARGET -srcfolder $$cpq($$OUT_PWD/Installer) -ov -format UDBZ $$OUT_PWD/$$OUTPUT_INSTALLER_NAME".dmg"$$psc
    #If QMAKE_POST_LINK stops working in a future version, QMAKE provides another way to add custom targets.
    #Use the method described in "Adding Custom Targets" on http://doc.qt.io/qt-5/qmake-advanced-usage.html.
    #Our deployment tool will be called anytime the application is sucessfully linked in release mode.
}

else:contains(INSTALLER_COMMANDS,"qt_ifw_installer"){
    QMAKE_POST_LINK += $${QMAKE_MKDIR} $$cpq($$OUT_PWD/Installer/config) $$psc #Create the directory to store the installer configuration info
    QMAKE_POST_LINK += $${QMAKE_COPY} $$INSTALLER_CONFIG_FILE $$cpq($$OUT_PWD/Installer/config/config.xml) $$psc \ #Copy platform dependant config file
        $${QMAKE_COPY} $$cpq($$PWD/config/control.js) $$cpq($$OUT_PWD/Installer/config) $$psc #Copy over installer control script


    #Copy over needed icons as set in defs file
    for(name,UNIVERSAL_ICONS){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$cpq($$OUT_PWD/Installer/config) $$psc
    }
    for(name,PLATFORM_ICONS){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$cpq($$OUT_PWD/Installer/config) $$psc
    }

    #Copy over additional data specified in defs file
    for(name,UNIVERSAL_DATA){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$cpq($$OUT_PWD/Installer/packages/$$TARGET/data) $$psc
    }
    for(name,PLATFORM_DATA){
        QMAKE_POST_LINK += $${QMAKE_COPY} $$cpq($$PATH_PREFIX/$$name) $$cpq($$OUT_PWD/Installer/packages/$$TARGET/data) $$psc
    }

    #The following two lines invoke QT Installer Framework executables. See the following link
    #for documentation on what the different comman line flags do.
    #http://doc.qt.io/qtinstallerframework/ifw-tools.html

    #Create installer using the qt binary creator
    QMAKE_POST_LINK += $$cpq($$QtInstallerBin/binarycreator) -c $$cpq($$OUT_PWD/Installer/config/config.xml) -p $$cpq($$OUT_PWD/Installer/packages) \
        $$cpq($$OUT_PWD/Installer/$$OUTPUT_INSTALLER_NAME) $$psc
}
