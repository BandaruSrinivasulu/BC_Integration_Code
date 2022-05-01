table 70004 "i95 Payment Methods Mapping"
{
    Caption = 'i95Dev Payment Methods Mapping';
    DrillDownPageId = "i95 Payment Methods Mapping";
    LookupPageId = "i95 Payment Methods Mapping";

    fields
    {
        field(1; "E-Commerce Payment Method Code"; Code[50])
        {
            Caption = 'E-Commerce Payment Method Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "BC Payment Method Code"; Code[10])
        {
            Caption = 'BC Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
            NotBlank = true;
        }
        field(3; "Ecommerce to BC Default"; Boolean)
        {
            Caption = 'Ecommerce to BC Default';
            DataClassification = CustomerContent;

            trigger onvalidate()
            begin
                SetI95DefaultRecord();
            end;
        }
        field(4; "BC to Ecommerce Default"; Boolean)
        {
            Caption = 'BC to Ecommerce Default';
            DataClassification = CustomerContent;

            trigger Onvalidate()
            begin
                SetBCDefaultRecord();
            end;
        }
    }

    keys
    {
        key(Key1; "E-Commerce Payment Method Code", "BC Payment Method Code")
        {
        }
    }

    procedure SetBCDefaultRecord()
    var
        i95PaymentMethodMapping: Record "i95 Payment Methods Mapping";
    begin
        i95PaymentMethodMapping.SetRange("BC Payment Method Code", "BC Payment Method Code");
        i95PaymentMethodMapping.SetRange("BC to Ecommerce Default", true);
        if i95PaymentMethodMapping.FindFirst() then begin
            i95PaymentMethodMapping."BC to Ecommerce Default" := false;
            i95PaymentMethodMapping.Modify();
        end;
    end;

    procedure SetI95DefaultRecord()
    var
        i95PaymentMethodMapping: Record "i95 Payment Methods Mapping";
    begin
        i95PaymentMethodMapping.SetRange("E-Commerce Payment Method Code", "E-Commerce Payment Method Code");
        i95PaymentMethodMapping.SetRange("Ecommerce to BC Default", true);
        if i95PaymentMethodMapping.FindFirst() then begin
            i95PaymentMethodMapping."Ecommerce to BC Default" := false;
            i95PaymentMethodMapping.Modify();
        end;
    end;
}