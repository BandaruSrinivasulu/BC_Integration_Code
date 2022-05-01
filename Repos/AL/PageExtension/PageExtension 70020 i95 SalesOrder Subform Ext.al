pageextension 70020 "i95 SalesOrder Subform Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("description")
        {
            field("i95 Variant Code"; Rec."Variant Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Variant Code for the Item Choosed';
                Caption = 'Variant Code';
            }
        }
    }

}