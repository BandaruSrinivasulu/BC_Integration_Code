PageExtension 70003 "i95 Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addafter(General)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Sync Status"; Rec."i95 Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Sync status';
                    Caption = 'Sync Source';
                }
                field("i95 Last Sync DateTime"; Rec."i95 Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last i95Dev sync';
                    Caption = 'Last Sync DateTime';
                }
                field("i95 Reference ID"; Rec."i95 Reference ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Reference ID';
                    Caption = 'Reference ID';
                }
            }
        }
    }

    var
        [InDataSet]
        Showi95Fields: Boolean;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            Showi95Fields := UserSetup."i95 Show i95 Data"
    end;
}