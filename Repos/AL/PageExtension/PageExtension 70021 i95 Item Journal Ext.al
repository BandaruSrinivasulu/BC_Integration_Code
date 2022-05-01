pageextension 70021 "i95 Item Journal Ext" extends "Item Journal"
{
    layout
    {
        addafter("Location Code")
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