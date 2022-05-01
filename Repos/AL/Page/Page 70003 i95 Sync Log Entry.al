Page 70003 "i95 Sync Log Entry"
{
    PageType = List;
    SourceTable = "i95 Sync Log Entry";
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTableView = ORDER(Descending);
    Editable = false;
    Caption = 'i95Dev Sync Log Entries';
    layout
    {
        area(Content)
        {
            repeater("i95 Sync Log")
            {
                Caption = 'i95Dev Sync Log';
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sync log entry No.';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Sync DateTime"; Rec."Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Date Time';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("API Type"; Rec."API Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API Type';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    width = 15;
                }
                field("Sync Source"; Rec."Sync Source")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Sync Source';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 15;
                }
                field("Sync Status"; Rec."Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Status';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 20;
                    Visible = false;
                }
                field("API Status"; Rec."Log Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Log Status';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("No. Of Records"; Rec."No. Of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of records';
                }
                field("Waiting For Push/Pull"; Rec."Waiting For Push/Pull")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number Of records waiting for Push/Pull';
                }
                field("Waiting For Response"; Rec."Waiting For Response")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number Of records waiting for response';
                }
                field("Waiting For Acknowledgement"; Rec."Waiting For Acknowledgement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number Of records Waiting for acknowledgement';
                }
                field("Sync Completed"; Rec."Sync Completed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number Of records that has completed sync';
                }
                field("No. Of Errors"; Rec."No. Of Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of errors';
                }
                field("Http Response Code"; Rec."Http Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Http Response Code';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 10;
                }
                field("i95 Response Result"; Rec."Response Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Response Result';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("i95 Response Message"; Rec."Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Response Message';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 20;
                }
                field("Status ID"; Rec."Status ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Status ID';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    BlankZero = true;
                }
                field("i95 Source ID"; Rec."i95 Source ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Source ID';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Message ID"; Rec."Message ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Message ID';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    BlankZero = true;
                }
                field("PullData Status"; Rec."PullData Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Pull Data Status';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 20;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Error Message';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 40;
                }
            }
        }
        area(FactBoxes)
        {
            part(i95ApiSync; "i95 API Sync Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No" = field("Entry No");
            }
            part(i95ApiResponse; "i95 API Response Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No" = field("Entry No");
            }
            part(i95ApiAcknowledge; "i95 API Acknowledge Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No" = field("Entry No");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Process Response API")
            {
                Image = ChangeLog;
                ApplicationArea = All;
                trigger OnAction();
                var
                    ProcessResponseAPI: Codeunit "i95 Process Response Api";
                begin
                    ProcessResponseAPI.Run();
                end;
            }
            action("Process Acknowledgement API")
            {
                Image = ChangeBatch;
                ApplicationArea = All;
                trigger OnAction();
                var
                    ProcessResponseAckAPI: Codeunit "i95 Process Acknowledge Api";
                begin
                    ProcessResponseAckAPI.Run();
                end;
            }
            action("Process i95 Received Data")
            {
                Image = UpdateDescription;
                ApplicationArea = All;
                trigger OnAction();
                var
                    i95PullRequestCU: Codeunit "i95 Process Pulled Data";
                begin
                    i95PullRequestCU.Run();
                end;
            }
            /* action(RunJobqueuecod)
             {

                 Image = UpdateDescription;
                 ApplicationArea = All;
                 trigger OnAction();
                 var
                     RunJobQueue: Codeunit "i95 Job Queue API Calls";
                 begin
                     RunJobQueue.Run();
                 end;
             }*/

            action("Detailed Sync Log Entries")
            {
                Image = Reuse;
                ApplicationArea = All;
                RunObject = page "i95 Detailed Sync Log Entries";
                RunPageLink = "Sync Log Entry No" = field("Entry No");
            }

            action("Cancel Sync")
            {
                Image = CancelLine;
                ApplicationArea = all;
                trigger OnAction();
                var
                    DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
                    CancelSyncConfirmTxt: Label 'Are you sure to cancel the Sync process?';
                begin
                    if Confirm(CancelSyncConfirmTxt) then begin
                        Rec.UpdateSyncLogEntry(Rec."Sync Status"::"No Response", Rec."Log Status"::Cancelled, Rec."Http Response Code", Rec."Response Result", Rec."Response Message", Rec."Message ID", Rec."i95 Source ID", Rec."Status ID", Rec."Sync Source");
                        DetSyncLogEntry.Reset();
                        DetSyncLogEntry.SetCurrentKey("Sync Log Entry No");
                        DetSyncLogEntry.SetRange(DetSyncLogEntry."Sync Log Entry No", Rec."Entry No");
                        If DetSyncLogEntry.FindSet() then
                            repeat
                                DetSyncLogEntry.UpdateSyncLogEntry(DetSyncLogEntry."Sync Status"::"No Response", DetSyncLogEntry."Log Status"::Cancelled, DetSyncLogEntry."Http Response Code", DetSyncLogEntry."API Response Result", DetSyncLogEntry."API Response Message",
                                                DetSyncLogEntry."i95 Source ID", DetSyncLogEntry."Message ID", DetSyncLogEntry."Message Text", DetSyncLogEntry."Status ID", DetSyncLogEntry."Target ID", DetSyncLogEntry."Sync Source");
                            until DetSyncLogEntry.Next() = 0;
                    end;
                end;
            }
        }
    }
    trigger onaftergetrecord()
    begin
        Clear(ErrorLine);
        If ((Rec."Error Message" <> '') and (Rec."Status ID" = Rec."Status ID"::Error)) or (Rec."Response Result" = 'false') then
            ErrorLine := True;
    end;

    var
        ErrorLine: Boolean;
}