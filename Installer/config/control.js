function Controller() {
    var widget = gui.pageById(QInstaller.Introduction); // get the introduction wizard page
    if (widget != null){
        widget.packageManagerCoreTypeChanged.connect(onPackageManagerCoreTypeChanged);
    }
}

Controller.prototype.IntroductionPageCallback  = function(){
    var widget = gui.currentPageWidget();
    if (widget != null) {
        console.log(Object.getOwnPropertyNames(widget));
        widget.findChild("PackageManagerRadioButton").text = "Add or Remove components from Example Application";
        widget.findChild("UninstallerRadioButton").text = "Uninstall Example Application"
        widget.findChild("UpdaterRadioButton").text = "Update Example Application"
    }

}

Controller.prototype.LicenseAgreementPageCallback = function(){
    var widget = gui.currentPageWidget();
    if (widget != null) {
		//Stub out code to allow changing default of license agreement.
		//Helpful in debug to change to true.
        widget.AcceptLicenseRadioButton.checked = false;
    }
}

Controller.prototype.FinishedPageCallback = function(){
}

onPackageManagerCoreTypeChanged = function(){

	
    var widget = gui.pageById(QInstaller.Introduction);
}
