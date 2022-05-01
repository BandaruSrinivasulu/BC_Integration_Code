page 70008 "i95 Payment Methods Mapping"
{
    ApplicationArea = All;
    Caption = 'i95Dev Payment Method Mapping';
    PageType = List;
    SourceTable = "i95 Payment Methods Mapping";
    UsageCategory = Administration;
    layout
    {
        area(Content)
        {
            repeater("PaymentMethodMapping")
            {
                field("E-Commerce Payment Method Code"; Rec."E-Commerce Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies E-Commerce Payment Method.';
                }
                field("BC Payment Method Code"; Rec."BC Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies BC Payment Method.';
                }
                field("Ecommerce to BC Default"; Rec."Ecommerce to BC Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the BC payment method Code will be used as default for the selected E-Commerce payment method code';
                }
                field("BC to Ecommerce Default"; Rec."BC to Ecommerce Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the E-Commerce payment method Code will be used as default for the selected BC payment method code';
                }
            }
        }
    }
}