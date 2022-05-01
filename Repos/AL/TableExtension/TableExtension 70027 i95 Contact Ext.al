tableextension 70027 "i95 Contact Ext" extends Contact
{
    fields
    {
        // Add changes to table fields here
        field(70000; "i95 Created By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
        }
        field(70001; "i95 Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
        }

        field(70007; "i95 Creation Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Source';
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Editable = false;
        }
        field(70008; "i95 Last Modified By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modified By';
            Editable = false;
        }
        field(70009; "i95 Last Modification DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modification DateTime';
            Editable = false;
        }
        field(70010; "i95 Last Modification Source"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Caption = 'Last Modification Source';
            Editable = false;
        }
        field(70011; "i95 Customer Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Admin","User";
            OptionCaption = ' ,Admin,User';
            Caption = 'Customer Type';
            ObsoleteState = Removed;
            ObsoleteReason = ' This field is not required as already have Type Field for Contact';

        }

        field(70012; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync DateTime';
            Editable = false;
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
            Editable = false;
        }
        field(70017; "i95 Synced"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Synced';
            Editable = false;
        }
        field(70018; "i95 Sync Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Message';
            Editable = false;
        }
        field(70019; "i95 Enable Forward Sync"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'i95 Enable Forward Sync';
            Editable = false;
        }


    }
    trigger OnBeforeInsert()
    begin
        CheckIfi95SyncAllowed();
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";


        If i95MandatoryFieldsUpdated() then begin
            IF (not UpdatedFromi95) then
                Rec."i95 Synced" := true;
            ContactL.Reset();
            ContactL.SetRange("No.", Rec."No.");
            IF ContactL.FindFirst() then begin
                ContactV.Reset();
                ContactV.SetRange("Company No.", ContactL."Company No.");
                IF ContactV.FindSet() then
                    repeat
                        ContactBusinessRelation.Reset();
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("Contact No.", ContactV."No.");
                        IF ContactBusinessRelation.FindFirst() then
                            repeat
                                Customer.Reset();
                                Customer.SetRange("No.", ContactBusinessRelation."No.");
                                Customer.SetRange("i95 Customer Type", Customer."i95 Customer Type"::Company);
                                IF Customer.FindFirst() then begin
                                    Customer."i95 Sync Status" := Customer."i95 Sync Status"::"Waiting for Sync";
                                    Customer."i95 Last Sync DateTime" := CurrentDateTime();
                                    Customer.Modify(false);
                                end;
                            until ContactBusinessRelation.Next() = 0;
                    until ContactV.Next() = 0;
            end;
        end;
    end;

    trigger OnBeforeModify()
    Begin
        CheckIfi95SyncAllowed();

        If i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            IF (not UpdatedFromi95) then
                Rec."i95 Synced" := true;

            ContactL.Reset();
            ContactL.SetRange("No.", Rec."No.");
            IF ContactL.FindFirst() then begin
                ContactV.Reset();
                ContactV.SetRange("Company No.", ContactL."Company No.");
                IF ContactV.FindSet() then
                    repeat
                        ContactBusinessRelation.Reset();
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("Contact No.", ContactV."No.");
                        IF ContactBusinessRelation.FindFirst() then
                            repeat
                                Customer.Reset();
                                Customer.SetRange("No.", ContactBusinessRelation."No.");
                                Customer.SetRange("i95 Customer Type", Customer."i95 Customer Type"::Company);
                                IF Customer.FindFirst() then begin
                                    Customer."i95 Sync Status" := Customer."i95 Sync Status"::"Waiting for Sync";
                                    Customer."i95 Last Sync DateTime" := CurrentDateTime();
                                    Customer.Modify(false);
                                end;
                            until ContactBusinessRelation.Next() = 0;
                    until ContactV.Next() = 0;
            end;
        end;
    End;

    trigger OnBeforeDelete()
    Begin
        IF (not UpdatedFromi95) then
            Rec."i95 Synced" := true;
        ContactL.Reset();
        ContactL.SetRange("No.", Rec."No.");
        IF ContactL.FindFirst() then begin
            ContactV.Reset();
            ContactV.SetRange("Company No.", ContactL."Company No.");
            IF ContactV.FindSet() then
                repeat
                    ContactBusinessRelation.Reset();
                    ContactBusinessRelation.SetRange("Business Relation Code", 'CUST');
                    ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                    ContactBusinessRelation.SetRange("Contact No.", ContactV."No.");
                    IF ContactBusinessRelation.FindFirst() then
                        repeat
                            Customer.Reset();
                            Customer.SetRange("No.", ContactBusinessRelation."No.");
                            Customer.SetRange("i95 Customer Type", Customer."i95 Customer Type"::Company);
                            IF Customer.FindFirst() then begin
                                Customer."i95 Sync Status" := Customer."i95 Sync Status"::"Waiting for Sync";
                                Customer."i95 Last Sync DateTime" := CurrentDateTime();
                                Customer.Modify(false);
                            end;
                        until ContactBusinessRelation.Next() = 0;
                until ContactV.Next() = 0;
        end;
    end;

    trigger OnBeforeRename()
    var

    Begin
        // CheckIfi95SyncAllowed();
        // If i95MandatoryFieldsUpdated() then begin
        IF (not UpdatedFromi95) then
            Rec."i95 Synced" := true;
        ContactL.Reset();
        ContactL.SetRange("No.", Rec."No.");
        IF ContactL.FindFirst() then begin
            ContactV.Reset();
            ContactV.SetRange("Company No.", ContactL."Company No.");
            IF ContactV.FindSet() then
                repeat
                    ContactBusinessRelation.Reset();
                    ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                    ContactBusinessRelation.SetRange("Contact No.", ContactV."No.");
                    IF ContactBusinessRelation.FindFirst() then
                        repeat

                            Customer.Reset();
                            Customer.SetRange("No.", ContactBusinessRelation."No.");
                            Customer.SetRange("i95 Customer Type", Customer."i95 Customer Type"::Company);
                            IF Customer.FindFirst() then begin
                                Customer."i95 Sync Status" := Customer."i95 Sync Status"::"Waiting for Sync";
                                Customer."i95 Last Sync DateTime" := CurrentDateTime();
                                Customer.Modify(false);
                            end;
                        until ContactBusinessRelation.Next() = 0;
                until ContactV.Next() = 0;
        end;
        //  end;

    End;

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec.Name = '') or (Rec."E-Mail" = '') or (Rec."i95 Sync Message" <> '') then
            exit(false)
        else
            exit(true);
    end;

    procedure CheckIfi95SyncAllowed()
    var
        i95CompanySyncErrorTxt: Label 'Company Admin of this %1 is not Synced to Ecommerce System';
    begin
        "i95 Sync Message" := '';

        IF not (Rec.Type = Rec.Type::Company) then begin
            ContactL.Reset();
            ContactL.SetRange("Company No.", Rec."Company No.");
            ContactL.SetRange(Type, ContactL.Type::Company);
            ContactL.SetRange("i95 Synced", true);
            IF ContactL.FindFirst() then begin
                "i95 Sync Message" := copystr(StrSubstNo(i95CompanySyncErrorTxt, Rec."No."), 1, 250);
            end;
        end;
    end;



    var
        ContactL: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactV: Record Contact;
        UpdatedFromi95: Boolean;

}