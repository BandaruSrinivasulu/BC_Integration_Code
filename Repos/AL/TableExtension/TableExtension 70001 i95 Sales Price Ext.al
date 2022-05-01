Tableextension 70001 "i95 Sales Price Ext" extends "Sales Price"
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

        field(70011; "i95 Enabled Sync"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled Sync';
            Editable = false;
        }

    }

    trigger OnBeforeInsert()
    var
        Item: Record Item;

    begin

        If not ("Sales Type" = "Sales Type"::Campaign) then begin
            //If "Source Type" = "Source Type"::"Customer Price Group" then begin
            "i95 Created By" := copystr(UserId(), 1, 80);
            "i95 Created DateTime" := CurrentDateTime();
            "i95 Creation Source" := "i95 Creation Source"::"Business Central";
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                "i95 Enabled Sync" := true
            else
                "i95 Enabled Sync" := false;


            If i95MandatoryFieldsUpdated() then
                //If item.get(Rec."Asset No.") then begin
                    If item.get(Rec."Item No.") then begin
                    IF Rec."Variant Code" = '' then begin//change
                        i95EntityMapping.Reset();
                        IF i95EntityMapping.FindSet() then;
                        IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                            Item."i95 SalesPrice Sync Status" := Item."i95 SalesPrice Sync Status"::"Waiting for Sync";
                    end;//
                    Item."i95 SP Last Updated DateTime" := CurrentDateTime();

                    Itemvariant.Reset();
                    Itemvariant.SetRange("Item No.", Rec."Item No.");
                    // Itemvariant.SetRange("Item No.", Rec."Asset No.");
                    Itemvariant.SetRange(Code, Rec."Variant Code");
                    IF Itemvariant.FindFirst() then begin
                        i95EntityMapping.Reset();
                        IF i95EntityMapping.FindSet() then;
                        IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                            Itemvariant."i95 SalesPrice Sync Status" := Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync";
                        Itemvariant.Modify(false);

                    end;

                    Item.Modify(false);
                end;
        end;
    end;

    trigger OnBeforeModify()
    var
        Item: Record Item;
    Begin
        If (not ("Sales Type" = "Sales Type"::Campaign)) and (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            //If ("Source Type" = "Source Type"::"Customer Price Group") and (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                "i95 Enabled Sync" := true
            else
                "i95 Enabled Sync" := false;


            if Item.Get(Rec."Item No.") then begin
                //    if Item.Get(Rec."Asset No.") then begin
                Item."i95 SP Last Updated DateTime" := CurrentDateTime();


                IF Rec."Variant Code" = '' then begin//change
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Item."i95 SalesPrice Sync Status" := Item."i95 SalesPrice Sync Status"::"Waiting for Sync";
                end;//

                Itemvariant.Reset();
                Itemvariant.SetRange("Item No.", Rec."Item No.");
                //Itemvariant.SetRange("Item No.", Rec."Asset No.");
                Itemvariant.SetRange(Code, Rec."Variant Code");
                IF Itemvariant.FindFirst() then begin
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Itemvariant."i95 SalesPrice Sync Status" := Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync";
                    Itemvariant.Modify(false);
                end;


                Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                Item.Modify(false);
            end;
        end;
    End;

    trigger OnBeforeDelete()
    var
        Item: Record Item;
    Begin
        If not ("Sales Type" = "Sales Type"::Campaign) then
            //If "Source Type" = "Source Type"::"Customer Price Group" then
            if Item.Get(Rec."Item No.") then begin
                //  if Item.Get(Rec."Asset No.") then begin
                Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                IF Rec."Variant Code" = '' then begin//change
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Item."i95 SalesPrice Sync Status" := Item."i95 SalesPrice Sync Status"::"Waiting for Sync";
                end;//

                Itemvariant.Reset();
                Itemvariant.SetRange("Item No.", Rec."Item No.");
                //Itemvariant.SetRange("Item No.", Rec."Asset No.");
                Itemvariant.SetRange(Code, Rec."Variant Code");
                IF Itemvariant.FindFirst() then begin
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Itemvariant."i95 SalesPrice Sync Status" := Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync";
                    Itemvariant.Modify(false);
                end;


                Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                Item.Modify(false);
            end;
    End;

    trigger OnBeforeRename()
    var
        Item: Record Item;
    Begin
        If (not ("Sales Type" = "Sales Type"::Campaign)) and (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            //If ("Source Type" = "Source Type"::"Customer Price Group") and (not UpdatedFromi95) and i95MandatoryFieldsUpdated() then begin
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                "i95 Enabled Sync" := true
            else
                "i95 Enabled Sync" := false;


            if xRec."Item No." <> Rec."Item No." then
                if Item.Get(xRec."Item No.") then begin
                    //        if xRec."Asset No." <> Rec."Asset No." then
                    //          if Item.Get(xRec."Asset No.") then begin
                    Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                    IF Rec."Variant Code" = '' then begin//change
                        i95EntityMapping.Reset();
                        IF i95EntityMapping.FindSet() then;
                        IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                            Item."i95 SalesPrice Sync Status" := Item."i95 SalesPrice Sync Status"::"Waiting for Sync";
                    end;//

                    Itemvariant.Reset();
                    Itemvariant.SetRange("Item No.", Rec."Item No.");
                    //Itemvariant.SetRange("Item No.", Rec."Asset No.");
                    Itemvariant.SetRange(Code, Rec."Variant Code");
                    IF Itemvariant.FindFirst() then begin
                        i95EntityMapping.Reset();
                        IF i95EntityMapping.FindSet() then;
                        IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                            Itemvariant."i95 SalesPrice Sync Status" := Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync";
                        Itemvariant.Modify(false);
                    end;


                    Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                    Item.Modify(false);
                end;

            if Item.Get(Rec."Item No.") then begin
                //if Item.Get(Rec."Asset No.") then begin
                Item."i95 SP Last Updated DateTime" := CurrentDateTime();

                IF Rec."Variant Code" = '' then begin//change
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Item."i95 SalesPrice Sync Status" := Item."i95 SalesPrice Sync Status"::"Waiting for Sync";
                end;//

                Itemvariant.Reset();
                Itemvariant.SetRange("Item No.", Rec."Item No.");
                //Itemvariant.SetRange("Item No.", Rec."Asset No.");
                Itemvariant.SetRange(Code, Rec."Variant Code");
                IF Itemvariant.FindFirst() then begin
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Tier Prices Oubound Sync" = true then
                        Itemvariant."i95 SalesPrice Sync Status" := Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync";
                    Itemvariant.Modify(false)
                end;



                Item."i95 SP Last Updated DateTime" := CurrentDateTime();
                Item.Modify(false);
            end;
        end;
    End;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (format(Rec."Sales Type") = '') or (Rec."Item No." = '') or (rec."Unit Price" = 0) then
            //If (Rec."Source No." = '') or (Rec."Asset No." = '') or (rec."Unit Price" = 0) then
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
        Itemvariant: Record "Item Variant";
}