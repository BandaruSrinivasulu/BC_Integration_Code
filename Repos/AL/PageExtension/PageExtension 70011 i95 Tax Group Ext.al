pageextension 70011 "i95 Tax Group Ext" extends "Tax Groups"
{
    layout
    {
        addafter(Description)
        {
            field("i95 Created By"; Rec."i95 Created By")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies who Created the item ';
                Caption = 'Created By';
            }
            field("i95 Created DateTime"; Rec."i95 Created DateTime")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies the Created Date Time';
                Caption = 'Created DateTime';
            }
            field("i95 Last Modification DateTime"; Rec."i95 Last Modification DateTime")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies the date time of last modification';
                Caption = 'Last Modification DateTime';
            }
            field("i95 Sync Status"; Rec."i95 Sync Status")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies the i95Dev Sync Status';
                Caption = 'i95Dev Sync Status';
            }
            field("i95 Last Sync DateTime"; Rec."i95 Last Sync DateTime")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies the date time of last sync';
                Caption = 'Last Sync DateTime';
            }
            field("i95 Reference ID"; Rec."i95 Reference ID")
            {
                ApplicationArea = All;
                Visible = Showi95Fields;
                ToolTip = 'Specifies the i95Dev Reference ID';
                Caption = 'Reference ID';
            }
        }
        modify(Description)
        {
            ShowMandatory = true;
        }
        modify(Code)
        {
            ShowMandatory = true;
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