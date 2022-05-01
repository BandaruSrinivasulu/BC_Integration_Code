Page 70010 "i95 Detailed Sync Log Entries"
{
    PageType = List;
    SourceTable = "i95 Detailed Sync Log Entry";
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTableView = ORDER(Ascending);
    Editable = false;
    Caption = 'i95Dev Detailed Sync Log Entries';
    layout
    {
        area(Content)
        {
            repeater("Detailed Sync Log Entry")
            {
                Caption = 'Detailed Sync Log Entry';
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry No.';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Sync Log Entry No"; Rec."Sync Log Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sync log entry No.';
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
                }
                field("API Status"; Rec."Log Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Log Status';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Http Response Code"; Rec."Http Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Http Response Code';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 10;
                }
                field("i95 Response Result"; Rec."API Response Result")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Response Result';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Response Message"; Rec."API Response Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Response Message';
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
                field("Target ID"; Rec."Target ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Target ID';
                    Style = Attention;
                    StyleExpr = ErrorLine;
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
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Table ID';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    BlankZero = true;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the Table Caption';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Error Message';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 40;
                }
                field("Field 1"; Rec."Field 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value that helps to identify the synced record';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 40;
                }
                field("Field 2"; Rec."Field 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value that helps to identify the synced record';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 40;
                }
                field("Field 3"; Rec."Field 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value that helps to identify the synced record';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 40;
                }
            }
            part(i95APILogSubPage; "i95 API Call Log Entry")
            {
                ApplicationArea = All;
                SubPageLink = "Sync Log Entry No" = field("Sync Log Entry No");
            }
        }

        area(FactBoxes)
        {
            part(i95ApiLogFactbox; "i95 API Log Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No" = field("Entry No");
                UpdatePropagation = SubPart;
                Provider = i95APILogSubPage;
            }
        }
    }

    trigger onaftergetrecord()
    begin
        Clear(ErrorLine);
        If ((Rec."Error Message" <> '') and (Rec."Status ID" = Rec."Status ID"::Error)) or (Rec."API Response Result" = 'false') then
            ErrorLine := True;
    end;

    var
        ErrorLine: Boolean;
}