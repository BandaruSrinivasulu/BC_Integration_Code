Codeunit 70010 "i95 Delete Sync Log Entries"
{
    trigger OnRun()
    begin
        Deletei95SyncLogEntries();
    end;

    procedure Deletei95SyncLogEntries()
    var
        I95SyncLogEntry: Record "i95 Sync Log Entry";
        DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        APILogEntry: Record "i95 API Call Log Entry";
    begin
        I95SyncLogEntry.reset();
        If I95SyncLogEntry.FindSet() then
            repeat
                DetSyncLogEntry.Reset();
                DetSyncLogEntry.SetRange("Sync Log Entry No", I95SyncLogEntry."Entry No");
                if DetSyncLogEntry.FindSet() then
                    DetSyncLogEntry.DeleteAll();

                APILogEntry.Reset();
                APILogEntry.SetRange("Sync Log Entry No", I95SyncLogEntry."Entry No");
                if APILogEntry.FindSet() then
                    APILogEntry.DeleteAll();

                I95SyncLogEntry.Delete();
            until I95SyncLogEntry.Next() = 0;
    end;
}