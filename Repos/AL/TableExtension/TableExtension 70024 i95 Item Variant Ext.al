tableextension 70024 "i95 Item Variant Ext" extends "Item Variant"
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
        field(70011; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
            Editable = false;
        }
        field(70012; "i95 Inventory Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Inventory Sync Status';
            OptionMembers = "Stock Not Initialised","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'Stock Not Initialised,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70013; "i95 Stock Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Stock Last Sync DateTime';
            Editable = false;
        }
        field(70014; "i95 Stock Last Update DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Stock Last Update DateTime';
            Editable = false;
        }
        field(70015; "i95 Enabled Sync"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled Sync';
            Editable = false;
        }
        field(70018; "i95 SalesPrice Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
    }

    keys
    {
        key(key2; "i95 Inventory Sync Status")
        { }
        key(key3; "i95 Reference ID")
        { }
    }

    trigger OnBeforeInsert()
    var
        Item: Record Item;
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then
            "i95 Enabled Sync" := true
        else
            "i95 Enabled Sync" := false;


        If i95MandatoryFieldsUpdated() then
            If item.get(Rec."Item No.") then begin

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                    Item."i95 ItemVariant Sync Status" := Item."i95 ItemVariant Sync Status"::"Waiting for Sync";
                    item."i95 Child Variant Sync Status" := item."i95 Child Variant Sync Status"::"Waiting for Sync";
                end;

                Item."i95 Sync Status" := Item."i95 Sync Status"::"InComplete Data";
                Item."i95 Reference ID" := '';
                CheckforItemDetSyncLogEntry(Item);
                Item.Modify(false);
            end;
    end;

    trigger OnBeforeModify()
    var
        Item: Record Item;
    Begin
        If (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then
                "i95 Enabled Sync" := true
            else
                "i95 Enabled Sync" := false;



            if Item.Get(Rec."Item No.") then begin
                Item."i95 Variant Updated DateTime" := CurrentDateTime();
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                    item."i95 ItemVariant Sync Status" := Item."i95 ItemVariant Sync Status"::"Waiting for Sync";
                    Item."i95 Child Variant Sync Status" := item."i95 Child Variant Sync Status"::"Waiting for Sync";
                end;

                Item."i95 Child Updated DateTime" := CurrentDateTime();
                Item."i95 Sync Status" := Item."i95 Sync Status"::"InComplete Data";
                Item."i95 Reference ID" := '';
                CheckforItemDetSyncLogEntry(Item);
                Item.Modify(false);
            end;
        end;
    End;

    trigger OnBeforeDelete()
    var
        Item: Record Item;
    Begin
        if Item.Get(Rec."Item No.") then begin
            Item."i95 Variant Updated DateTime" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                item."i95 ItemVariant Sync Status" := Item."i95 ItemVariant Sync Status"::"Waiting for Sync";
                Item."i95 Child Variant Sync Status" := item."i95 Child Variant Sync Status"::"Waiting for Sync";
            end;
            item."i95 Child Updated DateTime" := CurrentDateTime();

            Item.Modify(false);
        end;
    End;

    trigger OnBeforeRename()
    var
        Item: Record Item;
    Begin
        If (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then
                "i95 Enabled Sync" := true
            else
                "i95 Enabled Sync" := false;

            if xRec.Code <> Rec.Code then
                if Item.Get(Rec."Item No.") then begin
                    Item."i95 Variant Updated DateTime" := CurrentDateTime();

                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                        item."i95 ItemVariant Sync Status" := Item."i95 ItemVariant Sync Status"::"Waiting for Sync";
                        item."i95 Child Variant Sync Status" := Item."i95 Child Variant Sync Status"::"Waiting for Sync";
                    end;


                    Item."i95 Child Updated DateTime" := CurrentDateTime();

                    Item.Modify(false);
                end;

            if Item.Get(Rec."Item No.") then begin
                Item."i95 Variant Updated DateTime" := CurrentDateTime();
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                    item."i95 ItemVariant Sync Status" := Item."i95 ItemVariant Sync Status"::"Waiting for Sync";
                    item."i95 Child Variant Sync Status" := Item."i95 Child Variant Sync Status"::"Waiting for Sync";
                end;
                Item."i95 Child Updated DateTime" := CurrentDateTime();
                Item.Modify(false);
            end;
        End;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec.Code = '') or (Rec.Description = '') then
            exit(false)
        else
            exit(true);
    end;

    procedure UpdateReferenceId(ReferenceId: code[20])
    begin
        "i95 Reference ID" := ReferenceId;
        Modify(false);
    end;

    procedure Seti95InventoryPendingSync();
    begin
        "i95 Inventory Sync Status" := "i95 Inventory Sync Status"::"Waiting for Sync";
        "i95 Stock Last Update DateTime" := CurrentDateTime();
        Modify(false);
    end;

    procedure Updatei95InventorySyncStatus(SyncStatus: Option "Stock Not Initialised","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceId: code[20])
    begin
        "i95 Inventory Sync Status" := SyncStatus;
        "i95 Stock Last Sync DateTime" := CurrentDateTime();

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;

        Modify(false);
    end;

    procedure Updatei95SalesPriceSyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InCompleted","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 SalesPrice Sync Status" := SyncStatus;
        Modify(false);
    end;

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;






    procedure CheckforItemDetSyncLogEntry(Item: Record item)
    var
        DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
    begin
        DetSyncLogEntry.Reset();
        DetSyncLogEntry.SetRange(DetSyncLogEntry."Source Record ID", Item.RecordId());
        DetSyncLogEntry.SetFilter(DetSyncLogEntry."Sync Status", '<>%1', DetSyncLogEntry."Sync Status"::"Sync Complete");
        If DetSyncLogEntry.findset() then
            repeat
                DetSyncLogEntry.UpdateSyncLogEntry(DetSyncLogEntry."Sync Status"::"No Response", DetSyncLogEntry."Log Status"::Cancelled, DetSyncLogEntry."Http Response Code",
                                DetSyncLogEntry."API Response Result", DetSyncLogEntry."API Response Message",
                                DetSyncLogEntry."i95 Source Id",
                                DetSyncLogEntry."Message ID",
                                DetSyncLogEntry."Message Text",
                                DetSyncLogEntry."Status ID",
                                DetSyncLogEntry."Target ID", DetSyncLogEntry."Sync Source"::"Business Central");
            until DetSyncLogEntry.next() = 0;
    end;

    var
        UpdatedFromi95: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}