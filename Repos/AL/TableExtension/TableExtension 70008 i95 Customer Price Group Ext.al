Tableextension 70008 "i95 Customer Price Group Ext" extends "Customer Price Group"
{
    fields
    {
        field(70005; "i95 Created By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
        }
        field(70006; "i95 Created DateTime"; DateTime)
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
        field(70014; "i95 SalesPrice Ref Id"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Reference ID';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70015; "i95 SalesPrice Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70016; "i95 SP Last SyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Last Sync DateTime';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70017; "i95 SP Last Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Last Updated DateTime';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key4; "i95 Sync Status")
        { }
    }
    trigger OnBeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow CustGroup Outbound Sync" = true then begin
            If i95MandatoryFieldsUpdated() then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;
    end;

    trigger OnBeforeModify()
    Begin
        If (not UpdatedFromi95) and (i95MandatoryFieldsUpdated()) then begin
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Sync DateTime" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow CustGroup Outbound Sync" = true then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";

            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
        end;
    End;

    trigger OnRename()
    begin
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow CustGroup Outbound Sync" = true then begin
            IF Rec.Code <> xRec.Code then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;


    end;

    procedure Updatei95SyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := SyncStatus;
        "i95 Last Modification Source" := SyncSource;

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;

        Modify(false);
    end;

    procedure Updatei95SyncStatusforSyncComplete(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := "i95 Sync Status"::"Sync Complete";
        "i95 Last Modification Source" := SyncSource;
        Modify(false);
    end;

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec.Description = '') then begin
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    var
        UpdatedFromi95: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}
