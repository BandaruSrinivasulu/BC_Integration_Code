Codeunit 70005 "i95 Process Acknowledge Api"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm;

    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95PushWebService: Codeunit "i95 Push Webservice";

    trigger OnRun()
    begin
        //with i95SyncLogEntry do begin
        //Sync Source = Business Central
        i95SyncLogEntry.Reset();
        i95SyncLogEntry.SetCurrentKey("Sync Source", "API Type", "Sync Status");
        i95SyncLogEntry.SetRange("Sync Source", i95SyncLogEntry."Sync Source"::"Business Central");
        i95SyncLogEntry.Setfilter("Waiting For Acknowledgement", '<>%1', 0);
        If i95SyncLogEntry.FindSet() then
            repeat
                i95PushWebService.SetSynclogEntryNo(i95SyncLogEntry."Entry No");
                i95PushWebService.ProcessPullResponseAcknowledgment(i95SyncLogEntry."API Type");
            until i95SyncLogEntry.next() = 0;
    end;
    //end;

}