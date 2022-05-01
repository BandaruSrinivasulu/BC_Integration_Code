Codeunit 70004 "i95 Process Response Api"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm, tabledata "Sales Cr.Memo Header" = rm, tabledata "Sales Cr.Memo Line" = rm;

    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95PullWebservice: Codeunit "i95 Pull Webservice";
        i95PushWebService: Codeunit "i95 Push Webservice";

    trigger OnRun()
    begin
        //with i95SyncLogEntry do begin

        //Sync Source = i95
        i95SyncLogEntry.Reset();
        i95SyncLogEntry.SetCurrentKey("Sync Source", "API Type", "Sync Status");
        i95SyncLogEntry.SetRange("Sync Source", i95SyncLogEntry."Sync Source"::i95);
        i95SyncLogEntry.SetFilter("Log Status", '%1 |%2 |%3', i95SyncLogEntry."Log Status"::"In-Progress", i95SyncLogEntry."Log Status"::New, i95SyncLogEntry."Log Status"::Error);
        i95SyncLogEntry.SetFilter("Waiting For Response", '<>%1', 0);
        If i95SyncLogEntry.FindSet() then
            repeat
                i95PullWebservice.SetSynclogEntryNo(i95SyncLogEntry."Entry No");
                i95PullWebservice.ProcessPushResponse(i95SyncLogEntry."API Type");
            until i95SyncLogEntry.next() = 0;

        i95SyncLogEntry.Reset();
        i95SyncLogEntry.SetCurrentKey("Sync Source", "API Type", "Sync Status");
        i95SyncLogEntry.SetRange("Sync Source", i95SyncLogEntry."Sync Source"::i95);
        i95SyncLogEntry.SetRange("Log Status", i95SyncLogEntry."Log Status"::"In-Progress");
        i95SyncLogEntry.SetFilter(i95SyncLogEntry."API Type", '<>%1', i95SyncLogEntry."API Type"::EntityManagement);
        If i95SyncLogEntry.FindSet() then
            repeat
                i95PullWebservice.SetSynclogEntryNo(i95SyncLogEntry."Entry No");
                i95PullWebservice.ProcessPushResponse(i95SyncLogEntry."API Type");
            until i95SyncLogEntry.next() = 0;

        //Sync Source = Business Central
        i95SyncLogEntry.Reset();
        i95SyncLogEntry.SetCurrentKey("Sync Source", "API Type", "Sync Status");
        i95SyncLogEntry.SetRange("Sync Source", i95SyncLogEntry."Sync Source"::"Business Central");
        i95SyncLogEntry.SetFilter("Waiting For Response", '<>%1', 0);
        If i95SyncLogEntry.FindSet() then
            repeat
                i95PushWebService.SetSynclogEntryNo(i95SyncLogEntry."Entry No");
                i95PushWebService.ProcessPullResponse(i95SyncLogEntry."API Type");
            until i95SyncLogEntry.next() = 0;
    end;
    //end;

}