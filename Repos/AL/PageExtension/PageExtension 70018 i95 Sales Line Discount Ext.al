pageextension 70018 "i95 Sales Line Discount" extends "Sales Line Discounts"
{
    layout
    {
        addafter("Ending Date")
        {
            field("i95 Created By"; Rec."i95 Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who created the Discount Price';
                Caption = 'Created By';
                Visible = Showi95Fields;
            }
            field("i95 Created DateTime"; Rec."i95 Created DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of discount price created';
                Caption = 'Created DateTime';
                Visible = Showi95Fields;
            }
            field("i95 Creation Source"; Rec."i95 Creation Source")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the source of creation';
                Caption = 'Creation Source';
                Visible = Showi95Fields;
            }

            field("i95 Last Modified By"; Rec."i95 Last Modified By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who last modified the discount price';
                Caption = 'Last Modified By';
                Visible = Showi95Fields;
            }
            field("i95 Last Modification DateTime"; Rec."i95 Last Modification DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of last modification';
                Caption = 'Last Modification DateTime';
                Visible = Showi95Fields;
            }
            field("i95 Last Modification Source"; Rec."i95 Last Modification Source")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the source of last modification';
                Caption = 'Last Modification Source';
                Visible = Showi95Fields;
            }

        }
        modify(SalesCode)
        {
            ShowMandatory = true;
        }
        modify(Code)
        {
            ShowMandatory = true;
        }
        modify("Line Discount %")
        {
            ShowMandatory = true;
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