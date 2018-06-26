function Component(){
    gui.pageWidgetByObjectName("LicenseAgreementPage").entered.connect(changeLicenseLabels);
    installer.installationFinished.connect(this, Component.prototype.installationFinishedPageIsShown);
    installer.finishButtonClicked.connect(this, Component.prototype.installationFinished);

    //gui.pageWidgetByObjectName("Introduction").entered.connect(changeLicenseLabels);
}

Component.prototype.createOperations = function(){
    component.createOperations();
    if(installer.value("os") == "win"){
        component.addOperation("Execute", "@TargetDir@\\vcredist_x64.exe","/install","/passive", "/norestart","/quiet");
        component.addOperation("CreateShortcut", "@TargetDir@/example.exe", "@StartMenuDir@/example.lnk",
                    "workingDirectory=@TargetDir@","description=Run Example Application");
    }
}
Component.prototype.installationFinishedPageIsShown = function(){
}

Component.prototype.installationFinished = function(){

}
changeLicenseLabels = function()
{
    //page = gui.pageWidgetByObjectName("LicenseAgreementPage");
    //page.AcceptLicenseLabel.setText("Yes I do!");
    //page.RejectLicenseLabel.setText("No I don't!");
}
