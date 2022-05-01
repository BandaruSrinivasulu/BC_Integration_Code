page 70011 "i95 API Call Log Entry"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "i95 API Call Log Entry";
    SourceTableView = ORDER(Ascending);
    Caption = 'i95Dev API Call Log Entries';
    Editable = FALSE;

    layout
    {
        area(Content)
        {
            repeater("API Call Log Entry")
            {
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Entry No.';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Sync Log Entry No"; Rec."Sync Log Entry No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Log Entry No.';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }
                field("Sync DateTime"; Rec."Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Date and Time';
                    Style = Attention;
                    StyleExpr = ErrorLine;

                }
                field("Sync Datetime in Sec"; Rec."i95 Sync Datetime in Sec")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Date and Time in Sec';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                }

                field("API Type"; Rec."API Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API Type';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 15;
                }
                field("Scheduler Type"; Rec."Scheduler Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Scheduler Type';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 15;
                }
                field("Sync Source"; Rec."Sync Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync source';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 15;
                }
                field("HTTP Response Code"; Rec."Http Response Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Http Response Code';
                    Style = Attention;
                    StyleExpr = ErrorLine;
                    Width = 10;
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
    }

    var
        ErrorLine: Boolean;
}