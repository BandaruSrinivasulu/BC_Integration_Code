pageextension 70031 "i95 Location Card Ext" extends "Location Card"
{

    layout
    {
        // Add changes to page layout here
        addlast(content)
        {
            field("i95 Reference ID"; Rec."i95 Reference ID")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies Reference id';
                Caption = 'Reference ID';
            }
            field("i95 Sync Status"; Rec."i95 Sync Status")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies Sync Status';
                Caption = ' Sync Status';
            }
            field("i95 Last Sync DateTime"; Rec."i95 Last Sync DateTime")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies Last Sync DateTime';
                Caption = ' Last Sync DateTime';
            }
            field("i95 Created By"; Rec."i95 Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who created the Location';
                Caption = 'Created By';
            }
            field("i95 Created DateTime"; Rec."i95 Created DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of Location creation';
                Caption = 'Created DateTime';
            }
            field("i95 Creation Source"; Rec."i95 Creation Source")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the source of creation';
                Caption = 'Creation Source';
            }

        }
    }
    var
        [InDataSet]
        Showi95Fields: Boolean;

    trigger OnOpenPage();
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            Showi95Fields := UserSetup."i95 Show i95 Data";
    end;
}