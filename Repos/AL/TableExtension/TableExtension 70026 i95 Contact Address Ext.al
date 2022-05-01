tableextension 70026 ContactAddresExt extends "Contact Alt. Address"
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
        field(70011; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Requried for the currenct functionality';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Not Requried for the currenct functionality';
        }
        field(70014; "i95 Is Default Shipping"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Default Shipping';

            trigger OnValidate()
            begin
                if "i95 Is Default Shipping" then
                    Removei95DefaultShipping()
                else
                    if not Isi95DefaultShippingFound() then
                        Error(i95DefaultShippingErrorTxt);
            end;
        }

    }
    trigger OnBeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        Updatei95CustomerSyncStatus(Rec."Contact No.");
    end;

    trigger OnBeforeModify()
    Begin
        If (i95MandatoryFieldsUpdated()) then begin
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Sync DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            Updatei95CustomerSyncStatus(Rec."Contact No.");
        end;
    End;

    trigger OnBeforeDelete()
    Begin
        Updatei95CustomerSyncStatus(Rec."Contact No.");
    End;

    trigger OnBeforeRename()
    Begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
        Updatei95CustomerSyncStatus(Rec."Contact No.");
    End;

    procedure Updatei95CustomerSyncStatus(ContactNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Reset();
        Customer.SetRange("Primary Contact No.", ContactNo);
        IF Customer.FindFirst() then begin
            IF (Customer."i95 Sync Status" <> Customer."i95 Sync Status"::"InComplete Data") then begin
                Customer."i95 Last Modification DateTime" := CurrentDateTime();
                Customer."i95 Last Modified By" := copystr(UserId(), 1, 80);
                Customer."i95 Last Sync DateTime" := CurrentDateTime();
                Customer."i95 Sync Status" := Customer."i95 Sync Status"::"Waiting for Sync";
                Customer."i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
                Customer.Modify(false);
            end;
        end;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec."Company Name" = '') or (rec.Address = '') or (Rec.City = '') or (Rec."Country/Region Code" = '') or (Rec."Post Code" = '')
           or (Rec."Phone No." = '') then
            exit(false)
        else
            exit(true);
    end;

    procedure Removei95DefaultShipping(): Boolean
    var
        ContactAlternateAddress: Record "Contact Alt. Address";
    begin

        ContactAlternateAddress.Reset();
        ContactAlternateAddress.SetRange("Contact No.", Rec."Contact No.");
        ContactAlternateAddress.SetFilter(Code, '<>%1', Rec.Code);
        ContactAlternateAddress.SetRange("i95 Is Default Shipping", true);
        ContactAlternateAddress.ModifyAll("i95 Is Default Shipping", false);
    end;

    procedure Isi95DefaultShippingFound(): Boolean
    var
        ContactAlternateAddress: Record "Contact Alt. Address";
    begin
        ContactAlternateAddress.Reset();
        ContactAlternateAddress.SetRange("Contact No.", Rec."Contact No.");
        ContactAlternateAddress.SetFilter(Code, '<>%1', Rec.Code);
        ContactAlternateAddress.SetRange("i95 Is Default Shipping", true);
        exit(not ContactAlternateAddress.IsEmpty());
    end;

    var
        i95DefaultShippingErrorTxt: Label 'Default Shipping should be true for any one of the Contact Alternate Address.';


}