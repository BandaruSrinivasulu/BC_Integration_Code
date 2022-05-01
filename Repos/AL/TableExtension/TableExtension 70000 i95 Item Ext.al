Tableextension 70000 "i95 Item Ext" extends Item
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
        field(70014; "i95 Inventory Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Inventory Sync Status';
            OptionMembers = "Stock Not Initialised","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'Stock Not Initialised,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70015; "i95 Stock Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Stock Last Sync DateTime';
            Editable = false;
        }
        field(70016; "i95 Stock Last Update DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Stock Last Update DateTime';
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
        field(70019; "i95 SP Last SyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Last Sync DateTime';
            Editable = false;
        }
        field(70020; "i95 SP Last Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Price Last Updated DateTime';
            Editable = false;
        }
        field(70021; "i95 DiscountPrice Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Price Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70022; "i95 DiscPrice LastSyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Price Last Sync DateTime';
            Editable = false;
        }
        field(70023; "i95 DiscPrice Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Price Last Updated DateTime';
            Editable = false;
        }
        field(70024; "i95 ItemVariant Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Config Item Variant Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70025; "i95 Variant Last SyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Config Item Variant Last Sync DateTime';
            Editable = false;
        }
        field(70026; "i95 Variant Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Config Item Variant Last Updated DateTime';
            Editable = false;
        }
        field(70027; "i95 Child Variant Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Item Variant Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70028; "i95 Child Last SyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Item Variant Last Sync DateTime';
            Editable = false;
        }
        field(70029; "i95 Child Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Item Variant Last Updated DateTime';
            Editable = false;
        }
        field(70030; "i95 Dev Sync"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95 Dev Sync';
            OptionMembers = Disabled,Enabled;
            OptionCaption = 'Disabled,Enabled';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not needed.';
        }
    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key3; "i95 Sync Status")
        { }
        key(key4; "i95 Inventory Sync Status")
        { }
        key(key5; "i95 SalesPrice Sync Status")
        { }
        key(key6; "i95 DiscountPrice Sync Status")
        { }
        key(key7; "i95 ItemVariant Sync Status")
        { }
        key(key8; "i95 Child Variant Sync Status")
        { }
    }

    trigger OnBeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow Product Oubound Sync" = true then
            "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
    end;

    trigger OnBeforeModify()
    begin
        If (not UpdatedFromi95) then begin
            i95CheckSalesPriceUpdate();
            i95CheckDiscountUpdate();
            i95CheckItemVariantUpdate();
        end;

        if (not UpdatedFromi95) and i95MandatoryFieldsExists() and IsSimpleItem then begin
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Sync DateTime" := CurrentDateTime();

            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF (i95EntityMapping."Allow Product Oubound Sync" = true) then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";

            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
        end;

        IF not IsSimpleItem then begin
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow ItemVar Oubound Sync" = true then begin
                "i95 ItemVariant Sync Status" := "i95 ItemVariant Sync Status"::"Waiting for Sync";
                "i95 Child Variant Sync Status" := "i95 Child Variant Sync Status"::"Waiting for Sync";
            end;
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            "i95 Reference ID" := '';

            CheckforItemDetSyncLogEntry(Rec);
            Modify(false);
        end;
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

    procedure Updatei95SalesPriceSyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 SP Last Updated DateTime" := CurrentDateTime();
        "i95 SP Last SyncDateTime" := CurrentDateTime();
        "i95 SalesPrice Sync Status" := SyncStatus;

        Modify(false);
    end;

    procedure Updatei95DiscountPriceSyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 DiscountPrice Sync Status" := SyncStatus;
        "i95 DiscPrice LastSyncDateTime" := CurrentDateTime();
        "i95 DiscPrice Updated DateTime" := CurrentDateTime();
        Modify(false);
    end;

    procedure Updatei95ItemVariantSyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 ItemVariant Sync Status" := SyncStatus;
        "i95 Variant Last SyncDateTime" := CurrentDateTime();
        "i95 Variant Updated DateTime" := CurrentDateTime();
        "i95 Reference ID" := ReferenceID;
        Modify(false);
    end;

    procedure Updatei95ChildItemVariantSyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 Child Variant Sync Status" := SyncStatus;
        "i95 Child Last SyncDateTime" := CurrentDateTime();
        "i95 Child Updated DateTime" := CurrentDateTime();
        Modify(false);
    end;

    procedure Seti95InventoryPendingSync();
    begin
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow Inventory Oubound Sync" = true then
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

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure i95MandatoryFieldsExists(): Boolean
    begin
        //If (Rec.Description = '') or (Rec."Base Unit of Measure" = '') or (rec."Gen. Prod. Posting Group" = '') or (rec."Inventory Posting Group" = '') or (rec."Tax Group Code" = '') then begin
        If (Rec.Description = '') or (Rec."Base Unit of Measure" = '') or (rec."Gen. Prod. Posting Group" = '') or (rec."Inventory Posting Group" = '') then begin
            rec."i95 Sync Status" := rec."i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    procedure i95CheckSalesPriceUpdate()
    var
        SalPrice: Record "Sales Price";
        //SalPrice: Record "Price List Line";
        SalesPriceFieldsUpdated: Boolean;
    begin
        SalPrice.SetRange(SalPrice."Item No.", "No.");
        //SalPrice.SetRange("Asset Type", SalPrice."Asset Type"::Item);
        //SalPrice.SetRange("Asset No.", "No.");

        If SalPrice.FindSet() then
            repeat
                if SalPrice.i95MandatoryFieldsUpdated() then
                    SalesPriceFieldsUpdated := true
                else
                    SalesPriceFieldsUpdated := false;
            until (SalPrice.Next() = 0) or (not SalesPriceFieldsUpdated);

        If not SalesPriceFieldsUpdated then
            "i95 SalesPrice Sync Status" := "i95 SalesPrice Sync Status"::"InComplete Data";
    end;

    procedure i95CheckDiscountUpdate()
    var
        SalesLineDiscount: Record "Sales Line Discount";
        SalesLineDiscountUpdated: Boolean;
    begin
        SalesLineDiscount.Reset();
        SalesLineDiscount.SetRange(SalesLineDiscount.Type, SalesLineDiscount.Type::Item);
        SalesLineDiscount.SetRange(SalesLineDiscount.Code, "No.");
        if SalesLineDiscount.FindSet() then
            repeat
                if SalesLineDiscount.i95MandatoryFieldsUpdated() then
                    SalesLineDiscountUpdated := true
                else
                    SalesLineDiscountUpdated := false;
            until (SalesLineDiscount.Next() = 0) or (not SalesLineDiscountUpdated);

        If not SalesLineDiscountUpdated then
            "i95 DiscountPrice Sync Status" := "i95 DiscountPrice Sync Status"::"InComplete Data";
    end;

    procedure i95CheckItemVariantUpdate()
    var
        ItemVariant: Record "Item Variant";
        ItemVariantUpdated: Boolean;
    begin
        IsSimpleItem := true;

        ItemVariant.Reset();
        ItemVariant.SetRange(ItemVariant."Item No.", Rec."No.");
        If ItemVariant.FindSet() then
            repeat
                IsSimpleItem := false;

                if ItemVariant.i95MandatoryFieldsUpdated() then
                    ItemVariantUpdated := true
                else
                    ItemVariantUpdated := false;
            until (ItemVariant.Next() = 0) or (not ItemVariantUpdated);

        If (not ItemVariantUpdated) then begin
            Rec."i95 ItemVariant Sync Status" := "i95 ItemVariant Sync Status"::"InComplete Data";
            Rec."i95 Child Variant Sync Status" := "i95 Child Variant Sync Status"::"InComplete Data";
        end
    end;

    var
        UpdatedFromi95: Boolean;
        IsSimpleItem: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}