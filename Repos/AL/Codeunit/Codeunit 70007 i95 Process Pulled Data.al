codeunit 70007 "i95 Process Pulled Data"
{
    trigger OnRun()
    var
        i95Setup: Record "i95 Setup";
    begin
        i95Setup.get();
        i95Setup.TestField(i95Setup."i95 Customer Posting Group");
        i95Setup.TestField(i95Setup."i95 Gen. Bus. Posting Group");
        i95Setup.TestField(i95Setup."Default Guest Customer No.");

        // with i95SyncLogEntry do begin
        i95SyncLogEntry.Reset();
        i95SyncLogEntry.SetRange("Sync Source", i95SyncLogEntry."Sync Source"::i95);
        i95SyncLogEntry.SetRange("Sync Status", i95SyncLogEntry."Sync Status"::"Waiting for Sync");
        i95SyncLogEntry.SetFilter("Log Status", '=%1|%2', i95SyncLogEntry."Log Status"::"In-Progress", i95SyncLogEntry."Log Status"::New);
        //Need to check this field usage
        i95SyncLogEntry.SetRange("PullData Status", i95SyncLogEntry."PullData Status"::"Data Received");
        if i95SyncLogEntryNo <> 0 then
            i95SyncLogEntry.SetRange("Entry No", i95SyncLogEntryNo);
        If i95SyncLogEntry.FindSet() then
            repeat
                Clear(i95UpdateDataCU);
                Commit();
                i95UpdateDataCU.SetParamaters(i95SyncLogEntry."Entry No");
                if not i95UpdateDataCU.Run() then begin
                    i95SyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                    i95SyncLogEntry."Log Status" := i95SyncLogEntry."Log Status"::Error;
                    i95SyncLogEntry."Status ID" := i95SyncLogEntry."Status ID"::Error;
                    i95SyncLogEntry.modify();
                end
            until i95SyncLogEntry.next() = 0;
    end;
    // end;

    procedure SetParamaters(EntryNo: Integer)
    begin
        i95SyncLogEntryNo := EntryNo;
    end;

    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95UpdateDataCU: Codeunit "i95 Update Data to BC";
        i95SyncLogEntryNo: Integer;
}