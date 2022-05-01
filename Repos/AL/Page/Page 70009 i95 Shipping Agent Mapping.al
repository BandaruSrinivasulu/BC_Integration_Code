page 70009 "i95 Shipping Agent Mapping"
{
    ApplicationArea = All;
    Caption = 'i95Dev Shipping Agent Mapping';
    PageType = List;
    SourceTable = "i95 Shipping Agent Mapping";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(ShippingAgentMApping)
            {
                field("E-Commerce Shipping Method Code"; Rec."E-Com Shipping Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies E-Commerce shipping method code.';
                }
                field("E-Commerce Shipping Description"; Rec."E-Com Shipping Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies E-Commerce shipping method description.';
                }
                field("BC Shipping Agent Code"; Rec."BC Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which BC shipping agent code';
                }
                field("BC Shipping Agent Service Code"; Rec."BC Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BC shipping agent service';
                }
            }
        }
    }
}