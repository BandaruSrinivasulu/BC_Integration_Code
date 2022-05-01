table 70005 "i95 Shipping Agent Mapping"
{
    Caption = 'i95Dev Shipping Agent Mapping';
    DrillDownPageId = "i95 Shipping Agent Mapping";
    LookupPageId = "i95 Shipping Agent Mapping";

    fields
    {
        field(1; "E-Com Shipping Method Code"; Code[50])
        {
            Caption = 'E-Commerce Shipping Method Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "E-Com Shipping Description"; Text[50])
        {
            Caption = 'E-Commerce Shipping Description';
            DataClassification = CustomerContent;
        }
        field(3; "BC Shipping Agent Code"; Code[10])
        {
            Caption = 'BC Shipping Agent Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent";
        }
        field(4; "BC Shipping Agent Service Code"; Code[10])
        {
            Caption = 'BC Shipping Agent Service Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipping Agent Services".Code WHERE("Shipping Agent Code" = FIELD("BC Shipping Agent Code"));
        }
    }

    keys
    {
        key(Key1; "E-Com Shipping Method Code")
        {
        }
    }
}