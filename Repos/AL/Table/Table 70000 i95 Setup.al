Table 70000 "i95 Setup"
{
    Caption = 'i95Dev Setup';
    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Base Url"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Url';
        }
        field(3; "Login Email"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Login Email';
        }
        field(4; "Password"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Password';
            ExtendedDatatype = Masked;
        }
        field(5; "Subscription Key"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Subscription Key';
        }
        field(6; "Client ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Client ID';
        }
        field(7; "Authorization"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Authorization';
        }
        field(8; "Instance Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Staging,Production;
            OptionCaption = 'Staging,Production';
            Caption = 'Instance Type';
        }
        field(9; "Endpoint Code"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Endpoint Code';
        }
        field(11; "Scheduler Type"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Scheduler Type';
        }
        field(12; "Schedular ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Scheduler ID';
        }
        field(13; "Content Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = "Application/json";
            OptionCaption = 'Application/json';
            Caption = 'Content Type';
        }
        field(14; "i95 Default Warehouse"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Warehouse';
            TableRelation = Location;
        }
        field(15; "Default Guest Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Guest Customer No.';
            TableRelation = Customer;
        }
        field(16; "i95 Customer Posting Group"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Customer Posting Group';
            TableRelation = "Customer Posting Group";
        }
        field(17; "i95 Gen. Bus. Posting Group"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Gen. Business Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(18; "Default UOM"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
            Caption = 'Default UOM';
        }
        field(19; "Customer Nos."; Code[20])
        {
            Caption = 'Default Customer No Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Sales Order No Series';
            TableRelation = "No. Series";
        }
        field(21; "Pull Data Packet Size"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Pull Data Packet Size';
        }
        field(22; "Product Nos."; Code[20])
        {
            Caption = 'Default Item No Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(23; "i95 Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(24; "i95 Inventory Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Inventory Posting Group';
            TableRelation = "Inventory Posting Group";
        }
        field(25; "i95 Tax Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Tax Group Code';
            TableRelation = "Tax Group";
        }
        field(26; "i95 Use Item Nos. from E-COM"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Item Nos. from E-Commerce';
        }
        field(27; "i95 Shipping Charge G/L Acc"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Charge G/L Account';
            TableRelation = "G/L Account"."No." where("Account Type" = CONST(Posting), Blocked = CONST(false));
        }
        field(28; "i95 Item Variant Seperator"; Text[1])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Variant Seperator';
        }
        field(29; "i95 Item Variant Pattern 1"; text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Variant Pattern 1';
        }
        field(30; "i95 Item Variant Pattern 2"; text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Variant Pattern 2';
        }
        field(31; "i95 Item Variant Pattern 3"; text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Variant Pattern 3';
        }
        field(32; "IsConfigurationUpdated"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'IsConfigurationUpdated';
        }
        field(39; "I95 Default Template Name"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Cash Reciept Journal Template name';
            TableRelation = "Gen. Journal Template";
        }
        field(40; "I95 Default Batch Name"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Cash Reciept Batch name';
            trigger OnLookup()
            var
                GenJnlLine: Record "Gen. Journal Line";
                GenJnlManagement: Codeunit GenJnlManagement;
                GenJnlBatch: Record "Gen. Journal Batch";
            begin
                COMMIT;
                TestField("I95 Default Template Name");
                GenJnlBatch."Journal Template Name" := "I95 Default Template Name";
                GenJnlBatch.FILTERGROUP(2);
                GenJnlBatch.SETRANGE("Journal Template Name", GenJnlBatch."Journal Template Name");
                GenJnlBatch.FILTERGROUP(0);
                IF PAGE.RUNMODAL(0, GenJnlBatch) = ACTION::LookupOK THEN BEGIN
                    "I95 Default Batch Name" := GenJnlBatch.Name;
                    GenJnlLine.FILTERGROUP := 2;
                    GenJnlLine.SETRANGE("Journal Batch Name", "I95 Default Batch Name");
                    GenJnlLine.FILTERGROUP := 0;
                    IF GenJnlLine.FIND('-') THEN;
                END;
            end;
        }
        field(41; "i95 Enable Company"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Company';
        }
        field(42; "i95 Contact Nos."; Code[20])
        {
            Caption = 'Default Contact No Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(43; "i95 Enable BillPay"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable BillPay';
        }

        field(44; "Refreshtoken"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Refreshtoken';
        }
        field(45; "RefreshtokenExpirytime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'RefreshtokenExpireTime';
        }
        field(46; "accesstoken"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'accesstoken';
        }
        field(47; "accesstokenExpirytime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'accesstokenExpireTime';
        }
        field(48; "accesstokentime"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'accesstokentime';
        }
        field(49; "Refreshtokentime"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Refreshtokentime';
        }
        field(50; "accesstokendate"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'accesstokendate';
        }
        field(51; "Refreshtokendate"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Refreshtokendate';
        }
        field(52; "i95 Enable MultiWarehouse"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable MultiWarehouse';
        }
        field(53; "i95 Enable CustSpec Pricing"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Customer Specific Pricing';
        }
        field(54; "i95 Enable MSI"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable MSI';
        }
        field(55; "i95 Enable ProdAtriButeMapping"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Product Attribute Mapping';
        }
        field(56; "i95Dev EnableAllCustmr Pricing"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable All Customer Pricing';
        }

        field(57; "i95Dev CPG Pricing"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Enable Customer Price Group Pricing';
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        { }
    }

    procedure SetAuthorizationToken(NewAuthorizationToken: Text);
    var
        OutStreamL: OutStream;
        Refreshtokenkey: Text;
    begin
        Clear(Authorization);

        if NewAuthorizationToken = '' then
            exit;

        Authorization.CreateOutStream(OutStreamL, TextEncoding::Windows);
        OutStreamL.WriteText(NewAuthorizationToken);
        Modify();
        Clear(OutStreamL);
        Refreshtokenkey := DelStr(NewAuthorizationToken, 1, 7);
        Refreshtoken.CreateOutStream(OutStreamL, TextEncoding::Windows);
        OutStreamL.WriteText(Refreshtokenkey);
    end;

    procedure GetAuthorizationToken(): Text;
    var
        TypeHelper: Codeunit "Type Helper";
        CarriageReturn: Char;
        InStreamL: InStream;
    begin
        CalcFields(Authorization);
        if not Authorization.HasValue() then
            exit('');

        CarriageReturn := 10;

        Authorization.CreateInStream(InStreamL, TextEncoding::Windows);
        exit(TypeHelper.ReadAsTextWithSeparator(InStreamL, CarriageReturn));
    end;

}