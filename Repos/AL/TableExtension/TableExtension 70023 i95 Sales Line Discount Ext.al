tableextension 70023 "i95 Sales Line Discount Ext" extends "Sales Line Discount"
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
    }

    trigger OnBeforeInsert()
    var
        Item: Record Item;
        ItemDiscGrp: Record "Item Discount Group";
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        If i95MandatoryFieldsUpdated() then begin
            If (Type = Type::Item) and (item.get(Rec.Code)) then begin
                item."i95 DiscPrice Updated DateTime" := CurrentDateTime();

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    Item."i95 DiscountPrice Sync Status" := Item."i95 DiscountPrice Sync Status"::"Waiting for Sync";

                Item.Modify(false);
            end;
            If (Type = type::"Item Disc. Group") and (ItemDiscGrp.get(Rec.Code)) then begin
                ItemDiscGrp."i95 DiscPrice Updated DateTime" := CurrentDateTime();

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    ItemDiscGrp."i95 DiscountPrice Sync Status" := ItemDiscGrp."i95 DiscountPrice Sync Status"::"Waiting for Sync";

                ItemDiscGrp.Modify(false);
            end;
        end;
    end;

    trigger OnBeforeModify()
    var
        Item: Record Item;
        ItemDiscGrp: Record "Item Discount Group";
    Begin
        If (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";

            if ((Type = Type::Item) and (Item.Get(Rec.Code))) then begin
                Item."i95 DiscPrice Updated DateTime" := CurrentDateTime();

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    item."i95 DiscountPrice Sync Status" := Item."i95 DiscountPrice Sync Status"::"Waiting for Sync";
                Item.Modify(false);
            end;
            If (Type = type::"Item Disc. Group") and (ItemDiscGrp.get(Rec.Code)) then begin
                ItemDiscGrp."i95 DiscPrice Updated DateTime" := CurrentDateTime();

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    ItemDiscGrp."i95 DiscountPrice Sync Status" := ItemDiscGrp."i95 DiscountPrice Sync Status"::"Waiting for Sync";

                ItemDiscGrp.Modify(false);
            end;
        end;
    End;

    trigger OnBeforeDelete()
    var
        Item: Record Item;
        ItemDiscGrp: Record "Item Discount Group";
    Begin
        //If ("Sales Type" = "Sales Type"::"Customer Disc. Group") and (Type = Type::Item) then
        if (Type = Type::Item) and (Item.Get(Rec.Code)) then begin
            Item."i95 DiscPrice Updated DateTime" := CurrentDateTime();

            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                item."i95 DiscountPrice Sync Status" := Item."i95 DiscountPrice Sync Status"::"Waiting for Sync";

            Item.Modify(false);
        end;
        If (Type = type::"Item Disc. Group") and (ItemDiscGrp.get(Rec.Code)) then begin
            ItemDiscGrp."i95 DiscPrice Updated DateTime" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                ItemDiscGrp."i95 DiscountPrice Sync Status" := ItemDiscGrp."i95 DiscountPrice Sync Status"::"Waiting for Sync";
            ItemDiscGrp.Modify(false);
        end;
    End;

    trigger OnBeforeRename()
    var
        Item: Record Item;
        ItemDiscGrp: Record "Item Discount Group";
    Begin
        If (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";

            if xRec.Code <> Rec.Code then
                if Item.Get(xRec.Code) then begin
                    Item."i95 DiscPrice Updated DateTime" := CurrentDateTime();
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                        item."i95 DiscountPrice Sync Status" := Item."i95 DiscountPrice Sync Status"::"Waiting for Sync";
                    Item.Modify(false);
                end;

            if (Type = Type::Item) and (Item.Get(Rec.Code)) then begin
                Item."i95 DiscPrice Updated DateTime" := CurrentDateTime();
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    item."i95 DiscountPrice Sync Status" := Item."i95 DiscountPrice Sync Status"::"Waiting for Sync";
                Item.Modify(false);
            end;

            If (Type = type::"Item Disc. Group") and (ItemDiscGrp.get(Rec.Code)) then begin
                ItemDiscGrp."i95 DiscPrice Updated DateTime" := CurrentDateTime();
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow DiscPrice Oubound Sync" = true then
                    ItemDiscGrp."i95 DiscountPrice Sync Status" := ItemDiscGrp."i95 DiscountPrice Sync Status"::"Waiting for Sync";
                ItemDiscGrp.Modify(false);
            end;
        End;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If rec."Sales Type" <> Rec."Sales Type"::"All Customers" then begin
            If (Rec.Code = '') or (rec."Sales Code" = '') then
                exit(false)
            else
                exit(true);
        end else
            If (Rec.Code = '') then
                exit(false)
            else
                exit(true);
    end;

    procedure i95SetAPIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    var
        UpdatedFromi95: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}