PageExtension 70002 "i95 Posted Sales Shipment Ext" extends "Posted Sales Shipment"
{
    layout
    {
        modify("Package Tracking No.")
        {
            trigger OnAfterValidate()
            begin
                Rec.Updatei95Fields();
            end;
        }
        modify("Shipping Agent Code")
        {
            trigger OnAfterValidate()
            begin
                Rec.Updatei95Fields();
            end;
        }
        modify("Shipping Agent Service Code")
        {
            trigger OnAfterValidate()
            begin
                Rec.Updatei95Fields();
            end;
        }
        addafter(General)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Sync Status"; Rec."i95 Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev sync status';
                    Caption = 'Sync Status';
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
                field("i95 Sync Message"; Rec."i95 Sync Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message before Sync';
                    Caption = 'Sync Message';
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