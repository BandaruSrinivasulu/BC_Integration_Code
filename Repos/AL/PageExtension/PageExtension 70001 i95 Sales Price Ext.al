PageExtension 70001 "i95 Sales Price Ext" extends "Sales Prices"
{
    layout
    {
        addlast(content)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Created By"; Rec."i95 Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the Sales Price';
                    Caption = 'Created By';
                }
                field("i95 Created DateTime"; Rec."i95 Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of sales price created';
                    Caption = 'Created DateTime';
                }
                field("i95 Creation Source"; Rec."i95 Creation Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of creation';
                    Caption = 'Creation Source';
                }

                field("i95 Last Modified By"; Rec."i95 Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the sales price';
                    Caption = 'Last Modified By';
                }
                field("i95 Last Modification DateTime"; Rec."i95 Last Modification DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last modification';
                    Caption = 'Last Modification DateTime';
                }
                field("i95 Last Modification Source"; Rec."i95 Last Modification Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of last modification';
                    Caption = 'Last Modification Source';
                }
            }
        }
        modify("Sales Code")
        {
            ShowMandatory = true;
        }
        /*modify(SourceNo)
        {
            ShowMandatory = true;
        }*/

        modify("Item No.")
        {
            ShowMandatory = true;
        }
        /* modify("Asset No.")
         {
             ShowMandatory = true;
         }*/

        modify("Unit Price")
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