codeunit 70011 "i95 Installation"
{
    Subtype = Install;

    trigger OnRun()
    begin

    end;

    trigger OnInstallAppPerCompany();
    var
        i95APIConfig: Record "i95 API Configuration";
    begin
        i95APIConfig.Initializei95APIConfiguration();
        EnableWebServiceCalls();
        i95APIConfig.intilizeEntityMapping();
    end;

    procedure EnableWebServiceCalls()
    var
        NavAppSetting: Record "NAV App Setting";
        Appinfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Appinfo);
        NavAppSetting."App ID" := Appinfo.Id();
        NavAppSetting."Allow HttpClient Requests" := true;
        if not NavAppSetting.Insert() then
            NavAppSetting.Modify();
    end;
}