Codeunit 70009 "i95 Job Queue API Calls"
{

    trigger OnRun()
    begin
        ClearLastError();
        if not i95ProcessSyncAPI.Run() then
            message('Sync Process Error :%1', GetLastErrorText());
        Commit();
        Sleep(10000); //10000 milliseconds = 10 seconds 
        if not i95ProcessPulledData.Run() then
            message('Data Update Process Error :%1', GetLastErrorText());
        Commit();
        Sleep(10000); //10000 milliseconds = 10 seconds
        if not i95ProcessResponseAPI.Run() then
            message('Response Process Error :%1', GetLastErrorText());
        Commit();
        Sleep(10000); //10000 milliseconds = 10 seconds
        if not i95ProcessAcknowledgeAPI.Run() then
            message('Ack Process Error :%1', GetLastErrorText());
        Commit();
    end;

    var
        i95ProcessSyncAPI: Codeunit "i95 Process Sync Api";
        i95ProcessPulledData: Codeunit "i95 Process Pulled Data";
        i95ProcessResponseAPI: Codeunit "i95 Process Response Api";
        i95ProcessAcknowledgeAPI: Codeunit "i95 Process Acknowledge Api";
}