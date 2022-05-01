codeunit 70012 "i95 Create Body Content"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm;

    var
        BodyContentjsonObj: JsonObject;
        FirstRecord: Boolean;
        LocalMessageID: Integer;
        EntityID: Integer;
        SyncCounter: Integer;
        MessageStatus: Integer;
        SchedulerID: Integer;
        SalesLine: Record "Sales Line";
        Salesheader: Record "Sales Header";

    procedure AddContextHeader(var BodyContent: Text; SchedulerType: Text)
    var
        i95Setup: Record "i95 Setup";
        SchedulerIDL: Integer;
        ContextHdrjsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
    begin
        clear(BodyContentjsonObj);
        i95Setup.Get();
        FirstRecord := true;
        if i95Setup."Schedular ID" = '' then
            SchedulerIDL := 0
        else
            Evaluate(SchedulerIDL, i95Setup."Schedular ID");

        ContextHdrjsonObj.Add('clientId', i95Setup."Client ID");
        ContextHdrjsonObj.Add('subscriptionKey', i95Setup."Subscription Key");
        ContextHdrjsonObj.Add('instanceType', format(i95Setup."Instance Type"));
        ContextHdrjsonObj.Add('requestType', 'Target');
        If SchedulerType = 'PushResponse' then
            ContextHdrjsonObj.Add('schedulerType', 'PullData')
        else
            if SchedulerType = 'PushDatas' then
                ContextHdrjsonObj.Add('schedulerType', 'PushData')
            else
                ContextHdrjsonObj.Add('schedulerType', SchedulerType);
        ContextHdrjsonObj.Add('schedulerId', SchedulerIDL);
        ContextHdrjsonObj.Add('IsNotEncrypted', true);
        ContextHdrjsonObj.Add('endpointCode', i95Setup."Endpoint Code");

        BodyContentjsonObj.Add('context', ContextHdrjsonObj);

        if (UpperCase(SchedulerType) = 'PUSHDATAS') or (UpperCase(SchedulerType) = 'PULLDATA') then begin
            BodyContentjsonObj.Add('packetSize', i95Setup."Pull Data Packet Size");
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);
        end;
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure AddContextFooter(var BodyContent: Text)
    begin

    end;

    procedure RefreshTokenpullData(var BodyContent: Text; SchedulerType: Text)
    var
        i95Setup: Record "i95 Setup";
        SchedulerIDL: Integer;
        ContextHdrjsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RefreshTokenText: Text;
        RefreshInstream: InStream;
    begin
        clear(BodyContentjsonObj);
        Clear(RefreshTokenText);
        i95Setup.Get();
        i95Setup.CalcFields(Refreshtoken);

        i95Setup.Refreshtoken.CreateInStream(RefreshInstream, TextEncoding::Windows);
        RefreshInstream.ReadText(RefreshTokenText);
        //ContextHdrjsonObj.Add('refreshToken', 'eyJraWQiOiJjcGltY29yZV8wOTI1MjAxNSIsInZlciI6IjEuMCIsInppcCI6IkRlZmxhdGUiLCJzZXIiOiIxLjAifQ..lH_0N_dfufXoswZz.9kDkcpeRdml5r72BgBAMRHFA27xDF7wrjdH7NB8lCQmENakmn0iMOpGOBmUluZIIjE5uuk-b4qUpqnT09ZWYjqhVj_hZbzxcxL94TyYKXyTmNm3dgkKvh1iOW4vq27sqwr5sXKDcuTYIsNrqrs4yxPQTDmI095EcWwqwm8mlgTXkXprsoJ0nPOvsOPGVq4fIGcoZVeD3DS3oKHsQQReYgrBx_JjpfTiU-sUBBPXdw3z-dioBiILs7IdF1JUiXiQ6bGuEVxWCc3MVl_BB_1usBh9xg1DCSlTjUP5OEmKNnV4Nm-vrBJF1TBr_f2hKhZCWgD0HnoeFresmnQFdV6C9IDd0mID1a3h6ysrIX5Hhoqt4Zr-7yZvOm-MXvPfnMRoegqC4HQ_a_WVLatK3l4YD_o9tUOBz483sFqFmod5xqb4wicC3MkYSPjNokHMCnN_GPg6BbYgwBZo0Rn_eZnzfQVS1aw6C6cEckhrwTS83ETuvlBKOt11c-sE7xnds3pP_LnJFjtn82RfIDcBPVf7kQMQ7LuR7R2pGrgJTmkhjLNS1La7BpLVirfTkXkiiRgGm4SuYiIOznEzLzV0VW9G5ok9PSE6Vn6xKKneTSw.NK--pdw6fodxfgnIBDPW7Q');

        ContextHdrjsonObj.Add('refreshToken', RefreshTokenText);
        ContextHdrjsonObj.WriteTo(BodyContent);
    end;

    procedure ProductPushData(Item: Record Item; var BodyContent: text)
    var
        i95Setup: Record "i95 Setup";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        warehouseQuantityEntityJsonArr: JsonArray;
        warehouseQuantityEntityJsonObj: JsonObject;
        warehouseQuantityEntityJsonToken: JsonToken;
        Location: Record Location;
        ItemL: Record Item;
    begin
        i95Setup.get();

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Item.Description);

        InputDataJsonObj.Add('sku', Item."No.");
        InputDataJsonObj.Add('name', Item.Description);
        InputDataJsonObj.Add('description', Item.Description);
        InputDataJsonObj.Add('shortDescription', Item."Search Description");
        InputDataJsonObj.Add('cost', format(Item."Unit Cost"));
        InputDataJsonObj.Add('targetId', Item."No.");
        InputDataJsonObj.Add('reference', Item.Description);
        InputDataJsonObj.Add('weight', format(Item."Gross Weight"));
        InputDataJsonObj.Add('price', format(Item."Unit Price"));
        If Item."Base Unit of Measure" <> '' then
            InputDataJsonObj.Add('unitOfMeasure', Item."Base Unit of Measure")
        else
            InputDataJsonObj.Add('unitOfMeasure', i95Setup."Default UOM");
        i95Setup.Get();
        IF i95Setup."i95 Enable MultiWarehouse" = true then begin
            InputDataJsonObj.Add('warehouseQuantityEntity', warehouseQuantityEntityJsonArr);
            InputDataJsonObj.Get('warehouseQuantityEntity', warehouseQuantityEntityJsonToken);
            warehouseQuantityEntityJsonArr := warehouseQuantityEntityJsonToken.AsArray();

            Location.FindSet();
            repeat
                ItemL.Reset();
                ItemL.SetRange("No.", Item."No.");
                ItemL.SETFILTER("Location Filter", '=%1', Location.Code);
                IF ItemL.FindFirst() then begin
                    ItemL.CALCFIELDS(Inventory);
                    clear(warehouseQuantityEntityJsonObj);
                    warehouseQuantityEntityJsonObj.Add('warehouseId', Location.Code);
                    warehouseQuantityEntityJsonObj.Add('warehouseQuantity', ItemL.Inventory);
                    warehouseQuantityEntityJsonObj.Add('warehousePrice', ItemL."Unit Price");
                end;
                warehouseQuantityEntityJsonArr.Add(warehouseQuantityEntityJsonObj);
            until Location.Next() = 0;
        end;
        InputDataJsonObj.Add('status', 1);
        InputDataJsonObj.Add('Taxable Goods', 0);
        InputDataJsonObj.Add('qty', 0);
        InputDataJsonObj.Add('taxProductPostingGroupCode', Item."VAT Prod. Posting Group");
        InputDataJsonObj.Add('itemDiscountGroupId', Item."Item Disc. Group");
        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', Item."No.");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ProductPushDatawithMapping(Item: Record Item; var BodyContent: text)
    var
        i95Setup: Record "i95 Setup";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ProductAttributeMapping: Record "i95 Product Attribute Mapping";
        ItemRef: RecordRef;
        ItemFieldRef: FieldRef;
        index: Integer;
        ItemRecordRef: RecordRef;
        Fieldvalue: Text;
        Fieldcount: Integer;
    begin
        Clear(Fieldcount);
        ItemRef.GetTable(Item);
        //ItemRef.Open(Database::Item);
        Fieldcount := ItemRef.FieldCount;
        ProductAttributeMapping.Reset();
        IF ProductAttributeMapping.FindSet() then
            i95Setup.get();
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Item.Description);
        Clear(index);
        repeat
            index := 0;
            repeat
                Clear(Fieldvalue);
                index := index + 1;
                ItemFieldRef := ItemRef.FieldIndex(Index);

                IF ItemFieldRef.Name = ProductAttributeMapping.BCAttribute then begin

                    if ItemFieldRef.Name = 'Base Unit of Measure' then begin

                        iF format(ItemFieldRef.Value) <> '' then
                            InputDataJsonObj.Add(Format(ProductAttributeMapping.BCAttribute), format(ItemFieldRef.Value))
                        else
                            InputDataJsonObj.Add(Format(ProductAttributeMapping.BCAttribute), i95Setup."Default UOM");
                    end else begin
                        Fieldvalue := ItemFieldRef.Value;
                        //Message('%1', Fieldvalue);
                        //  iF not (ItemFieldRef.Name = 'Description') then

                        InputDataJsonObj.Add(Format(ProductAttributeMapping.BCAttribute), Fieldvalue);
                    end;
                end;

                InputDataJsonObj.WriteTo(BodyContent);

            until index = Fieldcount;

        Until ProductAttributeMapping.Next() = 0;

        /* InputDataJsonObj.Add('status', 1);
         InputDataJsonObj.Add('Taxable Goods', 0);
         InputDataJsonObj.Add('qty', 0);*/
        InputDataJsonObj.Add('targetId', Item."No.");
        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', Item."No.");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ProductAttributePushData(Item: Record Item; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        Valuechar: Char;
        ItemRef: RecordRef;
        ItemFieldRef: FieldRef;
        FieldIndex: Integer;
        ItemFieldType: FieldType;
        ItemFieldLength: Integer;
        Varchar: Char;
        ItemFieldRefText: Text;
        ItemFieldTypeText: Text;
        ItemFieldLengthText: Text;
        fieldcount: Integer;
    begin
        BodyContentjsonObj.Add('RequestData', RequestDataJsonArr);

        Clear(FieldIndex);
        ItemRef.Open(Database::Item);
        fieldcount := ItemRef.FieldCount;
        Repeat
            Clear(PushDatajsonObj);
            Clear(RequestDataJsonArr);
            BodyContentjsonObj.Get('RequestData', RequestDataJsonToken);
            RequestDataJsonArr := RequestDataJsonToken.AsArray();

            Clear(ItemFieldType);
            FieldIndex := FieldIndex + 1;

            ItemFieldRef := ItemRef.FieldIndex(FieldIndex);
            ItemFieldType := ItemFieldRef.Type;
            ItemFieldLength := ItemFieldRef.Length;

            Valuechar := '\';
            RequestDataJsonArr.Add('{');
            RequestDataJsonArr.Add(format(Valuechar));
            // RequestDataJsonArr.Add('Attribute\');
            RequestDataJsonArr.Add('name\');
            RequestDataJsonArr.Add(':');
            RequestDataJsonArr.Add(format(Valuechar));
            RequestDataJsonArr.Add(Format(ItemFieldRef.Name) + Valuechar);
            RequestDataJsonArr.Add(format(Valuechar));
            //RequestDataJsonArr.Add('AttributeType\');
            RequestDataJsonArr.Add('dataType\');
            RequestDataJsonArr.Add(':');
            RequestDataJsonArr.Add(format(Valuechar));
            RequestDataJsonArr.Add(Format(ItemFieldType) + Valuechar);
            RequestDataJsonArr.Add(format(Valuechar));
            //RequestDataJsonArr.Add('AttributeSize\');
            RequestDataJsonArr.Add('size\');
            RequestDataJsonArr.Add(':');
            RequestDataJsonArr.Add(format(Valuechar));
            RequestDataJsonArr.Add(Format(ItemFieldLength) + Valuechar);
            RequestDataJsonArr.Add(format(Valuechar));
            RequestDataJsonArr.Add('type\');
            RequestDataJsonArr.Add(':');
            RequestDataJsonArr.Add(format(Valuechar));
            RequestDataJsonArr.Add('default' + Valuechar);
            ;
            RequestDataJsonArr.Add('}');
            BodyContentjsonObj.WriteTo(BodyContent);
        Until FieldIndex = fieldcount;

        BodyContent := BodyContent.Replace('"{",', '{');
        BodyContent := BodyContent.Replace(',"}"', '}');
        BodyContent := BodyContent.Replace(',":",', ':');
        BodyContent := BodyContent.Replace('"\\",', '\');
        BodyContent := BodyContent.Replace('\\', '\');
        BodyContent := BodyContent.Replace('[', '"[');
        BodyContent := BodyContent.Replace(']', ']"');
    end;


    procedure InventoryPushData(Item: Record Item; InventoryString: Text; var BodyContent: text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        warehouseQuantityEntityJsonArr: JsonArray;
        warehouseQuantityEntityJsonObj: JsonObject;
        warehouseQuantityEntityJsonToken: JsonToken;
        Location: Record Location;
        ItemL: Record Item;
        i95Setup: Record "i95 Setup";
        EntityMapping: Record "i95 Entity Mapping";
        Salesline: Record "Sales Line";
        Salesheader: Record "Sales Header";
        OutstandingQty: Decimal;
    begin
        Clear(OutstandingQty);
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Item.Description);

        InputDataJsonObj.Add('sku', format(Item."No."));
        InputDataJsonObj.Add('targetId', format(Item."No."));
        InputDataJsonObj.Add('reference', Item.Description);
        i95Setup.Get();
        IF i95Setup."i95 Enable MultiWarehouse" = true then begin
            InputDataJsonObj.Add('warehouseQuantityEntity', warehouseQuantityEntityJsonArr);
            InputDataJsonObj.Get('warehouseQuantityEntity', warehouseQuantityEntityJsonToken);
            warehouseQuantityEntityJsonArr := warehouseQuantityEntityJsonToken.AsArray();

            Location.FindSet();
            repeat
                ItemL.Reset();
                ItemL.SetRange("No.", Item."No.");
                ItemL.SETFILTER("Location Filter", '=%1', Location.Code);
                IF ItemL.FindFirst() then begin
                    ItemL.CALCFIELDS(Inventory);
                    clear(warehouseQuantityEntityJsonObj);
                    warehouseQuantityEntityJsonObj.Add('warehouseId', Location.Code);
                    IF not (i95Setup."i95 Enable MSI" = true) then begin
                        ItemL.CalcFields("Qty. on Sales Order");
                        warehouseQuantityEntityJsonObj.Add('warehouseQuantity', ItemL.Inventory - ItemL."Qty. on Sales Order");
                    end else begin
                        IF EntityMapping.FindSet() then;
                        IF EntityMapping."Allow SalesOrder Oubound Sync" = false then begin
                            Salesheader.Reset();
                            Salesheader.SetRange("i95 Creation Source", Salesheader."i95 Creation Source"::"Business Central");
                            Salesheader.SetRange("Document Type", Salesheader."Document Type"::Order);
                            IF Salesheader.FindSet() then
                                repeat
                                    Salesline.Reset();
                                    Salesline.SetRange("Document Type", Salesheader."Document Type"::Order);
                                    Salesline.SetRange("Document No.", Salesheader."No.");
                                    Salesline.SetRange(Type, Salesline.Type::Item);
                                    Salesline.SetRange("No.", ItemL."No.");
                                    Salesline.SetRange("Location Code", Location.Code);
                                    IF Salesline.FindSet() then
                                        repeat
                                            OutstandingQty += Salesline."Outstanding Qty. (Base)";
                                        until Salesline.Next() = 0;
                                until Salesheader.Next() = 0;
                            ItemL.CALCFIELDS(Inventory);

                            warehouseQuantityEntityJsonObj.Add('warehouseQuantity', ItemL.Inventory - OutstandingQty);
                        end else begin
                            ItemL.CALCFIELDS(Inventory);
                            warehouseQuantityEntityJsonObj.Add('warehouseQuantity', ItemL.Inventory);
                        end;

                    end;
                    warehouseQuantityEntityJsonObj.Add('warehousePrice', ItemL."Unit Price");
                end;
                warehouseQuantityEntityJsonArr.Add(warehouseQuantityEntityJsonObj);
            until Location.Next() = 0;
            Item.CalcFields(Inventory);
            Item.CalcFields("Qty. on Sales Order");
            InputDataJsonObj.Add('qty', Item.Inventory - Item."Qty. on Sales Order");

        end else begin
            InputDataJsonObj.Add('qty', InventoryString);
        end;
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(Item."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure VariantInventoryPushData(ItemVariant: Record "Item Variant"; InventoryString: Text; var BodyContent: text)
    var
        i95Setup: Record "i95 Setup";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        warehouseQuantityEntityJsonArr: JsonArray;
        warehouseQuantityEntityJsonObj: JsonObject;
        warehouseQuantityEntityJsonToken: JsonToken;
        Location: Record Location;
        ItemL: Record Item;
        Item: Record Item;
    begin
        i95Setup.Get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', ItemVariant.Description);

        InputDataJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        InputDataJsonObj.Add('targetId', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        InputDataJsonObj.Add('reference', ItemVariant.Description);
        i95Setup.Get();
        IF i95Setup."i95 Enable MultiWarehouse" = true then begin
            InputDataJsonObj.Add('warehouseQuantityEntity', warehouseQuantityEntityJsonArr);
            InputDataJsonObj.Get('warehouseQuantityEntity', warehouseQuantityEntityJsonToken);
            warehouseQuantityEntityJsonArr := warehouseQuantityEntityJsonToken.AsArray();

            Location.FindSet();
            repeat
                ItemL.Reset();
                ItemL.SetRange("No.", ItemVariant."Item No.");
                ItemL.SETFILTER("Location Filter", '=%1', Location.Code);
                IF ItemL.FindFirst() then begin
                    ItemL.CALCFIELDS(Inventory);
                    ItemL.CalcFields("Qty. on Sales Order");
                    clear(warehouseQuantityEntityJsonObj);
                    warehouseQuantityEntityJsonObj.Add('warehouseId', Location.Code);
                    warehouseQuantityEntityJsonObj.Add('warehouseQuantity', ItemL.Inventory - ItemL."Qty. on Sales Order");
                    warehouseQuantityEntityJsonObj.Add('warehousePrice', ItemL."Unit Price");
                end;
                warehouseQuantityEntityJsonArr.Add(warehouseQuantityEntityJsonObj);
            until Location.Next() = 0;
            ItemL.CalcFields(Inventory);
            ItemL.CalcFields("Qty. on Sales Order");
            InputDataJsonObj.Add('qty', ItemL.Inventory - ItemL."Qty. on Sales Order");

        end else begin
            InputDataJsonObj.Add('qty', InventoryString);
        end;
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ConfigurableProductPushData(Item: Record Item; var BodyContent: text)
    var
        ItemVariant: record "Item Variant";
        i95Setup: Record "i95 Setup";
        FirstItemVariantCode: code[50];
        AttributeValue: Text[30];
        ChildSku: Text[250];
        i: Integer;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        configurableEntityJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        i95Setup.get();

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Item.Description);

        InputDataJsonObj.Add('sku', format(Item."No."));
        InputDataJsonObj.Add('name', Item.Description);
        InputDataJsonObj.Add('description', Item.Description);
        InputDataJsonObj.Add('shortDescription', Item.Description);
        InputDataJsonObj.Add('typeId', 'Configurable');

        Clear(FirstItemVariantCode);
        Clear(configurableEntityJsonObj);
        ItemVariant.Reset();
        ItemVariant.SetRange(ItemVariant."Item No.", item."No.");
        If ItemVariant.Findfirst() then
            FirstItemVariantCode := ItemVariant.Code;

        Clear(i);
        Clear(AttributeValue);
        if strpos(FirstItemVariantCode, i95Setup."i95 Item Variant Seperator") <> 0 then
            repeat
                AttributeValue := copystr(copystr(FirstItemVariantCode, 1, strpos(FirstItemVariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                FirstItemVariantCode := copystr(CopyStr(FirstItemVariantCode, strpos(FirstItemVariantCode, i95Setup."i95 Item Variant Seperator") + 1, MaxStrLen(firstItemVariantCode)), 1, 50);
                i += 1;
            until strpos(FirstItemVariantCode, i95Setup."i95 Item Variant Seperator") = 0;

        //The Pattern should be seperated by comma --> Ex Colour,Style,Size.   It should not be Colour-style-size 
        case i of
            0:
                configurableEntityJsonObj.Add('attributes', convertstr(i95Setup."i95 Item Variant Pattern 1", i95Setup."i95 Item Variant Seperator", ','));
            1:
                configurableEntityJsonObj.Add('attributes', convertstr(i95Setup."i95 Item Variant Pattern 2", i95Setup."i95 Item Variant Seperator", ','));
            2:
                configurableEntityJsonObj.Add('attributes', convertstr(i95Setup."i95 Item Variant Pattern 3", i95Setup."i95 Item Variant Seperator", ','));
        end;

        ItemVariant.Reset();
        ItemVariant.SetRange(ItemVariant."Item No.", item."No.");
        If ItemVariant.FindSet() then
            repeat
                if ChildSku = '' then
                    ChildSku := ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code
                else
                    ChildSku += ',' + ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code;
            until ItemVariant.Next() = 0;

        configurableEntityJsonObj.Add('childSkus', ChildSku);
        InputDataJsonObj.Add('configurableEntity', configurableEntityJsonObj);
        InputDataJsonObj.Add('targetId', format(Item."No."));
        InputDataJsonObj.Add('reference', Item.Description);
        InputDataJsonObj.Add('weight', format(Item."Gross Weight"));
        InputDataJsonObj.Add('price', format(Item."Unit Price"));
        InputDataJsonObj.Add('unitOfMeasure', Item."Base Unit of Measure");
        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(Item."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CustomerPushData(Customer: Record Customer; var BodyContent: Text)
    var
        ShipToAddress: Record "Ship-to Address";
        FirstAddress: Boolean;
        FirstName: Text[100];
        LastName: Text[100];
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        AddressesJsonArr: JsonArray;
        AddressesJsonObj: JsonObject;
        AddressesJsonToken: JsonToken;
        CompanyInfoJsonArr: JsonArray;
        CompanyInfoJsonObj: JsonObject;
        CompanyInfoJsonToken: JsonToken;
        i95DevSetup: Record "i95 Setup";
        EntityMapping: Record "i95 Entity Mapping";

    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstAddress := true;

        If StrPos(Customer.Name, ' ') <> 0 then begin
            FirstName := CopyStr(Customer.Name, 1, StrPos(Customer.Name, ' '));
            LastName := copystr(Customer.Name, strpos(Customer.Name, ' ') + 1, StrLen(Customer.Name));
        end else begin
            FirstName := Customer.Name;
            LastName := Customer.Name;
        end;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(Customer."No."));

        InputDataJsonObj.Add('targetId', Customer."No.");
        //InputDataJsonObj.Add('reference', Customer."No.");
        InputDataJsonObj.Add('reference', Customer."E-Mail");
        InputDataJsonObj.Add('firstName', FirstName);
        InputDataJsonObj.Add('lastName', LastName);
        InputDataJsonObj.Add('priceLevel', Customer."Customer Price Group");
        InputDataJsonObj.Add('taxBusPostingGroupCode', Customer."VAT Bus. Posting Group");
        InputDataJsonObj.Add('addresses', AddressesJsonArr);
        InputDataJsonObj.Get('addresses', AddressesJsonToken);
        AddressesJsonArr := AddressesJsonToken.AsArray();
        ShipToAddress.Reset();
        ShipToAddress.SetRange(ShipToAddress."Customer No.", Customer."No.");
        If ShipToAddress.FindSet() then
            repeat
                clear(AddressesJsonObj);
                if (ShipToAddress.Name <> '') and (ShipToAddress.Address <> '') then begin

                    If StrPos(ShipToAddress.Name, ' ') <> 0 then begin
                        FirstName := CopyStr(ShipToAddress.Name, 1, StrPos(ShipToAddress.Name, ' '));
                        LastName := copystr(ShipToAddress.Name, strpos(ShipToAddress.Name, ' ') + 1, StrLen(ShipToAddress.Name));
                    end else begin
                        FirstName := ShipToAddress.Name;
                        LastName := ShipToAddress.Name;
                    end;

                    AddressesJsonObj.Add('targetId', ShipToAddress.Code);
                    AddressesJsonObj.Add('reference', ShipToAddress."Customer No.");
                    AddressesJsonObj.Add('targetCustomerId', ShipToAddress."Customer No.");
                    if ShipToAddress.Code = 'I95DEFAULT' then
                        AddressesJsonObj.Add('isDefaultBilling', true)
                    else
                        AddressesJsonObj.Add('isDefaultBilling', false);
                    if not ShipToAddress."i95 Is Default Shipping" then
                        AddressesJsonObj.Add('isDefaultShipping', false)
                    else
                        AddressesJsonObj.Add('isDefaultShipping', true);
                    AddressesJsonObj.Add('firstName', FirstName);
                    AddressesJsonObj.Add('lastName', LastName);
                    AddressesJsonObj.Add('street', ShipToAddress.Address);
                    AddressesJsonObj.Add('street2', ShipToAddress."Address 2");
                    AddressesJsonObj.Add('city', ShipToAddress.City);
                    AddressesJsonObj.Add('postcode', ShipToAddress."Post Code");
                    AddressesJsonObj.Add('countryId', ShipToAddress."Country/Region Code");
                    AddressesJsonObj.Add('regionId', ShipToAddress.County);
                    AddressesJsonObj.Add('telephone', ShipToAddress."Phone No.");
                    AddressesJsonObj.Add('createdTime', format(ShipToAddress."i95 Created DateTime"));
                    AddressesJsonArr.Add(AddressesJsonObj);
                end;
            until ShipToAddress.Next() = 0;

        ShipToAddress.Get(Customer."No.", 'I95DEFAULT');

        InputDataJsonObj.Add('email', ShipToAddress."E-Mail");
        InputDataJsonObj.Add('customerDiscountGroupId', Customer."Customer Disc. Group");
        InputDataJsonObj.Add('createdDate', format(Customer."i95 Created DateTime"));
        InputDataJsonObj.Add('street', ShipToAddress.Address);
        InputDataJsonObj.Add('street2', ShipToAddress."Address 2");
        InputDataJsonObj.Add('city', ShipToAddress.City);
        InputDataJsonObj.Add('regionId', ShipToAddress.County);
        InputDataJsonObj.Add('countryId', ShipToAddress."Country/Region Code");
        InputDataJsonObj.Add('postcode', ShipToAddress."Post Code");
        InputDataJsonObj.Add('telephone', ShipToAddress."Phone No.");
        InputDataJsonObj.Add('isDefaultBilling', true);
        InputDataJsonObj.Add('targetAddressId', ShipToAddress.Code);
        if ShipToAddress."i95 Is Default Shipping" then
            InputDataJsonObj.Add('isDefaultShipping', true)
        else
            InputDataJsonObj.Add('isDefaultShipping', false);

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(Customer."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CompanyPushData(Customer: Record Customer; var BodyContent: Text)
    var
        ShipToAddress: Record "Ship-to Address";
        FirstAddress: Boolean;
        FirstName: Text[100];
        LastName: Text[100];
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        AddressesJsonArr: JsonArray;
        AddressesJsonObj: JsonObject;
        AddressesJsonToken: JsonToken;
        CompanyInfoJsonArr: JsonArray;
        CompanyInfoJsonObj: JsonObject;
        CompanyInfoJsonToken: JsonToken;
        i95DevSetup: Record "i95 Setup";
        ContactInfoJsonArr: JsonArray;
        ContactInfoJsonObj: JsonObject;
        ContactInfoJsonToken: JsonToken;
        Contact: Record Contact;
        ContactAddressJsonArr: JsonArray;
        ContactAddressJsonObj: JsonObject;
        ContactAddressJsonToken: JsonToken;
        ContactAlternateAddress: Record "Contact Alt. Address";
        ContactBusinessRelation: Record "Contact Business Relation";
        AvailableLimit: Decimal;
        OutStandingAMount: Decimal;
        ContactNoL: Code[50];
        EntityMapping: Record "i95 Entity Mapping";
    begin
        Clear(ContactInfoJsonObj);
        Clear(InputDataJsonObj);

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstAddress := true;

        If StrPos(Customer.Name, ' ') <> 0 then begin
            FirstName := CopyStr(Customer.Name, 1, StrPos(Customer.Name, ' '));
            LastName := copystr(Customer.Name, strpos(Customer.Name, ' ') + 1, StrLen(Customer.Name));
        end else begin
            FirstName := Customer.Name;
            LastName := Customer.Name;
        end;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();
        PushDatajsonObj.Add('Reference', Format(Customer."No."));

        InputDataJsonObj.Add('targetId', Customer."No.");
        InputDataJsonObj.Add('reference', Customer."No.");
        InputDataJsonObj.Add('firstName', FirstName);
        InputDataJsonObj.Add('lastName', LastName);
        InputDataJsonObj.Add('priceLevel', Customer."Customer Price Group");
        InputDataJsonObj.Add('taxBusPostingGroupCode', Customer."VAT Bus. Posting Group");
        InputDataJsonObj.Add('targetNetTermsId', Customer."Payment Terms Code");
        InputDataJsonObj.Add('salesPersonId', Customer."Salesperson Code");



        case Customer."i95 Customer Type" of
            Customer."i95 Customer Type"::Company:
                InputDataJsonObj.Add('customerType', 'Company');
            Customer."i95 Customer Type"::Customer:
                InputDataJsonObj.Add('customerType', 'Customer');
            else
                InputDataJsonObj.Add('customerType', format(Customer."i95 Customer Type"));
        end;
        InputDataJsonObj.Add('companyName', Customer.Name);
        IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
            i95DevSetup.Get();
            IF i95DevSetup."i95 Enable Company" = true then begin
                /*InputDataJsonObj.Add('contactInfo', ContactInfoJsonArr);
                InputDataJsonObj.Get('contactInfo', ContactInfoJsonToken);
                ContactInfoJsonArr := ContactInfoJsonToken.AsArray();*/
                ContactBusinessRelation.Reset();
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", Customer."No.");
                IF ContactBusinessRelation.FindFirst() then
                    Contact.Reset();
                Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");
                IF Contact.FindFirst() then
                    repeat
                        IF (Contact."i95 Synced" = true) then begin
                            Clear(ContactInfoJsonObj);
                            ContactInfoJsonObj.add('targetId', Contact."No.");
                            case Contact.Type of
                                Contact.Type::Company:
                                    ContactInfoJsonObj.Add('customerType', 'Admin');
                                Contact.Type::Person:
                                    ContactInfoJsonObj.Add('customerType', 'User');
                                else
                                    ContactInfoJsonObj.Add('customerType', format(Contact.Type));
                            end;

                            ContactInfoJsonObj.add('targetParentId', Customer."No.");
                            Clear(FirstName);
                            Clear(LastName);
                            If StrPos(Contact.Name, ' ') <> 0 then begin
                                FirstName := CopyStr(Contact.Name, 1, StrPos(Contact.Name, ' '));
                                LastName := copystr(Contact.Name, strpos(Contact.Name, ' ') + 1, StrLen(Contact.Name));
                            end else begin
                                FirstName := Contact.Name;
                                LastName := Contact.Name;
                            end;
                            ContactInfoJsonObj.add('companyName', Contact."Company Name");
                            ContactInfoJsonObj.add('firstName', FirstName);
                            ContactInfoJsonObj.add('lastName', LastName);
                            ContactInfoJsonObj.add('email', Contact."E-Mail");
                            ContactInfoJsonObj.add('priceLevel', '');
                            //  ContactInfoJsonObj.Add('targetId', Contact."No.");
                            ContactInfoJsonObj.add('reference', Contact."E-Mail");
                            ContactInfoJsonObj.Add('targetContactId', Contact."No.");
                            ContactInfoJsonObj.Add('targetCustomerId', Customer."No.");
                            ContactInfoJsonObj.Add('Name', Contact.Name);
                            // ContactInfoJsonObj.Add('firstName', FirstName);
                            // ContactInfoJsonObj.Add('lastName', LastName);
                            ContactInfoJsonObj.Add('street', Contact.Address);
                            ContactInfoJsonObj.Add('street2', Contact."Address 2");
                            ContactInfoJsonObj.Add('city', Contact.City);
                            ContactInfoJsonObj.Add('postcode', Contact."Post Code");
                            ContactInfoJsonObj.Add('countryId', Contact."Country/Region Code");
                            ContactInfoJsonObj.Add('regionId', Contact.County);
                            ContactInfoJsonObj.Add('telephone', Contact."Phone No.");
                            ContactInfoJsonObj.Add('fax', Contact."Fax No.");

                            ContactInfoJsonObj.Add('targetNetTermsId', Customer."Payment Terms Code");
                            ContactInfoJsonObj.Add('salesPersonId', Customer."Salesperson Code");

                            ContactInfoJsonObj.Add('customerDiscountGroupId', Customer."Customer Disc. Group");
                            //  ContactInfoJsonArr.Add(ContactInfoJsonObj);

                            //ContactInfoJsonObj.Add('addresses', ContactAddressJsonArr);
                            ContactInfoJsonObj.Add('address', ContactAddressJsonArr);

                            //ContactInfoJsonObj.Get('addresses', ContactAddressJsonToken);
                            ContactInfoJsonObj.Get('address', ContactAddressJsonToken);

                            ContactAddressJsonArr := ContactAddressJsonToken.AsArray();
                            // ContactAddressJsonArr.Add(ContactAddressJsonObj);

                            ContactAlternateAddress.Reset();
                            ContactAlternateAddress.SetCurrentKey("Contact No.", Code);
                            ContactAlternateAddress.SetRange("Contact No.", Contact."No.");
                            IF ContactAlternateAddress.FindFirst() then
                                repeat
                                    Clear(ContactAddressJsonObj);
                                    Clear(FirstName);
                                    Clear(LastName);

                                    If StrPos(ContactAlternateAddress."Company Name", ' ') <> 0 then begin
                                        FirstName := CopyStr(ContactAlternateAddress."Company Name", 1, StrPos(ContactAlternateAddress."Company Name", ' '));
                                        LastName := copystr(ContactAlternateAddress."Company Name", strpos(ContactAlternateAddress."Company Name", ' ') + 1, StrLen(ContactAlternateAddress."Company Name"));
                                    end else begin
                                        FirstName := ContactAlternateAddress."Company Name";
                                        LastName := ContactAlternateAddress."Company Name";
                                    end;

                                    ContactAddressJsonObj.Add('targetId', ContactAlternateAddress."Contact No.");
                                    ContactAddressJsonObj.Add('reference', ContactAlternateAddress."Contact No.");
                                    ContactAddressJsonObj.Add('targetContactId', ContactAlternateAddress."Contact No.");
                                    ContactAddressJsonObj.Add('targetCustomerId', Customer."No.");
                                    ContactAddressJsonObj.Add('Name', Contact.Name);
                                    ContactAddressJsonObj.Add('firstName', FirstName);
                                    ContactAddressJsonObj.Add('lastName', LastName);
                                    ContactAddressJsonObj.Add('street', ContactAlternateAddress.Address);
                                    ContactAddressJsonObj.Add('street2', ContactAlternateAddress."Address 2");
                                    ContactAddressJsonObj.Add('city', ContactAlternateAddress.City);
                                    ContactAddressJsonObj.Add('postcode', ContactAlternateAddress."Post Code");
                                    ContactAddressJsonObj.Add('countryId', ContactAlternateAddress."Country/Region Code");
                                    ContactAddressJsonObj.Add('regionId', ContactAlternateAddress.County);
                                    ContactAddressJsonObj.Add('telephone', ContactAlternateAddress."Phone No.");
                                    ContactAddressJsonObj.Add('fax', ContactAlternateAddress."Fax No.");
                                    ContactAddressJsonArr.Add(ContactAddressJsonObj);
                                until ContactAlternateAddress.Next() = 0;

                            InputDataJsonObj.Add('contactInfo', ContactInfoJsonObj);
                        end;
                    until Contact.Next() = 0;
            end;
        end;


        //ContactInfoJsonArr.Add(ContactInfoJsonObj);

        IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Customer then begin
            InputDataJsonObj.Add('addresses', AddressesJsonArr);
            //InputDataJsonObj.Add('address', AddressesJsonArr);

            InputDataJsonObj.Get('addresses', AddressesJsonToken);
            //InputDataJsonObj.Get('address', AddressesJsonToken);
            AddressesJsonArr := AddressesJsonToken.AsArray();
            ShipToAddress.Reset();
            ShipToAddress.SetRange(ShipToAddress."Customer No.", Customer."No.");
            If ShipToAddress.FindSet() then
                repeat
                    clear(AddressesJsonObj);
                    if (ShipToAddress.Name <> '') and (ShipToAddress.Address <> '') then begin

                        If StrPos(ShipToAddress.Name, ' ') <> 0 then begin
                            FirstName := CopyStr(ShipToAddress.Name, 1, StrPos(ShipToAddress.Name, ' '));
                            LastName := copystr(ShipToAddress.Name, strpos(ShipToAddress.Name, ' ') + 1, StrLen(ShipToAddress.Name));
                        end else begin
                            FirstName := ShipToAddress.Name;
                            LastName := ShipToAddress.Name;
                        end;

                        AddressesJsonObj.Add('targetId', ShipToAddress.Code);
                        AddressesJsonObj.Add('reference', ShipToAddress."Customer No.");
                        AddressesJsonObj.Add('targetCustomerId', ShipToAddress."Customer No.");
                        if ShipToAddress.Code = 'I95DEFAULT' then
                            AddressesJsonObj.Add('isDefaultBilling', 'true')
                        else
                            AddressesJsonObj.Add('isDefaultBilling', 'false');
                        if not ShipToAddress."i95 Is Default Shipping" then
                            AddressesJsonObj.Add('isDefaultShipping', 'false')
                        else
                            AddressesJsonObj.Add('isDefaultShipping', 'true');
                        AddressesJsonObj.Add('firstName', FirstName);
                        AddressesJsonObj.Add('lastName', LastName);
                        AddressesJsonObj.Add('street', ShipToAddress.Address);
                        AddressesJsonObj.Add('street2', ShipToAddress."Address 2");
                        AddressesJsonObj.Add('city', ShipToAddress.City);
                        AddressesJsonObj.Add('postcode', ShipToAddress."Post Code");
                        AddressesJsonObj.Add('countryId', ShipToAddress."Country/Region Code");
                        AddressesJsonObj.Add('regionId', ShipToAddress.County);
                        AddressesJsonObj.Add('telephone', ShipToAddress."Phone No.");
                        AddressesJsonObj.Add('createdTime', format(ShipToAddress."i95 Created DateTime"));
                        AddressesJsonArr.Add(AddressesJsonObj);
                    end;
                until ShipToAddress.Next() = 0;
        end;
        ShipToAddress.Get(Customer."No.", 'I95DEFAULT');
        IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
            AddressesJsonObj.Add('firstName', FirstName);
            AddressesJsonObj.Add('lastName', LastName);
            AddressesJsonObj.Add('email', ShipToAddress."E-Mail");
            AddressesJsonObj.Add('street', ShipToAddress.Address);
            AddressesJsonObj.Add('street2', ShipToAddress."Address 2");
            AddressesJsonObj.Add('city', ShipToAddress.City);
            AddressesJsonObj.Add('regionId', ShipToAddress.County);
            AddressesJsonObj.Add('countryId', ShipToAddress."Country/Region Code");
            AddressesJsonObj.Add('postcode', ShipToAddress."Post Code");
            AddressesJsonObj.Add('telephone', ShipToAddress."Phone No.");
            if ShipToAddress.Code = 'I95DEFAULT' then
                AddressesJsonObj.Add('isDefaultBilling', 'true')
            else
                AddressesJsonObj.Add('isDefaultBilling', 'false');
            if not ShipToAddress."i95 Is Default Shipping" then
                AddressesJsonObj.Add('isDefaultShipping', 'false')
            else
                AddressesJsonObj.Add('isDefaultShipping', 'true');
            AddressesJsonObj.Add('createdTime', format(ShipToAddress."i95 Created DateTime"));
            AddressesJsonObj.Add('targetAddressId', ShipToAddress.Code);
            InputDataJsonObj.Add('address', AddressesJsonObj);
        end;

        ShipToAddress.Get(Customer."No.", 'I95DEFAULT');

        InputDataJsonObj.Add('email', ShipToAddress."E-Mail");
        InputDataJsonObj.Add('customerDiscountGroupId', Customer."Customer Disc. Group");
        InputDataJsonObj.Add('createdDate', format(Customer."i95 Created DateTime"));
        InputDataJsonObj.Add('street', ShipToAddress.Address);
        InputDataJsonObj.Add('street2', ShipToAddress."Address 2");
        InputDataJsonObj.Add('city', ShipToAddress.City);
        InputDataJsonObj.Add('regionId', ShipToAddress.County);
        InputDataJsonObj.Add('countryId', ShipToAddress."Country/Region Code");
        InputDataJsonObj.Add('postcode', ShipToAddress."Post Code");
        InputDataJsonObj.Add('telephone', ShipToAddress."Phone No.");
        InputDataJsonObj.Add('isDefaultBilling', 'true');
        InputDataJsonObj.Add('targetAddressId', ShipToAddress.Code);

        //Start Company Account
        i95DevSetup.Get();
        IF i95DevSetup."i95 Enable Company" = true then begin
            InputDataJsonObj.Add('CompanyInfo', CompanyInfoJsonArr);
            InputDataJsonObj.Get('CompanyInfo', CompanyInfoJsonToken);
            CompanyInfoJsonArr := CompanyInfoJsonToken.AsArray();
            case Customer."i95 Customer Type" of
                Customer."i95 Customer Type"::Company:
                    CompanyInfoJsonObj.Add('customerType', 'Company');
                Customer."i95 Customer Type"::Customer:
                    CompanyInfoJsonObj.Add('customerType', 'Customer');
                else
                    CompanyInfoJsonObj.Add('customerType', format(Customer."i95 Customer Type"));
            end;

            CompanyInfoJsonArr.Add(CompanyInfoJsonObj);
        end;
        //Stop Company Account

        if ShipToAddress."i95 Is Default Shipping" then
            InputDataJsonObj.Add('isDefaultShipping', 'true')
        else
            InputDataJsonObj.Add('isDefaultShipping', 'false');
        if Customer."Credit Limit (LCY)" > 0 then begin
            AvailableLimit := Customer.CalcAvailableCredit();
            InputDataJsonObj.Add('creditLimitType', 'Amount');
            InputDataJsonObj.Add('creditLimitAmount', Customer."Credit Limit (LCY)");
            InputDataJsonObj.Add('availableCreditLimit', AvailableLimit);
        end;

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(Customer."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CustomerPriceGroupPushData(CustPriceGroup: Record "Customer Price Group"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(CustPriceGroup.Code));

        InputDataJsonObj.Add('targetId', CustPriceGroup.Code);
        InputDataJsonObj.Add('priceLevelDescription', CustPriceGroup.Description);
        InputDataJsonObj.Add('reference', CustPriceGroup.Code);

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(CustPriceGroup.Code));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesPricePushData(Item: Record Item; var BodyContent: Text)
    var
        SalesPrice: Record "Sales Price";
        //SalesPrice: Record "Price List Line";
        FirstSalesPrice: Boolean;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        TierPricesJsonArr: JsonArray;
        TierPricessonObj: JsonObject;
        TierPricesJsonToken: JsonToken;
        ItemVariant: Record "Item Variant";
        i95DevSetup: Record "i95 Setup";
    begin

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesPrice := true;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(Item.Description));

        InputDataJsonObj.Add('targetId', Item."No.");
        InputDataJsonObj.Add('reference', Item.Description);
        InputDataJsonObj.Add('tierPrices', TierPricesJsonArr);
        InputDataJsonObj.Get('tierPrices', TierPricesJsonToken);
        TierPricesJsonArr := TierPricesJsonToken.AsArray();
        //SalesPrice.Reset(); srinivas
        //SalesPrice.SetRange(SalesPrice."Item No.", Item."No."); srinivas

        //SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        //SalesPrice.SetRange("Asset No.", Item."No.");
        i95DevSetup.Get();

        IF i95DevSetup."i95 Enable CustSpec Pricing" = true then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", Item."No.");
            SalesPrice.SetFilter("Variant Code", '=%1', '');
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::Customer);
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;
        if i95DevSetup."i95Dev EnableAllCustmr Pricing" = true then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", Item."No.");
            SalesPrice.SetFilter("Variant Code", '=%1', '');
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::"All Customers");
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;
        if i95DevSetup."i95Dev CPG Pricing" then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", Item."No.");
            SalesPrice.SetFilter("Variant Code", '=%1', '');
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::"Customer Price Group");
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;


        /*srinivas

                //SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::"Customer Price Group");
                SalesPrice.SetFilter("Variant Code", '=%1', '');
                If SalesPrice.FindSet() then
                    repeat
                        Clear(TierPricessonObj);
                        TierPricessonObj.Add('priceLevelKey', SalesPrice."Sales Code");
                        // TierPricessonObj.Add('priceLevelKey', SalesPrice."Source No.");
                        TierPricessonObj.Add('minQty', SalesPrice."Minimum Quantity");
                        TierPricessonObj.Add('price', SalesPrice."Unit Price");
                        TierPricessonObj.Add('salesCode', SalesPrice."Sales Code");
                        TierPricessonObj.Add('salesType', SalesPrice."Sales Type");
                        IF SalesPrice."Starting Date" <> 0D then
                            TierPricessonObj.Add('fromDate', SalesPrice."Starting Date")
                        else
                            TierPricessonObj.Add('fromDate', '');
                        IF SalesPrice."Ending Date" <> 0D then
                            TierPricessonObj.Add('toDate', SalesPrice."Ending Date")
                        else
                            TierPricessonObj.Add('toDate', '');


                        TierPricesJsonArr.Add(TierPricessonObj);
                    until SalesPrice.Next() = 0;

                    */

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(Item."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    local procedure FillTierPrice(var TierPricessonObj: JsonObject; var TierPricesJsonArr: JsonArray; var SalesPrice: Record "Sales Price")
    var
        TierPricesJsonArr1: JsonArray;
        TierPricessonObj1: JsonObject;
    begin
        //SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::"Customer Price Group");
        //SalesPrice.SetFilter("Variant Code", '=%1', '');
        If SalesPrice.FindSet() then
            repeat
                Clear(TierPricessonObj);
                TierPricessonObj.Add('priceLevelKey', SalesPrice."Sales Code");
                // TierPricessonObj.Add('priceLevelKey', SalesPrice."Source No.");
                TierPricessonObj.Add('minQty', SalesPrice."Minimum Quantity");
                TierPricessonObj.Add('price', SalesPrice."Unit Price");
                TierPricessonObj.Add('salesCode', SalesPrice."Sales Code");
                TierPricessonObj.Add('salesType', SalesPrice."Sales Type");
                IF SalesPrice."Starting Date" <> 0D then
                    TierPricessonObj.Add('fromDate', SalesPrice."Starting Date")
                else
                    TierPricessonObj.Add('fromDate', '');
                IF SalesPrice."Ending Date" <> 0D then
                    TierPricessonObj.Add('toDate', SalesPrice."Ending Date")
                else
                    TierPricessonObj.Add('toDate', '');


                TierPricesJsonArr.Add(TierPricessonObj);
            until SalesPrice.Next() = 0;
    end;

    procedure SalesPriceVariantPushData(ItemVariant: Record "Item Variant"; var BodyContent: Text)
    var
        SalesPrice: Record "Sales Price";
        //SalesPrice: Record "Price List Line";
        FirstSalesPrice: Boolean;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        TierPricesJsonArr: JsonArray;
        TierPricessonObj: JsonObject;
        TierPricesJsonToken: JsonToken;
        // ItemVariant: Record "Item Variant";
        i95Setup: Record "i95 Setup";

    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");


        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesPrice := true;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(ItemVariant.Description));
        InputDataJsonObj.Add('targetId', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        InputDataJsonObj.Add('reference', ItemVariant.Description);
        InputDataJsonObj.Add('tierPrices', TierPricesJsonArr);
        InputDataJsonObj.Get('tierPrices', TierPricesJsonToken);
        TierPricesJsonArr := TierPricesJsonToken.AsArray();
        SalesPrice.Reset();

        // SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        // SalesPrice.SetRange("Asset No.", ItemVariant."Item No.");
        //SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::"Customer Price Group");
        i95Setup.Get();
        IF i95Setup."i95 Enable CustSpec Pricing" = true then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", ItemVariant."Item No.");
            SalesPrice.SetRange(SalesPrice."Variant Code", ItemVariant.Code);
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::Customer);
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;
        if i95Setup."i95Dev EnableAllCustmr Pricing" = true then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", ItemVariant."Item No.");
            SalesPrice.SetRange(SalesPrice."Variant Code", ItemVariant.Code);
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::"All Customers");
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;
        if i95Setup."i95Dev CPG Pricing" then begin
            SalesPrice.Reset();
            SalesPrice.SetRange(SalesPrice."Item No.", ItemVariant."Item No.");
            SalesPrice.SetRange(SalesPrice."Variant Code", ItemVariant.Code);
            SalesPrice.SetFilter(SalesPrice."Sales Type", '=%1', SalesPrice."Sales Type"::"Customer Price Group");
            FillTierPrice(TierPricessonObj, TierPricesJsonArr, SalesPrice);
        end;

        //SalesPrice.SetRange(SalesPrice."Item No.", ItemVariant."Item No.");
        //SalesPrice.SetRange(SalesPrice."Variant Code", ItemVariant.Code);

        // If SalesPrice.FindSet() then
        //     repeat
        //         Clear(TierPricessonObj);
        //         TierPricessonObj.Add('priceLevelKey', SalesPrice."Sales Code");
        //         //TierPricessonObj.Add('priceLevelKey', SalesPrice."Source No.");
        //         TierPricessonObj.Add('minQty', SalesPrice."Minimum Quantity");
        //         TierPricessonObj.Add('price', SalesPrice."Unit Price");
        //         IF SalesPrice."Starting Date" <> 0D then
        //             TierPricessonObj.Add('fromDate', SalesPrice."Starting Date")
        //         else
        //             TierPricessonObj.Add('fromDate', '');

        //         IF SalesPrice."Ending Date" <> 0D then
        //             TierPricessonObj.Add('toDate', SalesPrice."Ending Date")
        //         else
        //             TierPricessonObj.Add('toDate', '');

        //         TierPricesJsonArr.Add(TierPricessonObj);
        //     until SalesPrice.Next() = 0;

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesOrderPushData(SalesHeader: record "Sales Header"; var BodyContent: Text; EcommerceShippingCode: code[50]; EcommercePaymentMethodCode: Code[50]; EcommerceShippingTitle: text[50]; ShippingAgentCode: text[30])
    var
        SalesLine: Record "Sales Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        SalesLine2: Record "Sales Line";
        FirstSalesLine: Boolean;
        DiscountAmount: Decimal;
        AttributeCode: text[30];
        AttributeValue: Text[30];
        PatternType: Integer;
        Pattern: text[50];
        VariantCode: text[50];
        i: Integer;
        VariantSepratorCount: Integer;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        DiscountAmountJsonArr: JsonArray;
        DiscountAmountJsonObj: JsonObject;
        DiscountAmountJsonToken: JsonToken;
        PaymentJsonArr: JsonArray;
        PaymentJsonObj: JsonObject;
        PaymentJsonToken: JsonToken;
        OrderItemsJsonArr: JsonArray;
        OrderItemsJsonObj: JsonObject;
        OrderItemsJsonToken: JsonToken;
        OrderItemsdiscountAmountJsonArr: JsonArray;
        OrderItemsdiscountAmountJsonObj: JsonObject;
        OrderItemsdiscountAmountJsonToken: JsonToken;
        OrderItemVariantJsonArr: JsonArray;
        OrderItemVariantJsonObj: JsonObject;
        OrderItemVariantJsonToken: JsonToken;
        AttributewithKeyJsonArr: JsonArray;
        AttributewithKeyJsonObj: JsonObject;
        AttributewithKeyJsonToken: JsonToken;
        BillingAddressJsonObj: JsonObject;
        ShippingAddressJsonObj: JsonObject;
        CustomerJsonArr: JsonArray;
        CustomerJsonObj: JsonObject;
        CustomerJsonToken: JsonToken;
        CompanyJsonArr: JsonArray;
        CompanyJsonObj: JsonObject;
        CompanyJsonToken: JsonToken;
        Customer: Record Customer;
        Contact: Record Contact;
        CustomerId: text[50];
        AvailableLimit: Decimal;
        EntityMapping: Record "i95 Entity Mapping";
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesLine := true;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();


        PushDatajsonObj.Add('Reference', Format(SalesHeader."Sell-to Customer No."));

        IF Customer.get(SalesHeader."Sell-to Customer No.") then
            IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Contact No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Contact No.")
            end else begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Customer No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            end;

        InputDataJsonObj.Add('targetQuoteId', SalesHeader."Quote No.");
        InputDataJsonObj.Add('carrierName', lowercase(ShippingAgentCode));
        InputDataJsonObj.Add('targetShippingAddressId', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('targetBillingAddressId', SalesHeader."Bill-to Customer No.");
        InputDataJsonObj.Add('orderCreatedDate', format(SalesHeader."Order Date"));
        InputDataJsonObj.Add('targetNetTermsId', SalesHeader."Payment Terms Code");
        InputDataJsonObj.Add('salesPersonId', SalesHeader."Salesperson Code");
        InputDataJsonObj.Add('warehouseCode', SalesHeader."Location Code");

        InputDataJsonObj.Add('shippingMethod', lowercase(EcommerceShippingCode));
        InputDataJsonObj.Add('shippingTitle', lowercase(EcommerceShippingTitle));
        InputDataJsonObj.Add('payment', PaymentJsonArr);
        InputDataJsonObj.Get('payment', PaymentJsonToken);
        PaymentJsonArr := PaymentJsonToken.AsArray();
        clear(PaymentJsonObj);
        PaymentJsonObj.Add('paymentMethod', LowerCase(EcommercePaymentMethodCode));
        PaymentJsonArr.Add(PaymentJsonObj);

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange(SalesLine."No.", i95Setup."i95 Shipping Charge G/L Acc");
        If SalesLine.FindFirst() then
            InputDataJsonObj.Add('shippingAmount', format(SalesLine."Unit Price"))
        else
            InputDataJsonObj.Add('shippingAmount', 0);

        Clear(DiscountAmount);
        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        If SalesLine.Findset() then
            repeat
                DiscountAmount += SalesLine."Line Discount Amount";
            until SalesLine.Next() = 0;

        InputDataJsonObj.Add('subTotal', delchr(format(SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('orderDocumentAmount', delchr(format(SalesHeader."Amount Including VAT"), '=', ','));
        InputDataJsonObj.Add('taxAmount', delchr(format(SalesHeader."Amount Including VAT" - SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('discount', DiscountAmountJsonArr);
        InputDataJsonObj.Get('discount', DiscountAmountJsonToken);
        DiscountAmountJsonArr := DiscountAmountJsonToken.AsArray();

        clear(DiscountAmountJsonObj);
        DiscountAmountJsonObj.Add('discountType', 'discount');
        //DiscountAmountJsonObj.Add('discountAmount', format(DiscountAmount));
        DiscountAmountJsonObj.Add('discountAmount', delchr(format(DiscountAmount), '=', ','));

        DiscountAmountJsonArr.Add(DiscountAmountJsonObj);

        InputDataJsonObj.Add('orderItems', OrderItemsJsonArr);
        InputDataJsonObj.Get('orderItems', OrderItemsJsonToken);
        OrderItemsJsonArr := OrderItemsJsonToken.AsArray();

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                clear(OrderItemsJsonObj);

                if SalesLine."Variant Code" = '' then begin

                    OrderItemsJsonObj.Add('sku', SalesLine."No.");
                    // OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    //OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));

                    OrderItemsJsonObj.Add('qty', SalesLine.Quantity);
                    OrderItemsJsonObj.Add('price', SalesLine."Unit Price");

                    Clear(OrderItemsdiscountAmountJsonArr);
                    clear(OrderItemsdiscountAmountJsonObj);
                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        // OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));

                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end else begin
                    Clear(VariantCode);
                    Clear(VariantSepratorCount);
                    Clear(Pattern);
                    Clear(PatternType);
                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");

                    OrderItemsJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
                    OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));
                    OrderItemsJsonObj.Add('markdownPrice', 0);
                    OrderItemsJsonObj.Add('parentSku', ItemVariant."Item No.");
                    OrderItemsJsonObj.Add('retailVariantId', ItemVariant.Code);

                    //Item Variant
                    Clear(OrderItemVariantJsonObj);
                    clear(OrderItemVariantJsonArr);
                    Clear(AttributewithKeyJsonArr);
                    OrderItemsJsonObj.Add('itemVariants', OrderItemVariantJsonArr);
                    OrderItemsJsonObj.Get('itemVariants', OrderItemVariantJsonToken);
                    OrderItemVariantJsonArr := OrderItemVariantJsonToken.AsArray();
                    clear(OrderItemVariantJsonObj);

                    OrderItemVariantJsonObj.Add('attributeWithKey', AttributewithKeyJsonArr);
                    OrderItemVariantJsonObj.get('attributeWithKey', AttributewithKeyJsonToken);
                    AttributewithKeyJsonArr := AttributewithKeyJsonToken.AsArray();
                    clear(AttributewithKeyJsonObj);

                    VariantCode := ItemVariant.Code;
                    VariantSepratorCount := STRLEN(DELCHR(VariantCode, '=', DELCHR(VariantCode, '=', i95Setup."i95 Item Variant Seperator")));

                    case VariantSepratorCount of
                        0:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 1";
                                PatternType := 1;
                            end;
                        1:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 2";
                                PatternType := 2;
                            end;
                        2:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 3";
                                PatternType := 3;
                            end;
                    end;

                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");
                    VariantCode := ItemVariant.Code;
                    for i := 1 to PatternType do begin
                        Clear(AttributewithKeyJsonObj);
                        Clear(AttributeCode);
                        Clear(AttributeValue);
                        if StrPos(Pattern, i95Setup."i95 Item Variant Seperator") <> 0 then begin
                            AttributeCode := copystr(CopyStr(Pattern, 1, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                            AttributeValue := copystr(copystr(VariantCode, 1, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);

                            Pattern := copystr(CopyStr(Pattern, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") + 1), 1, 30);
                            VariantCode := copystr(CopyStr(VariantCode, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") + 1), 1, 50);
                        end else begin
                            AttributeCode := CopyStr(Pattern, 1, 30);
                            AttributeValue := CopyStr(VariantCode, 1, 30);
                        end;

                        AttributewithKeyJsonObj.Add('attributeCode', AttributeCode);
                        AttributewithKeyJsonObj.Add('attributeValue', AttributeValue);
                        AttributewithKeyJsonObj.Add('attributeType', 'select');

                        AttributewithKeyJsonArr.Add(AttributewithKeyJsonObj);
                    end;

                    OrderItemVariantJsonArr.Add(OrderItemVariantJsonObj);

                    Clear(OrderItemsdiscountAmountJsonArr);
                    Clear(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        //OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));
                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end;

            until SalesLine.Next() = 0;

        Clear(BillingAddressJsonObj);
        BillingAddressJsonObj.Add('targetAddressId', 'I95DEFAULT');
        BillingAddressJsonObj.Add('isDefaultBilling', true);
        if strpos(SalesHeader."Bill-to Name", ' ') <> 0 then begin
            BillingAddressJsonObj.Add('firstName', copystr(SalesHeader."Bill-to Name", 1, strpos(SalesHeader."Bill-to Name", ' ') - 1));
            BillingAddressJsonObj.Add('lastName', copystr(SalesHeader."Bill-to Name", strpos(SalesHeader."Bill-to Name", ' ') + 1));
        end else begin
            BillingAddressJsonObj.Add('firstName', SalesHeader."Bill-to Name");
            BillingAddressJsonObj.Add('lastName', SalesHeader."Bill-to Name");
        end;
        BillingAddressJsonObj.Add('street', SalesHeader."Bill-to Address");
        BillingAddressJsonObj.Add('street2', SalesHeader."Bill-to Address 2");
        BillingAddressJsonObj.Add('city', SalesHeader."Bill-to City");
        BillingAddressJsonObj.Add('postcode', SalesHeader."Bill-to Post Code");
        BillingAddressJsonObj.Add('countryId', SalesHeader."Bill-to Country/Region Code");
        BillingAddressJsonObj.Add('regionId', SalesHeader."Bill-to County");
        BillingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('billingAddress', BillingAddressJsonObj);

        Clear(ShippingAddressJsonObj);
        If SalesHeader."Ship-to Code" <> '' then
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Ship-to Code")
        else
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Bill-to Customer No.");
        if strpos(SalesHeader."Ship-to Name", ' ') <> 0 then begin
            ShippingAddressJsonObj.Add('firstName', copystr(SalesHeader."Ship-to Name", 1, strpos(SalesHeader."Ship-to Name", ' ') - 1));
            ShippingAddressJsonObj.Add('lastName', copystr(SalesHeader."Ship-to Name", strpos(SalesHeader."Ship-to Name", ' ') + 1))
        end else begin
            ShippingAddressJsonObj.Add('firstName', SalesHeader."Ship-to Name");
            ShippingAddressJsonObj.Add('lastName', SalesHeader."Ship-to Name");
        end;

        ShippingAddressJsonObj.Add('street', SalesHeader."Ship-to Address");
        ShippingAddressJsonObj.Add('street2', SalesHeader."Ship-to Address 2");
        ShippingAddressJsonObj.Add('city', SalesHeader."Ship-to City");
        ShippingAddressJsonObj.Add('postcode', SalesHeader."Ship-to Post Code");
        ShippingAddressJsonObj.Add('countryId', SalesHeader."Ship-to Country/Region Code");
        ShippingAddressJsonObj.Add('regionId', SalesHeader."Ship-to County");
        ShippingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('shippingAddress', ShippingAddressJsonObj);
        Clear(CustomerId);
        Clear(AvailableLimit);
        CustomerId := SalesHeader."Bill-to Customer No.";
        Customer.get(CustomerId);
        if Customer."Credit Limit (LCY)" > 0 then begin
            AvailableLimit := Customer.CalcAvailableCredit();
            InputDataJsonObj.Add('creditLimitType', 'Amount');
            InputDataJsonObj.Add('creditLimit', Customer."Credit Limit (LCY)");
            InputDataJsonObj.Add('availableLimit', AvailableLimit);
        end;

        i95Setup.Get();
        IF i95Setup."i95 Enable Company" = true then begin
            CustomerJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            Contact.Reset();
            Contact.SetRange("No.", SalesHeader."Sell-to Contact No.");
            IF Contact.FindFirst() then begin
                case Contact.Type of
                    Contact.Type::Company:
                        CompanyJsonObj.Add('customerType', 'Admin');
                    Contact.Type::Person:
                        CompanyJsonObj.Add('customerType', 'User');
                    else
                        CompanyJsonObj.Add('customerType', format(Contact.Type));
                end;

            end;
            CompanyJsonObj.Add('targetParentId', SalesHeader."Sell-to Customer No.");
            CustomerJsonObj.Add('companyInfo', CompanyJsonObj);
            InputDataJsonObj.Add('customer', CustomerJsonObj);

        end;

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(SalesHeader."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesReturnOrderPushData(SalesHeader: record "Sales Header"; var BodyContent: Text; EcommerceShippingCode: code[50]; EcommercePaymentMethodCode: Code[50]; EcommerceShippingTitle: text[50]; ShippingAgentCode: text[30])
    var
        SalesLine: Record "Sales Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        SalesLine2: Record "Sales Line";
        FirstSalesLine: Boolean;
        DiscountAmount: Decimal;
        AttributeCode: text[30];
        AttributeValue: Text[30];
        PatternType: Integer;
        Pattern: text[50];
        VariantCode: text[50];
        i: Integer;
        VariantSepratorCount: Integer;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        DiscountAmountJsonArr: JsonArray;
        DiscountAmountJsonObj: JsonObject;
        DiscountAmountJsonToken: JsonToken;
        PaymentJsonArr: JsonArray;
        PaymentJsonObj: JsonObject;
        PaymentJsonToken: JsonToken;
        OrderItemsJsonArr: JsonArray;
        OrderItemsJsonObj: JsonObject;
        OrderItemsJsonToken: JsonToken;
        OrderItemsdiscountAmountJsonArr: JsonArray;
        OrderItemsdiscountAmountJsonObj: JsonObject;
        OrderItemsdiscountAmountJsonToken: JsonToken;
        OrderItemVariantJsonArr: JsonArray;
        OrderItemVariantJsonObj: JsonObject;
        OrderItemVariantJsonToken: JsonToken;
        AttributewithKeyJsonArr: JsonArray;
        AttributewithKeyJsonObj: JsonObject;
        AttributewithKeyJsonToken: JsonToken;
        BillingAddressJsonObj: JsonObject;
        ShippingAddressJsonObj: JsonObject;
        CustomerJsonArr: JsonArray;
        CustomerJsonObj: JsonObject;
        CustomerJsonToken: JsonToken;
        CompanyJsonArr: JsonArray;
        CompanyJsonObj: JsonObject;
        CompanyJsonToken: JsonToken;
        Customer: Record Customer;
        Contact: Record Contact;
        CustomerId: text[50];
        AvailableLimit: Decimal;
        EntityMapping: Record "i95 Entity Mapping";
        SalesInvoiceheader: Record "Sales Invoice Header";
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesLine := true;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();


        PushDatajsonObj.Add('Reference', Format(SalesHeader."Sell-to Customer No."));

        IF Customer.get(SalesHeader."Sell-to Customer No.") then
            IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Contact No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Contact No.")
            end else begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Customer No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            end;
        InputDataJsonObj.Add('updatedTime', SalesHeader."i95 Last Modification DateTime");

        //  InputDataJsonObj.Add('targetQuoteId', SalesHeader."Quote No.");
        // InputDataJsonObj.Add('carrierName', lowercase(ShippingAgentCode));
        // InputDataJsonObj.Add('targetShippingAddressId', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('targetBillingAddressId', SalesHeader."Bill-to Customer No.");

        IF SalesHeader."Applies-to Doc. No." <> '' then begin
            InputDataJsonObj.Add('targetInvoiceId', SalesHeader."Applies-to Doc. No.");
            SalesInvoiceheader.Reset();
            SalesInvoiceheader.SetRange("No.", SalesHeader."Applies-to Doc. No.");
            IF SalesInvoiceheader.FindFirst() then
                InputDataJsonObj.Add('targetOrderId', SalesInvoiceheader."Order No.");

        end else begin
            InputDataJsonObj.Add('targetInvoiceId', SalesHeader."External Document No.");
            SalesInvoiceheader.Reset();
            SalesInvoiceheader.SetRange("No.", SalesHeader."External Document No.");
            IF SalesInvoiceheader.FindFirst() then
                InputDataJsonObj.Add('targetOrderId', SalesInvoiceheader."Order No.");
        end;



        InputDataJsonObj.Add('returnStatus', format(SalesHeader.Status));
        InputDataJsonObj.Add('currencyCode', SalesHeader."Currency Code");

        //InputDataJsonObj.Add('orderCreatedDate', format(SalesHeader."Order Date"));
        /*  IF EntityMapping.FindFirst() then;
          IF EntityMapping."Allow PaymentTerm Oubound Sync" = true then begin
              InputDataJsonObj.Add('targetNetTermsId', SalesHeader."Payment Terms Code");
          end;*/
        InputDataJsonObj.Add('shippingMethod', lowercase(EcommerceShippingCode));
        // InputDataJsonObj.Add('shippingTitle', lowercase(EcommerceShippingTitle));
        InputDataJsonObj.Add('payment', PaymentJsonArr);
        InputDataJsonObj.Get('payment', PaymentJsonToken);
        PaymentJsonArr := PaymentJsonToken.AsArray();
        clear(PaymentJsonObj);
        PaymentJsonObj.Add('paymentMethod', LowerCase(EcommercePaymentMethodCode));
        PaymentJsonArr.Add(PaymentJsonObj);

        /* SalesLine.Reset();
         SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::"Return Order");
         SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
         SalesLine.SetRange(SalesLine.Type, SalesLine.Type::"G/L Account");
         SalesLine.SetRange(SalesLine."No.", i95Setup."i95 Shipping Charge G/L Acc");
         If SalesLine.FindFirst() then
             InputDataJsonObj.Add('shippingAmount', format(SalesLine."Unit Price"))
         else
             InputDataJsonObj.Add('shippingAmount', 0);*/

        Clear(DiscountAmount);
        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        If SalesLine.Findset() then
            repeat
                DiscountAmount += SalesLine."Line Discount Amount";
            until SalesLine.Next() = 0;

        InputDataJsonObj.Add('subTotal', delchr(format(SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('orderDocumentAmount', delchr(format(SalesHeader."Amount Including VAT"), '=', ','));
        InputDataJsonObj.Add('taxAmount', delchr(format(SalesHeader."Amount Including VAT" - SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('discount', DiscountAmountJsonArr);
        InputDataJsonObj.Get('discount', DiscountAmountJsonToken);
        DiscountAmountJsonArr := DiscountAmountJsonToken.AsArray();

        clear(DiscountAmountJsonObj);
        DiscountAmountJsonObj.Add('discountType', 'discount');
        //DiscountAmountJsonObj.Add('discountAmount', format(DiscountAmount));
        DiscountAmountJsonObj.Add('discountAmount', delchr(format(DiscountAmount), '=', ','));

        DiscountAmountJsonArr.Add(DiscountAmountJsonObj);

        InputDataJsonObj.Add('orderItems', OrderItemsJsonArr);
        InputDataJsonObj.Get('orderItems', OrderItemsJsonToken);
        OrderItemsJsonArr := OrderItemsJsonToken.AsArray();

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                clear(OrderItemsJsonObj);

                if SalesLine."Variant Code" = '' then begin

                    OrderItemsJsonObj.Add('sku', SalesLine."No.");
                    // OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    //OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));

                    OrderItemsJsonObj.Add('qty', SalesLine.Quantity);
                    OrderItemsJsonObj.Add('price', SalesLine."Unit Price");
                    OrderItemsJsonObj.Add('typeId', 'Simple');
                    OrderItemsJsonObj.Add('reasonToReturn', SalesLine."Return Reason Code");

                    Clear(OrderItemsdiscountAmountJsonArr);
                    clear(OrderItemsdiscountAmountJsonObj);
                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::"Return Order");
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        // OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));

                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end else begin
                    Clear(VariantCode);
                    Clear(VariantSepratorCount);
                    Clear(Pattern);
                    Clear(PatternType);
                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");

                    OrderItemsJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
                    OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));
                    OrderItemsJsonObj.Add('markdownPrice', 0);
                    OrderItemsJsonObj.Add('parentSku', ItemVariant."Item No.");
                    OrderItemsJsonObj.Add('retailVariantId', ItemVariant.Code);

                    //Item Variant
                    Clear(OrderItemVariantJsonObj);
                    clear(OrderItemVariantJsonArr);
                    Clear(AttributewithKeyJsonArr);
                    OrderItemsJsonObj.Add('itemVariants', OrderItemVariantJsonArr);
                    OrderItemsJsonObj.Get('itemVariants', OrderItemVariantJsonToken);
                    OrderItemVariantJsonArr := OrderItemVariantJsonToken.AsArray();
                    clear(OrderItemVariantJsonObj);

                    OrderItemVariantJsonObj.Add('attributeWithKey', AttributewithKeyJsonArr);
                    OrderItemVariantJsonObj.get('attributeWithKey', AttributewithKeyJsonToken);
                    AttributewithKeyJsonArr := AttributewithKeyJsonToken.AsArray();
                    clear(AttributewithKeyJsonObj);

                    VariantCode := ItemVariant.Code;
                    VariantSepratorCount := STRLEN(DELCHR(VariantCode, '=', DELCHR(VariantCode, '=', i95Setup."i95 Item Variant Seperator")));

                    case VariantSepratorCount of
                        0:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 1";
                                PatternType := 1;
                            end;
                        1:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 2";
                                PatternType := 2;
                            end;
                        2:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 3";
                                PatternType := 3;
                            end;
                    end;

                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");
                    VariantCode := ItemVariant.Code;
                    for i := 1 to PatternType do begin
                        Clear(AttributewithKeyJsonObj);
                        Clear(AttributeCode);
                        Clear(AttributeValue);
                        if StrPos(Pattern, i95Setup."i95 Item Variant Seperator") <> 0 then begin
                            AttributeCode := copystr(CopyStr(Pattern, 1, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                            AttributeValue := copystr(copystr(VariantCode, 1, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);

                            Pattern := copystr(CopyStr(Pattern, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") + 1), 1, 30);
                            VariantCode := copystr(CopyStr(VariantCode, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") + 1), 1, 50);
                        end else begin
                            AttributeCode := CopyStr(Pattern, 1, 30);
                            AttributeValue := CopyStr(VariantCode, 1, 30);
                        end;

                        AttributewithKeyJsonObj.Add('attributeCode', AttributeCode);
                        AttributewithKeyJsonObj.Add('attributeValue', AttributeValue);
                        AttributewithKeyJsonObj.Add('attributeType', 'select');

                        AttributewithKeyJsonArr.Add(AttributewithKeyJsonObj);
                    end;

                    OrderItemVariantJsonArr.Add(OrderItemVariantJsonObj);

                    Clear(OrderItemsdiscountAmountJsonArr);
                    Clear(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::"Return Order");
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        //OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));
                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end;

            until SalesLine.Next() = 0;

        Clear(BillingAddressJsonObj);
        BillingAddressJsonObj.Add('targetCustomerId', SalesHeader."Bill-to Customer No.");
        // BillingAddressJsonObj.Add('targetAddressId', 'I95DEFAULT');
        BillingAddressJsonObj.Add('isDefaultBilling', true);
        if strpos(SalesHeader."Bill-to Name", ' ') <> 0 then begin
            BillingAddressJsonObj.Add('firstName', copystr(SalesHeader."Bill-to Name", 1, strpos(SalesHeader."Bill-to Name", ' ') - 1));
            BillingAddressJsonObj.Add('lastName', copystr(SalesHeader."Bill-to Name", strpos(SalesHeader."Bill-to Name", ' ') + 1));
        end else begin
            BillingAddressJsonObj.Add('firstName', SalesHeader."Bill-to Name");
            BillingAddressJsonObj.Add('lastName', SalesHeader."Bill-to Name");
        end;
        BillingAddressJsonObj.Add('street', SalesHeader."Bill-to Address");
        BillingAddressJsonObj.Add('street2', SalesHeader."Bill-to Address 2");
        BillingAddressJsonObj.Add('city', SalesHeader."Bill-to City");
        BillingAddressJsonObj.Add('postcode', SalesHeader."Bill-to Post Code");
        BillingAddressJsonObj.Add('countryId', SalesHeader."Bill-to Country/Region Code");
        BillingAddressJsonObj.Add('regionId', SalesHeader."Bill-to County");
        BillingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('billingAddress', BillingAddressJsonObj);

        Clear(ShippingAddressJsonObj);
        If SalesHeader."Ship-to Code" <> '' then
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Ship-to Code")
        else
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Bill-to Customer No.");
        if strpos(SalesHeader."Ship-to Name", ' ') <> 0 then begin
            ShippingAddressJsonObj.Add('firstName', copystr(SalesHeader."Ship-to Name", 1, strpos(SalesHeader."Ship-to Name", ' ') - 1));
            ShippingAddressJsonObj.Add('lastName', copystr(SalesHeader."Ship-to Name", strpos(SalesHeader."Ship-to Name", ' ') + 1))
        end else begin
            ShippingAddressJsonObj.Add('firstName', SalesHeader."Ship-to Name");
            ShippingAddressJsonObj.Add('lastName', SalesHeader."Ship-to Name");
        end;

        ShippingAddressJsonObj.Add('street', SalesHeader."Ship-to Address");
        ShippingAddressJsonObj.Add('street2', SalesHeader."Ship-to Address 2");
        ShippingAddressJsonObj.Add('city', SalesHeader."Ship-to City");
        ShippingAddressJsonObj.Add('postcode', SalesHeader."Ship-to Post Code");
        ShippingAddressJsonObj.Add('countryId', SalesHeader."Ship-to Country/Region Code");
        ShippingAddressJsonObj.Add('regionId', SalesHeader."Ship-to County");
        ShippingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('shippingAddress', ShippingAddressJsonObj);
        /* Clear(CustomerId);
         Clear(AvailableLimit);
         CustomerId := SalesHeader."Bill-to Customer No.";
         Customer.get(CustomerId);
         if Customer."Credit Limit (LCY)" > 0 then begin
             AvailableLimit := Customer.CalcAvailableCredit();
             InputDataJsonObj.Add('creditLimitType', 'Amount');
             InputDataJsonObj.Add('creditLimit', Customer."Credit Limit (LCY)");
             InputDataJsonObj.Add('availableLimit', AvailableLimit);
         end;

         i95Setup.Get();
         IF i95Setup."i95 Enable Company" = true then begin
             CustomerJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
             Contact.Reset();
             Contact.SetRange("No.", SalesHeader."Sell-to Contact No.");
             IF Contact.FindFirst() then begin
                 case Contact."i95 Customer Type" of
                     Contact."i95 Customer Type"::Admin:
                         CompanyJsonObj.Add('customerType', 'Admin');
                     Contact."i95 Customer Type"::User:
                         CompanyJsonObj.Add('customerType', 'User');
                     else
                         CompanyJsonObj.Add('customerType', format(Contact."i95 Customer Type"));
                 end;

             end;
             CompanyJsonObj.Add('targetParentId', SalesHeader."Sell-to Customer No.");
             CustomerJsonObj.Add('companyInfo', CompanyJsonObj);
             InputDataJsonObj.Add('customer', CustomerJsonObj);

         end;*/

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(SalesHeader."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;


    procedure SalesQuotePushData(SalesHeader: record "Sales Header"; var BodyContent: Text; EcommerceShippingCode: code[50]; EcommercePaymentMethodCode: Code[50]; EcommerceShippingTitle: text[50]; ShippingAgentCode: text[30])
    var
        SalesLine: Record "Sales Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        SalesLine2: Record "Sales Line";
        FirstSalesLine: Boolean;
        DiscountAmount: Decimal;
        AttributeCode: text[30];
        AttributeValue: Text[30];
        PatternType: Integer;
        Pattern: text[50];
        VariantCode: text[50];
        i: Integer;
        VariantSepratorCount: Integer;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        DiscountAmountJsonArr: JsonArray;
        DiscountAmountJsonObj: JsonObject;
        DiscountAmountJsonToken: JsonToken;
        PaymentJsonArr: JsonArray;
        PaymentJsonObj: JsonObject;
        PaymentJsonToken: JsonToken;
        OrderItemsJsonArr: JsonArray;
        OrderItemsJsonObj: JsonObject;
        OrderItemsJsonToken: JsonToken;
        OrderItemsdiscountAmountJsonArr: JsonArray;
        OrderItemsdiscountAmountJsonObj: JsonObject;
        OrderItemsdiscountAmountJsonToken: JsonToken;
        OrderItemVariantJsonArr: JsonArray;
        OrderItemVariantJsonObj: JsonObject;
        OrderItemVariantJsonToken: JsonToken;
        AttributewithKeyJsonArr: JsonArray;
        AttributewithKeyJsonObj: JsonObject;
        AttributewithKeyJsonToken: JsonToken;
        BillingAddressJsonObj: JsonObject;
        ShippingAddressJsonObj: JsonObject;
        CustomerJsonArr: JsonArray;
        CustomerJsonObj: JsonObject;
        CustomerJsonToken: JsonToken;
        CompanyJsonArr: JsonArray;
        CompanyJsonObj: JsonObject;
        CompanyJsonToken: JsonToken;
        Customer: Record Customer;
        Contact: Record Contact;
        CustomerId: text[50];
        AvailableLimit: Decimal;
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesLine := true;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();


        PushDatajsonObj.Add('Reference', Format(SalesHeader."Sell-to Customer No."));

        IF Customer.get(SalesHeader."Sell-to Customer No.") then
            IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Contact No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Contact No.")
            end else begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Customer No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            end;

        InputDataJsonObj.Add('isCancelled', 1);
        InputDataJsonObj.Add('carrierName', lowercase(ShippingAgentCode));

        case SalesHeader.Status of
            SalesHeader.Status::Open:
                begin
                    InputDataJsonObj.Add('quoteStatus', format(SalesHeader.Status));
                end;
            SalesHeader.Status::Released:
                begin
                    InputDataJsonObj.Add('quoteStatus', Format(SalesHeader.Status));
                end;
        end;

        InputDataJsonObj.Add('targetShippingAddressId', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('targetBillingAddressId', SalesHeader."Bill-to Customer No.");
        InputDataJsonObj.Add('orderCreatedDate', format(SalesHeader."Order Date"));

        InputDataJsonObj.Add('shippingMethod', lowercase(EcommerceShippingCode));
        InputDataJsonObj.Add('shippingTitle', lowercase(EcommerceShippingTitle));
        InputDataJsonObj.Add('payment', PaymentJsonArr);
        InputDataJsonObj.Get('payment', PaymentJsonToken);
        PaymentJsonArr := PaymentJsonToken.AsArray();
        clear(PaymentJsonObj);
        PaymentJsonObj.Add('paymentMethod', LowerCase(EcommercePaymentMethodCode));
        PaymentJsonArr.Add(PaymentJsonObj);

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange(SalesLine."No.", i95Setup."i95 Shipping Charge G/L Acc");
        If SalesLine.FindFirst() then
            InputDataJsonObj.Add('shippingAmount', format(SalesLine."Unit Price"))
        else
            InputDataJsonObj.Add('shippingAmount', 0);

        Clear(DiscountAmount);
        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        If SalesLine.Findset() then
            repeat
                DiscountAmount += SalesLine."Line Discount Amount";
            until SalesLine.Next() = 0;

        InputDataJsonObj.Add('subTotal', delchr(format(SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('quoteDocumentAmount', delchr(format(SalesHeader."Amount Including VAT"), '=', ','));
        InputDataJsonObj.Add('taxAmount', delchr(format(SalesHeader."Amount Including VAT" - SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('discount', DiscountAmountJsonArr);
        InputDataJsonObj.Get('discount', DiscountAmountJsonToken);
        DiscountAmountJsonArr := DiscountAmountJsonToken.AsArray();

        clear(DiscountAmountJsonObj);
        DiscountAmountJsonObj.Add('discountType', 'discount');
        //DiscountAmountJsonObj.Add('discountAmount', format(DiscountAmount));
        DiscountAmountJsonObj.Add('discountAmount', delchr(format(DiscountAmount), '=', ','));

        DiscountAmountJsonArr.Add(DiscountAmountJsonObj);

        InputDataJsonObj.Add('quoteItems', OrderItemsJsonArr);
        InputDataJsonObj.Get('quoteItems', OrderItemsJsonToken);
        OrderItemsJsonArr := OrderItemsJsonToken.AsArray();

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Quote);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                clear(OrderItemsJsonObj);

                if SalesLine."Variant Code" = '' then begin

                    OrderItemsJsonObj.Add('sku', SalesLine."No.");
                    // OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    //OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));

                    OrderItemsJsonObj.Add('qty', SalesLine.Quantity);
                    OrderItemsJsonObj.Add('price', SalesLine."Unit Price");

                    Clear(OrderItemsdiscountAmountJsonArr);
                    clear(OrderItemsdiscountAmountJsonObj);
                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Quote);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        // OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));

                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end else begin
                    Clear(VariantCode);
                    Clear(VariantSepratorCount);
                    Clear(Pattern);
                    Clear(PatternType);
                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");

                    OrderItemsJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
                    OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));
                    OrderItemsJsonObj.Add('markdownPrice', 0);
                    OrderItemsJsonObj.Add('parentSku', ItemVariant."Item No.");
                    OrderItemsJsonObj.Add('retailVariantId', ItemVariant.Code);

                    //Item Variant
                    Clear(OrderItemVariantJsonObj);
                    clear(OrderItemVariantJsonArr);
                    Clear(AttributewithKeyJsonArr);
                    OrderItemsJsonObj.Add('itemVariants', OrderItemVariantJsonArr);
                    OrderItemsJsonObj.Get('itemVariants', OrderItemVariantJsonToken);
                    OrderItemVariantJsonArr := OrderItemVariantJsonToken.AsArray();
                    clear(OrderItemVariantJsonObj);

                    OrderItemVariantJsonObj.Add('attributeWithKey', AttributewithKeyJsonArr);
                    OrderItemVariantJsonObj.get('attributeWithKey', AttributewithKeyJsonToken);
                    AttributewithKeyJsonArr := AttributewithKeyJsonToken.AsArray();
                    clear(AttributewithKeyJsonObj);

                    VariantCode := ItemVariant.Code;
                    VariantSepratorCount := STRLEN(DELCHR(VariantCode, '=', DELCHR(VariantCode, '=', i95Setup."i95 Item Variant Seperator")));

                    case VariantSepratorCount of
                        0:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 1";
                                PatternType := 1;
                            end;
                        1:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 2";
                                PatternType := 2;
                            end;
                        2:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 3";
                                PatternType := 3;
                            end;
                    end;

                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");
                    VariantCode := ItemVariant.Code;
                    for i := 1 to PatternType do begin

                        Clear(AttributewithKeyJsonObj);
                        Clear(AttributeCode);
                        Clear(AttributeValue);

                        if StrPos(Pattern, i95Setup."i95 Item Variant Seperator") <> 0 then begin
                            AttributeCode := copystr(CopyStr(Pattern, 1, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                            AttributeValue := copystr(copystr(VariantCode, 1, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);

                            Pattern := copystr(CopyStr(Pattern, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") + 1), 1, 30);
                            VariantCode := copystr(CopyStr(VariantCode, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") + 1), 1, 50);
                        end else begin
                            AttributeCode := CopyStr(Pattern, 1, 30);
                            AttributeValue := CopyStr(VariantCode, 1, 30);
                        end;

                        AttributewithKeyJsonObj.Add('attributeCode', AttributeCode);
                        AttributewithKeyJsonObj.Add('attributeValue', AttributeValue);
                        AttributewithKeyJsonObj.Add('attributeType', 'select');

                        AttributewithKeyJsonArr.Add(AttributewithKeyJsonObj);
                    end;

                    OrderItemVariantJsonArr.Add(OrderItemVariantJsonObj);

                    Clear(OrderItemsdiscountAmountJsonArr);
                    Clear(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Quote);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        //OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', delchr(format(SalesLine2."Line Discount Amount"), '=', ','));
                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end;

            until SalesLine.Next() = 0;

        Clear(BillingAddressJsonObj);
        BillingAddressJsonObj.Add('targetId', 'I95DEFAULT');
        //BillingAddressJsonObj.Add('isDefaultBilling', true);
        BillingAddressJsonObj.Add('Name', SalesHeader."Bill-to Name");
        if strpos(SalesHeader."Bill-to Name", ' ') <> 0 then begin
            BillingAddressJsonObj.Add('firstName', copystr(SalesHeader."Bill-to Name", 1, strpos(SalesHeader."Bill-to Name", ' ') - 1));
            BillingAddressJsonObj.Add('lastName', copystr(SalesHeader."Bill-to Name", strpos(SalesHeader."Bill-to Name", ' ') + 1));
        end else begin
            BillingAddressJsonObj.Add('firstName', SalesHeader."Bill-to Name");
            BillingAddressJsonObj.Add('lastName', SalesHeader."Bill-to Name");
        end;
        BillingAddressJsonObj.Add('street', SalesHeader."Bill-to Address");
        BillingAddressJsonObj.Add('street2', SalesHeader."Bill-to Address 2");
        BillingAddressJsonObj.Add('city', SalesHeader."Bill-to City");
        BillingAddressJsonObj.Add('postcode', SalesHeader."Bill-to Post Code");
        BillingAddressJsonObj.Add('countryId', SalesHeader."Bill-to Country/Region Code");
        BillingAddressJsonObj.Add('regionId', SalesHeader."Bill-to County");
        BillingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('billingAddress', BillingAddressJsonObj);

        Clear(ShippingAddressJsonObj);
        If SalesHeader."Ship-to Code" <> '' then
            ShippingAddressJsonObj.Add('targetId', SalesHeader."Ship-to Code")
        else
            ShippingAddressJsonObj.Add('targetId', SalesHeader."Bill-to Customer No.");

        ShippingAddressJsonObj.Add('Name', SalesHeader."Ship-to Name");

        if strpos(SalesHeader."Ship-to Name", ' ') <> 0 then begin
            ShippingAddressJsonObj.Add('firstName', copystr(SalesHeader."Ship-to Name", 1, strpos(SalesHeader."Ship-to Name", ' ') - 1));
            ShippingAddressJsonObj.Add('lastName', copystr(SalesHeader."Ship-to Name", strpos(SalesHeader."Ship-to Name", ' ') + 1))
        end else begin
            ShippingAddressJsonObj.Add('firstName', SalesHeader."Ship-to Name");
            ShippingAddressJsonObj.Add('lastName', SalesHeader."Ship-to Name");
        end;

        ShippingAddressJsonObj.Add('street', SalesHeader."Ship-to Address");
        ShippingAddressJsonObj.Add('street2', SalesHeader."Ship-to Address 2");
        ShippingAddressJsonObj.Add('city', SalesHeader."Ship-to City");
        ShippingAddressJsonObj.Add('postcode', SalesHeader."Ship-to Post Code");
        ShippingAddressJsonObj.Add('countryId', SalesHeader."Ship-to Country/Region Code");
        ShippingAddressJsonObj.Add('regionId', SalesHeader."Ship-to County");
        ShippingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        InputDataJsonObj.Add('shippingAddress', ShippingAddressJsonObj);
        Clear(CustomerId);
        Clear(AvailableLimit);
        CustomerId := SalesHeader."Bill-to Customer No.";
        Customer.get(CustomerId);
        if Customer."Credit Limit (LCY)" > 0 then begin
            AvailableLimit := Customer.CalcAvailableCredit();
            InputDataJsonObj.Add('creditLimitType', 'Amount');
            InputDataJsonObj.Add('creditLimit', Customer."Credit Limit (LCY)");
            InputDataJsonObj.Add('availableLimit', AvailableLimit);
        end;

        i95Setup.Get();
        IF i95Setup."i95 Enable Company" = true then begin
            CustomerJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            Contact.Reset();
            Contact.SetRange("No.", SalesHeader."Sell-to Contact No.");
            IF Contact.FindFirst() then begin
                case Contact.Type of
                    Contact.Type::Company:
                        CompanyJsonObj.Add('customerType', 'Admin');
                    Contact.Type::Person:
                        CompanyJsonObj.Add('customerType', 'User');
                    else
                        CompanyJsonObj.Add('customerType', format(Contact.Type));
                end;
            end;
            CompanyJsonObj.Add('targetParentId', SalesHeader."Sell-to Customer No.");
            CustomerJsonObj.Add('companyInfo', CompanyJsonObj);
            InputDataJsonObj.Add('customer', CustomerJsonObj);

        end;

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(SalesHeader."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;



    procedure SalesShipmentPushData(SalesShipHeader: Record "Sales Shipment Header"; Var
                                                                                         BodyContent: Text;
                                                                                         EcommerceShippingCode: code[50];
                                                                                         EcommerceShippingDescription: text[50];
                                                                                         ShippingAgentCode: text[30])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ShipmentItemEntityJsonArr: JsonArray;
        ShipmentItemEntityJsonObj: JsonObject;
        ShipmentItemEntityJsonToken: JsonToken;
        TrackingJsonArr: JsonArray;
        TrackingJsonObj: JsonObject;
        TrackingJsonToken: JsonToken;
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(SalesShipHeader."Order No."));

        InputDataJsonObj.Add('targetOrderId', FORMAT(SalesShipHeader."Order No."));
        InputDataJsonObj.Add('reference', FORMAT(SalesShipHeader."Order No."));
        InputDataJsonObj.Add('targetId', FORMAT(SalesShipHeader."No."));
        InputDataJsonObj.Add('targetOrderStatus', 'Shipped');
        InputDataJsonObj.Add('warehouseCode', SalesShipHeader."Location Code");

        InputDataJsonObj.Add('shipmentItemEntity', ShipmentItemEntityJsonArr);
        InputDataJsonObj.Get('shipmentItemEntity', ShipmentItemEntityJsonToken);
        ShipmentItemEntityJsonArr := ShipmentItemEntityJsonToken.AsArray();
        clear(ShipmentItemEntityJsonObj);

        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange(SalesShipmentLine."Document No.", SalesShipHeader."No.");
        SalesShipmentLine.SetRange(SalesShipmentLine.Type, SalesShipmentLine.Type::Item);
        If SalesShipmentLine.FindSet() then
            repeat
                clear(ShipmentItemEntityJsonObj);

                if SalesShipmentLine."Variant Code" = '' then
                    ShipmentItemEntityJsonObj.Add('orderItemId', FORMAT(SalesShipmentLine."No."))
                else begin
                    ItemVariant.get(SalesShipmentLine."No.", SalesShipmentLine."Variant Code");
                    ShipmentItemEntityJsonObj.Add('orderItemId', SalesShipmentLine."No." + i95Setup."i95 Item Variant Seperator" + SalesShipmentLine."Variant Code");
                end;
                ShipmentItemEntityJsonObj.Add('qty', delchr(FORMAT(SalesShipmentLine.Quantity), '=', ','));
                ShipmentItemEntityJsonObj.Add('lineNo', delchr(FORMAT(SalesShipmentLine."Line No."), '=', ','));

                ShipmentItemEntityJsonArr.Add(ShipmentItemEntityJsonObj);

            until SalesShipmentLine.next() = 0;

        If SalesShipHeader."Package Tracking No." <> '' then begin
            InputDataJsonObj.Add('tracking', TrackingJsonArr);
            InputDataJsonObj.Get('tracking', TrackingJsonToken);
            TrackingJsonArr := TrackingJsonToken.AsArray();
            clear(TrackingJsonObj);
            TrackingJsonObj.Add('trackNumber', FORMAT(SalesShipHeader."Package Tracking No."));
            TrackingJsonObj.Add('title', lowercase(EcommerceShippingDescription));
            TrackingJsonObj.Add('carrier', LowerCase(EcommerceShippingCode));
            TrackingJsonArr.Add(TrackingJsonObj);
        end;

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', SalesShipHeader."No.");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    END;

    procedure SalesInvoicePushData(SalesInvoiceHdr: Record "Sales Invoice Header"; var BodyContent: Text)
    var
        SalesInvoiceLines: Record "Sales Invoice Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        invoiceItemEntityJsonArr: JsonArray;
        invoiceItemEntityJsonObj: JsonObject;
        invoiceItemEntityJsonToken: JsonToken;
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        CommissionAmount: Decimal;
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(SalesInvoiceHdr."Order No."));

        InputDataJsonObj.Add('targetOrderId', Format(SalesInvoiceHdr."Order No."));
        InputDataJsonObj.Add('reference', SalesInvoiceHdr."Order No.");
        InputDataJsonObj.Add('Completed', 'Completed');
        InputDataJsonObj.Add('targetId', SalesInvoiceHdr."No.");
        InputDataJsonObj.Add('LastUpdated', Format(SalesInvoiceHdr."i95 Last Sync DateTime"));
        InputDataJsonObj.Add('CreatedDate', Format(SalesInvoiceHdr."i95 Created Date Time"));
        InputDataJsonObj.Add('salesPersonId', Format(SalesInvoiceHdr."Salesperson Code"));

        Clear(CommissionAmount);
        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document No.", SalesInvoiceHdr."No.");
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange("Customer No.", SalesInvoiceHdr."Sell-to Customer No.");
        IF CustomerLedgerEntry.FindFirst() then begin
            SalesPerson.Reset();
            SalesPerson.SetRange(Code, SalesInvoiceHdr."Salesperson Code");
            IF SalesPerson.FindFirst() then begin
                CommissionAmount := ROUND(CustomerLedgerEntry."Sales (LCY)" * SalesPerson."Commission %" / 100);
                InputDataJsonObj.Add('commissionAmount', CommissionAmount);
            end;

        end;


        InputDataJsonObj.Add('invoiceItemEntity', invoiceItemEntityJsonArr);
        InputDataJsonObj.Get('invoiceItemEntity', invoiceItemEntityJsonToken);
        invoiceItemEntityJsonArr := invoiceItemEntityJsonToken.AsArray();

        SalesInvoiceLines.Reset();
        SalesInvoiceLines.SetRange(SalesInvoiceLines."Document No.", SalesInvoiceHdr."No.");
        SalesInvoiceLines.SetRange(SalesInvoiceLines.Type, SalesInvoiceLines.Type::Item);
        If SalesInvoiceLines.FindSet() then
            repeat
                clear(invoiceItemEntityJsonObj);
                if SalesInvoiceLines."Variant Code" = '' then
                    invoiceItemEntityJsonObj.Add('orderItemId', Format(SalesInvoiceLines."No."))
                else begin
                    ItemVariant.get(SalesInvoiceLines."No.", SalesInvoiceLines."Variant Code");
                    invoiceItemEntityJsonObj.Add('orderItemId', SalesInvoiceLines."No." + i95Setup."i95 Item Variant Seperator" + SalesInvoiceLines."Variant Code");
                end;
                invoiceItemEntityJsonObj.Add('qty', delchr(format(SalesInvoiceLines.Quantity), '=', ','));
                invoiceItemEntityJsonObj.Add('lineNo', delchr(format(SalesInvoiceLines."Line No."), '=', ','));

                invoiceItemEntityJsonArr.Add(invoiceItemEntityJsonObj);

            until SalesInvoiceLines.Next() = 0;
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', SalesInvoiceHdr."No.");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesCreditMemoPushData(SalesCreditMemoHdr: Record "Sales Cr.Memo Header"; var BodyContent: Text)
    var
        SalesCreditMemoLines: Record "Sales Cr.Memo Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        CreditMemoItemEntityJsonArr: JsonArray;
        CreditMemoItemEntityJsonObj: JsonObject;
        CreditMemoItemEntityJsonToken: JsonToken;
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TargetShipmentIDs: Text;
        TargetInvoiceIDs: Text;
        SalesReturnHeader: Record "Sales Header";
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(SalesCreditMemoHdr."Return Order No."));

        InputDataJsonObj.Add('targetId', Format(SalesCreditMemoHdr."No."));
        InputDataJsonObj.Add('targetReturnId', Format(SalesCreditMemoHdr."Return Order No."));
        InputDataJsonObj.Add('reference', SalesCreditMemoHdr."Return Order No.");
        InputDataJsonObj.Add('isCancelled', 2);
        InputDataJsonObj.Add('CreatedDate', Format(SalesCreditMemoHdr."i95 Created Date Time"));

        InputDataJsonObj.Add('cancelItemEntity', CreditMemoItemEntityJsonArr);
        InputDataJsonObj.Get('cancelItemEntity', CreditMemoItemEntityJsonToken);
        CreditMemoItemEntityJsonArr := CreditMemoItemEntityJsonToken.AsArray();

        SalesCreditMemoLines.Reset();
        SalesCreditMemoLines.SetRange(SalesCreditMemoLines."Document No.", SalesCreditMemoHdr."No.");
        SalesCreditMemoLines.SetRange(SalesCreditMemoLines.Type, SalesCreditMemoLines.Type::Item);
        If SalesCreditMemoLines.FindSet() then
            repeat
                clear(CreditMemoItemEntityJsonObj);
                if SalesCreditMemoLines."Variant Code" = '' then
                    CreditMemoItemEntityJsonObj.Add('orderItemId', Format(SalesCreditMemoLines."No."))
                else begin
                    ItemVariant.get(SalesCreditMemoLines."No.", SalesCreditMemoLines."Variant Code");
                    CreditMemoItemEntityJsonObj.Add('orderItemId', SalesCreditMemoLines."No." + i95Setup."i95 Item Variant Seperator" + SalesCreditMemoLines."Variant Code");
                end;
                CreditMemoItemEntityJsonObj.Add('quantityToCancel', delchr(format(SalesCreditMemoLines.Quantity), '=', ','));
                // CreditMemoItemEntityJsonObj.Add('lineNo', delchr(format(SalesCreditMemoLines."Line No."), '=', ','));

                CreditMemoItemEntityJsonArr.Add(CreditMemoItemEntityJsonObj);

            until SalesCreditMemoLines.Next() = 0;

        //  InputDataJsonObj.Add('targetShipmentIds', '');
        //  InputDataJsonObj.Add('targetInvoiceIds', '');
        InputDataJsonObj.Add('updatedTime', Format(SalesCreditMemoHdr."i95 Last Sync DateTime"));

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', SalesCreditMemoHdr."No.");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CancelOrderPushData(DetSyncLogEntry: Record "i95 Detailed Sync Log Entry"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        customerJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();
        PushDatajsonObj.Add('Reference', DetSyncLogEntry."Field 2");
        InputDataJsonObj.Add('reference', DetSyncLogEntry."Field 2");
        InputDataJsonObj.Add('targetId', DetSyncLogEntry."Field 1");
        InputDataJsonObj.Add('isCancelled', 1);
        Clear(customerJsonObj);
        customerJsonObj.Add('targetId', DetSyncLogEntry."Field 2");

        customerJsonObj.Add('creditLimitType', 'NoCredit');
        InputDataJsonObj.Add('customer', customerJsonObj);
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', DetSyncLogEntry."Field 1");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CancelQuotePushData(DetSyncLogEntry: Record "i95 Detailed Sync Log Entry"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        customerJsonObj: JsonObject;
        CompanyInfoObj: JsonObject;
        ContactL: Record Contact;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', DetSyncLogEntry."Field 3");

        InputDataJsonObj.Add('targetId', DetSyncLogEntry."Field 1");
        InputDataJsonObj.Add('reference', DetSyncLogEntry."Field 3");
        InputDataJsonObj.Add('isCancelled', 1);
        InputDataJsonObj.Add('quoteStatus', 'rejected');
        InputDataJsonObj.Add('origin', 'Magento');
        InputDataJsonObj.Add('targetCustomerId', DetSyncLogEntry."Field 2");

        Clear(customerJsonObj);
        customerJsonObj.Add('targetId', DetSyncLogEntry."Field 3");
        customerJsonObj.Add('creditLimitType', 'NoCredit');
        InputDataJsonObj.Add('customer', customerJsonObj);

        ContactL.Reset();
        ContactL.SetRange("No.", DetSyncLogEntry."Field 3");
        IF ContactL.FindFirst() then
            CompanyInfoObj.Add('customerType', format(ContactL.Type));
        CompanyInfoObj.Add('targetParentId', DetSyncLogEntry."Field 2");
        customerJsonObj.Add('companyInfo', CompanyInfoObj);

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', DetSyncLogEntry."Field 1");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;


    procedure TaxBusPostingGroupPushData(TaxBusPostingGrp: Record "VAT Business Posting Group"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', TaxBusPostingGrp.Description);

        InputDataJsonObj.Add('code', TaxBusPostingGrp.Code);
        InputDataJsonObj.Add('description', TaxBusPostingGrp.Description);
        InputDataJsonObj.Add('targetId', TaxBusPostingGrp.Code);
        InputDataJsonObj.Add('reference', TaxBusPostingGrp.Description);

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', TaxBusPostingGrp.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure TaxProdPostingGroupPushData(TaxProdPostingGrp: Record "VAT Product Posting Group"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', TaxProdPostingGrp.Description);

        InputDataJsonObj.Add('Code', TaxProdPostingGrp.Code);
        InputDataJsonObj.Add('description', TaxProdPostingGrp.Description);
        InputDataJsonObj.Add('targetId', TaxProdPostingGrp.Code);
        InputDataJsonObj.Add('reference', TaxProdPostingGrp.Description);
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', TaxProdPostingGrp.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure PaymentTermsPushData(PaymentTerms: Record "Payment Terms"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', PaymentTerms.Code);

        InputDataJsonObj.Add('targetNetTermsId', PaymentTerms.Code);
        InputDataJsonObj.Add('targetId', PaymentTerms.Code);
        InputDataJsonObj.Add('dueTypeWithValue', FORMAT(PaymentTerms."Due Date Calculation"));
        InputDataJsonObj.Add('discountTypeWithValue', FORMAT(PaymentTerms."Discount Date Calculation"));
        InputDataJsonObj.Add('description', PaymentTerms.Description);
        InputDataJsonObj.Add('reference', PaymentTerms.Code);
        InputDataJsonObj.Add('discountPercentage', PaymentTerms."Discount %");
        InputDataJsonObj.Add('updatedTime', PaymentTerms."Last Modified Date Time");

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', PaymentTerms.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;


    procedure TaxPostingSetupPushData(TaxPostingSetup: Record "VAT Posting Setup"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', TaxPostingSetup."VAT Prod. Posting Group");

        InputDataJsonObj.Add('taxBusPostingGroupCode', TaxPostingSetup."VAT Bus. Posting Group");
        InputDataJsonObj.Add('taxProductPostingGroupCode', TaxPostingSetup."VAT Prod. Posting Group");
        InputDataJsonObj.Add('taxPercentage', format(TaxPostingSetup."VAT %"));
        InputDataJsonObj.Add('targetId', TaxPostingSetup."VAT Bus. Posting Group");
        InputDataJsonObj.Add('reference', TaxPostingSetup."VAT Prod. Posting Group");

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', TaxPostingSetup."VAT Bus. Posting Group");
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CustomerDiscountGroupPushData(CustDiscountGroup: Record "Customer Discount Group"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', CustDiscountGroup.Code);

        InputDataJsonObj.Add('targetId', CustDiscountGroup.Code);
        InputDataJsonObj.Add('reference', CustDiscountGroup.Code);
        InputDataJsonObj.Add('description', CustDiscountGroup.Description);

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', CustDiscountGroup.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ItemDiscountGroupPushData(ItemDiscountGroup: Record "Item Discount Group"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', ItemDiscountGroup.Code);

        InputDataJsonObj.Add('targetId', ItemDiscountGroup.Code);
        InputDataJsonObj.Add('reference', ItemDiscountGroup.Code);
        InputDataJsonObj.Add('description', ItemDiscountGroup.Description);
        InputDataJsonObj.Add('itemDiscountGroupId', ItemDiscountGroup.Code);
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', ItemDiscountGroup.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure PullResponse(MessageID: Integer; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('localMessageId', format(LocalMessageID));
        PushDatajsonObj.Add('entityId', EntityID);
        PushDatajsonObj.Add('messageStatus', MessageStatus);
        PushDatajsonObj.Add('syncCounter', SyncCounter);
        PushDatajsonObj.Add('schedulerId', SchedulerID);
        PushDatajsonObj.Add('messageId', MessageID);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure PullResponseAcknowledge(DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('localMessageId', format(LocalMessageID));
        PushDatajsonObj.Add('entityId', EntityID);
        PushDatajsonObj.Add('messageStatus', MessageStatus);
        PushDatajsonObj.Add('syncCounter', SyncCounter);
        PushDatajsonObj.Add('schedulerId', SchedulerID);
        PushDatajsonObj.Add('reference', DetailedSyncLogEntry."Field 2");
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        PushDatajsonObj.Add('targetId', DetailedSyncLogEntry."Target ID");
        PushDatajsonObj.Add('sourceId', format(DetailedSyncLogEntry."i95 Source ID"));

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SetDefaultValues(i95LocalMessageID: Integer; i95EntityID: Integer; i95MessageStatus: Integer; i95SyncCounter: Integer; i95SchedulerID: Integer)
    begin
        LocalMessageID := i95LocalMessageID;
        EntityID := i95EntityID;
        MessageStatus := i95MessageStatus;
        SyncCounter := i95SyncCounter;
        SchedulerID := i95SchedulerID;
    end;

    procedure CustomerPushResponseData(Customer: Record Customer; var BodyContent: Text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        ShipToAddress: Record "Ship-to Address";
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        AddressesJsonArr: JsonArray;
        AddressesJsonObj: JsonObject;
        AddressesJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
        CompanyJsonArr: JsonArray;
        CompanyJsonObj: JsonObject;
        CompanyJsonToken: JsonToken;
        Contact: Record Contact;
        ContactL: Record Contact;
        I95DevSetup: Record "i95 Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Customer."E-Mail");

        I95DevSetup.Get();
        IF I95DevSetup."i95 Enable Company" = true then begin
            /*InputDataJsonObj.Add('companyInfo', CompanyJsonArr);
            InputDataJsonObj.Get('companyInfo', CompanyJsonToken);
            CompanyJsonArr := CompanyJsonToken.AsArray();*/
            CompanyJsonObj.Add('sourceId', Customer."i95 Reference ID");
            CompanyJsonObj.Add('targetId', Customer."No.");
            InputDataJsonObj.Add('companyInfo', CompanyJsonObj);
        end;

        InputDataJsonObj.Add('addresses', AddressesJsonArr);
        InputDataJsonObj.Get('addresses', AddressesJsonToken);
        AddressesJsonArr := AddressesJsonToken.AsArray();

        ShipToAddress.Reset();
        ShipToAddress.SetRange(ShipToAddress."Customer No.", Customer."No.");
        if ShipToAddress.FindSet() then
            repeat
                clear(AddressesJsonObj);
                AddressesJsonObj.Add('targetId', ShipToAddress.Code);
                AddressesJsonObj.Add('sourceId', ShipToAddress.Code);
                AddressesJsonObj.Add('targetCustomerId', Customer."No.");
                AddressesJsonArr.Add(AddressesJsonObj);
            until ShipToAddress.Next() = 0;

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', DetailedSyncLogEntry."Message ID");
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('result', true)
        else
            PushDatajsonObj.Add('result', false);
        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('ResponseData', ResponseDataJsonObj);

        /*CompanyJsonArr := CompanyJsonToken.AsArray();
        Contact.Reset();
        Contact.SetRange("No.", Customer."Primary Contact No.");
        IF Contact.FindFirst() then
            repeat
                CompanyJsonObj.Add('sourceId', Contact."No.");
                CompanyJsonObj.Add('targetId', Contact."No.");
                CompanyJsonArr.Add(CompanyJsonObj);
            until Contact.Next() = 0;*/


        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
            // IF I95DevSetup."i95 Enable Company" = true then begin
            /* ContactBusinessRelation.Reset();
             ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
             ContactBusinessRelation.SetRange("No.", Customer."No.");
             IF ContactBusinessRelation.FindFirst() then begin*/
            Contact.Reset();
            Contact.SetRange("No.", DetailedSyncLogEntry."Field 3");
            Contact.SetFilter("i95 Reference ID", '<>%1', '');
            Contact.SetRange("i95 Enable Forward Sync", true);
            IF Contact.FindFirst() then begin
                PushDatajsonObj.Add('sourceId', Contact."i95 Reference ID");
                /*    ContactL.Reset();
                    ContactL.SetRange("i95 Reference ID", Contact."i95 Reference ID");
                    IF ContactL.FindFirst() then*/
                PushDatajsonObj.Add('targetId', Contact."No.");
            end else begin
                PushDatajsonObj.Add('TargetId', Customer."No.");
                PushDatajsonObj.Add('sourceId', format(DetailedSyncLogEntry."i95 Source ID"));
            end;
            /*   end;*/
            //end else begin

            // end;
        end else begin
            PushDatajsonObj.Add('TargetId', '');
        end;
        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('Keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CustomerPrieGroupPushResponseData(CustomerPriceGroup: Record "Customer Price Group"; var BodyContent: Text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', CustomerPriceGroup.Code);
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");
        PushDatajsonObj.Add('result', true);
        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        PushDatajsonObj.Add('targetId', CustomerPriceGroup.Code);
        PushDatajsonObj.Add('sourceId', format(DetailedSyncLogEntry."i95 Source ID"));
        PushDatajsonObj.Add('keys', KeysJsonObj);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesOrderPushResponseData(SalesHeader: Record "Sales Header"; var BodyContent: Text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        Customer: Record Customer;
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        If Customer.get(SalesHeader."Sell-to Customer No.") then;
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', Customer."E-Mail");
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('result', true)
        else
            PushDatajsonObj.Add('result', false);

        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('targetId', SalesHeader."No.")
        else
            PushDatajsonObj.Add('targetId', '');

        PushDatajsonObj.Add('sourceId', Format(DetailedSyncLogEntry."i95 Source ID"));

        IF (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesQuotePushResponseData(SalesHeader: Record "Sales Header"; var BodyContent: Text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        Customer: Record Customer;
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        If Customer.get(SalesHeader."Sell-to Customer No.") then;
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', Customer."E-Mail");
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('result', true)
        else
            PushDatajsonObj.Add('result', false);

        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('targetId', SalesHeader."No.")
        else
            PushDatajsonObj.Add('targetId', '');

        PushDatajsonObj.Add('sourceId', Format(DetailedSyncLogEntry."i95 Source ID"));

        IF (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesReturnPushResponseData(SalesHeader: Record "Sales Header"; var BodyContent: Text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        Customer: Record Customer;
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        If Customer.get(SalesHeader."Sell-to Customer No.") then;
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', Customer."E-Mail");
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('result', true)
        else
            PushDatajsonObj.Add('result', false);

        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('targetId', SalesHeader."No.")
        else
            PushDatajsonObj.Add('targetId', '');

        PushDatajsonObj.Add('sourceId', Format(DetailedSyncLogEntry."i95 Source ID"));

        IF (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ProductPushResponseData(Item: Record Item; var BodyContent: text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', Item.Description);
        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");

        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            PushDatajsonObj.Add('result', false)
        else
            PushDatajsonObj.Add('result', true);

        PushDatajsonObj.Add('statusId', 0);
        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);
        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('targetId', Item."No.")
        else
            PushDatajsonObj.Add('targetId', '');

        PushDatajsonObj.Add('sourceId', Format(DetailedSyncLogEntry."i95 Source ID"));

        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure EntityManagementPushAck(EntityMapping: Record "i95 Entity Mapping"; var BodyContent: text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        BodyContentjsonObj.Add('Type', 'entityUpdate');
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure CashRecieptPushResponseData(GeneralJournalLine: Record "Gen. Journal Line"; var BodyContent: text; DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry")
    var
        PushDatajsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        ResponseDataJsonObj: JsonObject;
        KeysJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('reference', GeneralJournalLine."Applies-to Doc. No.");

        PushDatajsonObj.Add('messageId', DetailedSyncLogEntry."Message ID");

        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            PushDatajsonObj.Add('result', false)
        else
            PushDatajsonObj.Add('result', true);

        PushDatajsonObj.Add('statusId', 0);

        PushDatajsonObj.Add('responseData', ResponseDataJsonObj);

        IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then
            PushDatajsonObj.Add('targetId', GeneralJournalLine."Document No.")
        else
            PushDatajsonObj.Add('targetId', '');

        PushDatajsonObj.Add('sourceId', Format(DetailedSyncLogEntry."i95 Source ID"));

        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            PushDatajsonObj.Add('message', DetailedSyncLogEntry."Error Message");

        PushDatajsonObj.Add('keys', KeysJsonObj);

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure DiscountPricePushData(Item: Record item; var BodyContent: text)
    var
        SalesLineDiscount: Record "Sales Line Discount";
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        DiscountPricesJsonArr: JsonArray;
        DiscountPricesJsonToken: JsonToken;
        DiscountPricesJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushdatajsonObj.Add('Reference', Item."No.");

        InputDataJsonObj.Add('targetId', Item."No.");
        InputDataJsonObj.Add('reference', Item."No.");

        InputDataJsonObj.Add('discountPrices', DiscountPricesJsonArr);
        InputDataJsonObj.get('discountPrices', DiscountPricesJsonToken);
        DiscountPricesJsonArr := DiscountPricesJsonToken.AsArray();

        SalesLineDiscount.Reset();
        SalesLineDiscount.SetRange(SalesLineDiscount.Type, SalesLineDiscount.Type::Item);
        SalesLineDiscount.SetRange(SalesLineDiscount.Code, Item."No.");
        if SalesLineDiscount.FindSet() then
            repeat
                Clear(DiscountPricesJsonObj);
                DiscountPricesJsonObj.Add('targetId', Item."No.");
                DiscountPricesJsonObj.Add('reference', Item."No.");
                DiscountPricesJsonObj.Add('code', Item."No.");
                DiscountPricesJsonObj.Add('salesCode', SalesLineDiscount."Sales Code");

                case SalesLineDiscount."Sales Type" of
                    SalesLineDiscount."Sales Type"::"Customer Disc. Group":
                        DiscountPricesJsonObj.Add('salesType', 'CustomerDiscountGroup');
                    SalesLineDiscount."Sales Type"::"All Customers":
                        DiscountPricesJsonObj.Add('salesType', 'AllCustomers');

                    else
                        DiscountPricesJsonObj.Add('salesType', format(SalesLineDiscount."Sales Type"));
                end;

                DiscountPricesJsonObj.Add('type', format(SalesLineDiscount.Type));
                DiscountPricesJsonObj.Add('price', format(SalesLineDiscount."Line Discount %"));
                DiscountPricesJsonObj.Add('qty', format(SalesLineDiscount."Minimum Quantity"));
                DiscountPricesJsonObj.Add('startDate', format(SalesLineDiscount."Starting Date"));
                DiscountPricesJsonObj.Add('endDate', format(SalesLineDiscount."Ending Date"));

            until SalesLineDiscount.Next() = 0;
        DiscountPricesJsonArr.Add(DiscountPricesJsonObj);

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);

        PushDatajsonObj.Add('TargetId', Item."No.");

        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure DiscountPriceItemDiscGrpPushData(ItemDiscGrp: Record "Item Discount Group"; var BodyContent: text)
    var
        SalesLineDiscount: Record "Sales Line Discount";
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        DiscountPricesJsonArr: JsonArray;
        DiscountPricesJsonToken: JsonToken;
        DiscountPricesJsonObj: JsonObject;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', ItemDiscGrp.Code);

        InputDataJsonObj.Add('targetId', ItemDiscGrp.Code);
        InputDataJsonObj.Add('reference', ItemDiscGrp.Code);

        InputDataJsonObj.Add('discountPrices', DiscountPricesJsonArr);
        InputDataJsonObj.get('discountPrices', DiscountPricesJsonToken);
        DiscountPricesJsonArr := DiscountPricesJsonToken.AsArray();

        SalesLineDiscount.Reset();
        SalesLineDiscount.SetRange(SalesLineDiscount.Type, SalesLineDiscount.Type::"Item Disc. Group");
        SalesLineDiscount.SetRange(SalesLineDiscount.Code, ItemDiscGrp.Code);
        if SalesLineDiscount.FindSet() then
            repeat
                Clear(DiscountPricesJsonObj);
                DiscountPricesJsonObj.Add('targetId', ItemDiscGrp.Code);
                DiscountPricesJsonObj.Add('reference', ItemDiscGrp.Code);
                DiscountPricesJsonObj.Add('code', ItemDiscGrp.Code);
                DiscountPricesJsonObj.Add('salesCode', SalesLineDiscount."Sales Code");

                case SalesLineDiscount."Sales Type" of
                    SalesLineDiscount."Sales Type"::"Customer Disc. Group":
                        DiscountPricesJsonObj.Add('salesType', 'CustomerDiscountGroup');
                    SalesLineDiscount."Sales Type"::"All Customers":
                        DiscountPricesJsonObj.Add('salesType', 'AllCustomers');
                    else
                        DiscountPricesJsonObj.Add('salesType', format(SalesLineDiscount."Sales Type"));
                end;

                If SalesLineDiscount.Type = SalesLineDiscount.Type::"Item Disc. Group" then
                    DiscountPricesJsonObj.Add('type', 'ItemDiscountGroup')
                else
                    DiscountPricesJsonObj.Add('type', format(SalesLineDiscount.Type));

                DiscountPricesJsonObj.Add('price', format(SalesLineDiscount."Line Discount %"));
                DiscountPricesJsonObj.Add('qty', format(SalesLineDiscount."Minimum Quantity"));
                DiscountPricesJsonObj.Add('startDate', format(SalesLineDiscount."Starting Date"));
                DiscountPricesJsonObj.Add('endDate', format(SalesLineDiscount."Ending Date"));

            until SalesLineDiscount.Next() = 0;
        DiscountPricesJsonArr.Add(DiscountPricesJsonObj);
        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', ItemDiscGrp.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ShippingAgentPushData(ShippingAgentService: Record "Shipping Agent Services"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        Valuechar: Char;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        //PushDatajsonObj.Add('requestData', Format(ShippingAgentService."Shipping Agent Code") + '-' + format(ShippingAgentService.Code));
        Valuechar := '\';
        RequestDataJsonArr.Add(format(Valuechar));
        RequestDataJsonArr.Add(Format(ShippingAgentService."Shipping Agent Code") + '-' + format(ShippingAgentService.Code + Format(Valuechar)));
        //RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
        BodyContent := BodyContent.Replace('"\\",', '\');
        BodyContent := BodyContent.Replace('\\', '\');
        BodyContent := BodyContent.Replace('[', '"[');
        BodyContent := BodyContent.Replace(']', ']"');
    end;

    procedure PaymentMethodPushData(PaymentMethod: Record "Payment Method"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        Valuechar: Char;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        //PushDatajsonObj.Add('requestData', Format(PaymentMethod.code));
        Valuechar := '\';
        RequestDataJsonArr.Add(format(Valuechar));
        RequestDataJsonArr.Add(Format(PaymentMethod.code + Format(Valuechar)));

        BodyContentjsonObj.WriteTo(BodyContent);

        BodyContent := BodyContent.Replace('"\\",', '\');
        BodyContent := BodyContent.Replace('\\', '\');
        BodyContent := BodyContent.Replace('[', '"[');
        BodyContent := BodyContent.Replace(']', ']"');

    end;

    procedure AccountRecievablePushData(CustomerLedgerEntry: Record "Cust. Ledger Entry"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        Valuechar: Char;
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', format(CustomerLedgerEntry."Entry No."));

        InputDataJsonObj.Add('targetId', CustomerLedgerEntry."Entry No.");
        InputDataJsonObj.Add('reference', CustomerLedgerEntry."Document No.");
        InputDataJsonObj.Add('targetInvoiceId', CustomerLedgerEntry."Document No.");
        InputDataJsonObj.Add('targetCustomerId', CustomerLedgerEntry."Customer No.");
        InputDataJsonObj.Add('journalNumber', CustomerLedgerEntry."Entry No.");
        CustomerLedgerEntry.CalcFields(Amount);
        CustomerLedgerEntry.CalcFields("Remaining Amount");
        InputDataJsonObj.Add('invoiceAmount', CustomerLedgerEntry.Amount);
        InputDataJsonObj.Add('outstandingAmount', CustomerLedgerEntry.Amount);
        InputDataJsonObj.Add('documentDate', CustomerLedgerEntry."Document Date");
        InputDataJsonObj.Add('unAppliedAmount', CustomerLedgerEntry."Remaining Amount");
        IF CustomerLedgerEntry.Open = false then
            InputDataJsonObj.Add('invoiceStatus', 'Closed')
        else
            InputDataJsonObj.Add('invoiceStatus', 'Open');

        // CustomerLedgerEntry.CalcFields("Original Pmt. Disc. Possible");
        InputDataJsonObj.Add('discountAmount', CustomerLedgerEntry."Original Pmt. Disc. Possible");
        IF CustomerLedgerEntry."Pmt. Discount Date" <> 0D then
            InputDataJsonObj.Add('discountDate', CustomerLedgerEntry."Pmt. Discount Date")
        else
            InputDataJsonObj.Add('discountDate', '');

        IF CustomerLedgerEntry."Due Date" <> 0D then
            InputDataJsonObj.Add('dueDate', CustomerLedgerEntry."Due Date")
        else
            InputDataJsonObj.Add('dueDate', '');

        InputDataJsonObj.Add('paymentMethod', CustomerLedgerEntry."Payment Method Code");

        IF CustomerLedgerEntry."Document Type" = CustomerLedgerEntry."Document Type"::Invoice then
            InputDataJsonObj.Add('type', 'invoice')
        else
            InputDataJsonObj.Add('type', 'payment');

        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("No.", CustomerLedgerEntry."Document No.");
        IF SalesInvoiceHeader.FindFirst() then begin
            InputDataJsonObj.Add('targetOrderId', SalesInvoiceHeader."Order No.");
        end;
        InputDataJsonObj.Add('sourceOrderId', CustomerLedgerEntry."i95 Reference ID");
        InputDataJsonObj.Add('updatedTime', CustomerLedgerEntry."i95 Last Sync DateTime");
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', format(CustomerLedgerEntry."Entry No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);

    end;

    procedure PostedCashReceiptPushData(CustomerLedgerEntry: Record "Cust. Ledger Entry"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        Valuechar: Char;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustomerJsonObj: JsonObject;
        CustomerLedgerEntryL: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        AvailableLimit: Decimal;

    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', format(CustomerLedgerEntry."Entry No."));

        InputDataJsonObj.Add('targetId', CustomerLedgerEntry."Entry No.");
        InputDataJsonObj.Add('receiptDocumentNumber', CustomerLedgerEntry."Document No.");
        CustomerLedgerEntry.CalcFields(Amount);
        InputDataJsonObj.Add('receiptAppliedAmount', CustomerLedgerEntry.Amount);
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("No.", CustomerLedgerEntry."Document No.");
        IF SalesInvoiceHeader.FindFirst() then
            InputDataJsonObj.Add('invoiceDate', SalesInvoiceHeader."Posting Date");

        InputDataJsonObj.Add('appliedDocUnappliedAmount', CustomerLedgerEntry.Amount);
        InputDataJsonObj.Add('transactionId', CustomerLedgerEntry."Transaction No.");
        InputDataJsonObj.Add('targetCustomerId', CustomerLedgerEntry."Customer No.");

        InputDataJsonObj.Add('paymentComment', '');
        InputDataJsonObj.Add('appliedDocumentType', 'cashreceipt');
        InputDataJsonObj.Add('appliedDocumentNumber', CustomerLedgerEntry."Document No.");
        InputDataJsonObj.Add('OrderPaymentMethod', CustomerLedgerEntry."Payment Method Code");
        InputDataJsonObj.Add('InitialDocumentType', format(CustomerLedgerEntry."Document Type"::Invoice));

        CustomerLedgerEntryL.Reset();
        CustomerLedgerEntryL.SetRange("Document No.", CustomerLedgerEntry."Document No.");
        CustomerLedgerEntryL.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        IF CustomerLedgerEntryL.FindFirst() then
            InputDataJsonObj.Add('CustLedgerPostedInvoiceEntryId', CustomerLedgerEntryL."Entry No.");

        InputDataJsonObj.Add('reference', CustomerLedgerEntry."Document No.");
        InputDataJsonObj.Add('paymentType', CustomerLedgerEntry."Payment Method Code");
        InputDataJsonObj.Add('modifiedDate', Today);
        SalesInvoiceHeader.Reset();
        SalesInvoiceHeader.SetRange("No.", CustomerLedgerEntry."Document No.");
        IF SalesInvoiceHeader.FindFirst() then begin
            InputDataJsonObj.Add('targetInvoiceId', SalesInvoiceHeader."No.");
            InputDataJsonObj.Add('targetOrderId', SalesInvoiceHeader."Order No.");
        end;
        InputDataJsonObj.Add('sourceOrderId', CustomerLedgerEntry."i95 Reference ID");
        InputDataJsonObj.Add('updatedTime', CurrentDateTime);
        Customer.Reset();
        Customer.SetRange("No.", CustomerLedgerEntry."Customer No.");
        IF Customer.FindFirst() then
            InputDataJsonObj.Add('customerType', Format(Customer."i95 Customer Type"));

        Customer.Reset();
        Customer.SetRange("No.", CustomerLedgerEntry."Customer No.");
        IF Customer.FindFirst() then begin
            if Customer."Credit Limit (LCY)" > 0 then begin
                AvailableLimit := Customer.CalcAvailableCredit();
                CustomerJsonObj.Add('targetCustomerId', Customer."No.");
                Customer.CalcFields("Credit Amount");
                CustomerJsonObj.Add('creditLimitAmount', Customer."Credit Limit (LCY)");
                CustomerJsonObj.Add('availableLimit', AvailableLimit);
                CustomerJsonObj.Add('creditLimitType', 'Amount');
            end;
        end;
        InputDataJsonObj.Add('customer', CustomerJsonObj);
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', format(CustomerLedgerEntry."Entry No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);

    end;

    procedure FinancechargePushData(IssuedFinanceCharge: Record "Issued Fin. Charge Memo Header"; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        InvoiceDataJsonObj: JsonObject;
        InvoicesDataJsonArr: JsonArray;
        InvoicesDataJsonToken: JsonToken;
        Valuechar: Char;
        CustomerJsonObj: JsonObject;
        Customer: Record Customer;
        AvailableLimit: Decimal;
        IssuedFinanceChargeLine: Record "Issued Fin. Charge Memo Line";
        PenaltyAmount: Decimal;
        additionalCharge: Decimal;
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', IssuedFinanceCharge."No.");

        InputDataJsonObj.Add('targetId', IssuedFinanceCharge."No.");
        InputDataJsonObj.Add('reference', IssuedFinanceCharge.Name);
        InputDataJsonObj.Add('journalNumber', IssuedFinanceCharge."No.");

        InputDataJsonObj.Add('targetCustomerId', IssuedFinanceCharge."Customer No.");
        InputDataJsonObj.Add('dueDate', IssuedFinanceCharge."Due Date");
        InputDataJsonObj.Add('documentDate', IssuedFinanceCharge."Document Date");
        InputDataJsonObj.Add('penaltyTerm', IssuedFinanceCharge."Fin. Charge Terms Code");
        InputDataJsonObj.Add('updatedTime', CurrentDateTime);


        InputDataJsonObj.Add('invoices', InvoicesDataJsonArr);
        InputDataJsonObj.Get('invoices', InvoicesDataJsonToken);
        InvoicesDataJsonArr := InvoicesDataJsonToken.AsArray();
        Clear(PenaltyAmount);
        Clear(additionalCharge);
        IssuedFinanceChargeLine.Reset();
        IssuedFinanceChargeLine.SetCurrentKey("Finance Charge Memo No.", "Line No.");
        IssuedFinanceChargeLine.SetRange("Finance Charge Memo No.", IssuedFinanceCharge."No.");
        IF IssuedFinanceChargeLine.FindFirst() then
            repeat
                clear(InvoiceDataJsonObj);
                InvoiceDataJsonObj.Add('targetInvoiceId', IssuedFinanceChargeLine."Document No.");
                InvoiceDataJsonObj.Add('outstandingAmount', IssuedFinanceChargeLine.Amount);
                InvoiceDataJsonObj.Add('invoiceAmount', IssuedFinanceChargeLine."Original Amount");
                InvoiceDataJsonObj.Add('comments', IssuedFinanceChargeLine.Description);
                IF not (IssuedFinanceChargeLine.Description = 'Additional Fee') then begin
                    PenaltyAmount += IssuedFinanceChargeLine.Amount;
                    IF IssuedFinanceChargeLine."Document Type" = IssuedFinanceChargeLine."Document Type"::Invoice then
                        InvoiceDataJsonObj.Add('type', 'invoice')
                    else
                        if IssuedFinanceChargeLine."Document Type" = IssuedFinanceChargeLine."Document Type"::"Finance Charge Memo" then
                            InvoiceDataJsonObj.Add('type', 'penalty')
                        else
                            if IssuedFinanceChargeLine."Document Type" = IssuedFinanceChargeLine."Document Type"::Reminder then
                                InvoiceDataJsonObj.Add('type', 'Reminder');

                end else begin
                    InvoiceDataJsonObj.Add('type', 'additional Fee');
                    additionalCharge += IssuedFinanceChargeLine.Amount;
                end;

                InvoicesDataJsonArr.Add(InvoiceDataJsonObj);
            until IssuedFinanceChargeLine.Next() = 0;
        // IssuedFinanceCharge.CalcFields("Remaining Amount", "Additional Fee", "Interest Amount", "VAT Amount");
        InputDataJsonObj.Add('outstandingAmount', PenaltyAmount + additionalCharge);
        InputDataJsonObj.Add('type', 'penalty');
        InputDataJsonObj.Add('additionalCharges', additionalCharge);
        InputDataJsonObj.Add('penaltyCharges', PenaltyAmount);
        InputDataJsonObj.Add('invoiceAmount', PenaltyAmount + additionalCharge);
        Customer.Reset();
        Customer.SetRange("No.", IssuedFinanceCharge."Customer No.");
        IF Customer.FindFirst() then begin
            InputDataJsonObj.Add('customerType', format(Customer."i95 Customer Type"));
            IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
                ContactBusinessRelation.Reset();
                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                ContactBusinessRelation.SetRange("No.", Customer."No.");
                IF ContactBusinessRelation.FindFirst() then begin
                    Contact.Reset();
                    Contact.SetRange("No.", ContactBusinessRelation."Contact No.");
                    IF Contact.FindFirst() then
                        InputDataJsonObj.Add('companyadminid', Contact."Company No.");
                end;

            end;
        end;

        Customer.Reset();
        Customer.SetRange("No.", IssuedFinanceCharge."Customer No.");
        IF Customer.FindFirst() then begin
            if Customer."Credit Limit (LCY)" > 0 then begin
                AvailableLimit := Customer.CalcAvailableCredit();
                CustomerJsonObj.Add('targetCustomerId', Customer."No.");
                Customer.CalcFields("Credit Amount");
                CustomerJsonObj.Add('creditLimitAmount', Customer."Credit Limit (LCY)");
                CustomerJsonObj.Add('availableLimit', AvailableLimit);
                CustomerJsonObj.Add('creditLimitType', 'Amount');
            end;
        end;
        InputDataJsonObj.Add('customer', CustomerJsonObj);
        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', format(IssuedFinanceCharge."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);

    end;

    procedure WarehouseLocationPushData(Location: Record Location; var BodyContent: Text)
    var
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;

    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Location.Name);

        InputDataJsonObj.Add('siteId', Location.Code);
        InputDataJsonObj.Add('warehouseName', Location.Name);
        InputDataJsonObj.Add('street', Location.Address);
        InputDataJsonObj.Add('streettwo', Location."Address 2");
        InputDataJsonObj.Add('email', Location."E-Mail");
        InputDataJsonObj.Add('state', Location.County);
        InputDataJsonObj.Add('city', Location.City);
        InputDataJsonObj.Add('country', Location."Country/Region Code");
        InputDataJsonObj.Add('phone', Location."Phone No.");
        InputDataJsonObj.Add('zip', Location."Post Code");
        InputDataJsonObj.Add('updatedTime', Location."i95 Last Sync DateTime");
        InputDataJsonObj.Add('targetId', Location.Code);

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', format(Location.Code));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);

    end;

    procedure EditSalesOrderPushData(SalesHeader: record "Sales Header"; var BodyContent: text; EcommerceShippingCode: code[50]; EcommercePaymentMethodCode: Code[50]; EcommerceShippingTitle: text[50]; ShippingAgentCode: text[30])
    var
        SalesLine: Record "Sales Line";
        i95Setup: Record "i95 Setup";
        ItemVariant: Record "Item Variant";
        SalesLine2: Record "Sales Line";
        FirstSalesLine: Boolean;
        DiscountAmount: Decimal;
        AttributeCode: text[30];
        AttributeValue: Text[30];
        PatternType: Integer;
        Pattern: text[50];
        VariantCode: text[50];
        i: Integer;
        VariantSepratorCount: Integer;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        DiscountAmountJsonArr: JsonArray;
        DiscountAmountJsonObj: JsonObject;
        DiscountAmountJsonToken: JsonToken;
        PaymentJsonArr: JsonArray;
        PaymentJsonObj: JsonObject;
        PaymentJsonToken: JsonToken;
        OrderItemsJsonArr: JsonArray;
        OrderItemsJsonObj: JsonObject;
        OrderItemsJsonToken: JsonToken;
        OrderItemsdiscountAmountJsonArr: JsonArray;
        OrderItemsdiscountAmountJsonObj: JsonObject;
        OrderItemsdiscountAmountJsonToken: JsonToken;
        OrderItemVariantJsonArr: JsonArray;
        OrderItemVariantJsonObj: JsonObject;
        OrderItemVariantJsonToken: JsonToken;
        AttributewithKeyJsonArr: JsonArray;
        AttributewithKeyJsonObj: JsonObject;
        AttributewithKeyJsonToken: JsonToken;
        BillingAddressJsonObj: JsonObject;
        ShippingAddressJsonObj: JsonObject;
        CustomerId: text[50];
        Customer: Record Customer;
        AvailableLimit: Decimal;
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        FirstSalesLine := true;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', Format(SalesHeader."Sell-to Customer No."));


        IF Customer.get(SalesHeader."Sell-to Customer No.") then
            IF Customer."i95 Customer Type" = Customer."i95 Customer Type"::Company then begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Contact No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Contact No.")
            end else begin
                InputDataJsonObj.Add('targetId', SalesHeader."No.");
                InputDataJsonObj.Add('reference', SalesHeader."Sell-to Customer No.");
                InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
            end;

        //InputDataJsonObj.Add('targetId', SalesHeader."No.");
        //InputDataJsonObj.Add('reference', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('targetOrderId', SalesHeader."No.");

        If SalesHeader."i95 Order Status" = SalesHeader."i95 Order Status"::Edited then
            InputDataJsonObj.Add('targetOrderEditStatus', 'edited')
        else
            if SalesHeader."i95 Order Status" = SalesHeader."i95 Order Status"::Updated then
                InputDataJsonObj.Add('targetOrderEditStatus', 'updated');

        InputDataJsonObj.Add('sourceOrderId', SalesHeader."i95 Reference ID");
        //InputDataJsonObj.Add('targetCustomerId', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('carrierName', lowercase(ShippingAgentCode));
        InputDataJsonObj.Add('targetShippingAddressId', SalesHeader."Sell-to Customer No.");
        InputDataJsonObj.Add('targetBillingAddressId', SalesHeader."Bill-to Customer No.");
        InputDataJsonObj.Add('orderCreatedDate', format(SalesHeader."Order Date"));
        InputDataJsonObj.Add('shippingMethod', lowercase(EcommerceShippingCode));
        InputDataJsonObj.Add('shippingTitle', lowercase(EcommerceShippingTitle));
        InputDataJsonObj.Add('payment', PaymentJsonArr);
        InputDataJsonObj.Get('payment', PaymentJsonToken);
        PaymentJsonArr := PaymentJsonToken.AsArray();
        clear(PaymentJsonObj);
        PaymentJsonObj.Add('paymentMethod', LowerCase(EcommercePaymentMethodCode));
        PaymentJsonArr.Add(PaymentJsonObj);

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange(SalesLine."No.", i95Setup."i95 Shipping Charge G/L Acc");
        If SalesLine.FindFirst() then
            InputDataJsonObj.Add('shippingAmount', format(SalesLine."Unit Price"))
        else
            InputDataJsonObj.Add('shippingAmount', 0);

        Clear(DiscountAmount);
        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        If SalesLine.Findset() then
            repeat
                DiscountAmount += SalesLine."Line Discount Amount";
            until SalesLine.Next() = 0;

        InputDataJsonObj.Add('subTotal', delchr(format(SalesHeader.Amount), '=', ','));
        InputDataJsonObj.Add('orderDocumentAmount', delchr(format(SalesHeader."Amount Including VAT"), '=', ','));
        InputDataJsonObj.Add('taxAmount', delchr(format(SalesHeader."Amount Including VAT" - SalesHeader.Amount), '=', ','));

        InputDataJsonObj.Add('discount', DiscountAmountJsonArr);
        InputDataJsonObj.Get('discount', DiscountAmountJsonToken);
        DiscountAmountJsonArr := DiscountAmountJsonToken.AsArray();
        clear(DiscountAmountJsonObj);

        DiscountAmountJsonObj.Add('discountType', 'discount');
        DiscountAmountJsonObj.Add('discountAmount', format(DiscountAmount));
        DiscountAmountJsonArr.Add(DiscountAmountJsonObj);

        InputDataJsonObj.Add('orderItems', OrderItemsJsonArr);
        InputDataJsonObj.Get('orderItems', OrderItemsJsonToken);
        OrderItemsJsonArr := OrderItemsJsonToken.AsArray();

        SalesLine.Reset();
        SalesLine.SetRange(SalesLine."Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(SalesLine."Document No.", SalesHeader."No.");
        SalesLine.SetRange(SalesLine.Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                clear(OrderItemsJsonObj);

                if SalesLine."Variant Code" = '' then begin

                    OrderItemsJsonObj.Add('sku', SalesLine."No.");
                    OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));

                    Clear(OrderItemsdiscountAmountJsonArr);
                    clear(OrderItemsdiscountAmountJsonObj);
                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end else begin
                    Clear(VariantCode);
                    Clear(VariantSepratorCount);
                    Clear(Pattern);
                    Clear(PatternType);
                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");

                    OrderItemsJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
                    OrderItemsJsonObj.Add('qty', delchr(format(SalesLine.Quantity), '=', ','));
                    OrderItemsJsonObj.Add('price', delchr(format(SalesLine."Unit Price"), '=', ','));
                    OrderItemsJsonObj.Add('markdownPrice', 0);
                    OrderItemsJsonObj.Add('parentSku', ItemVariant."Item No.");
                    OrderItemsJsonObj.Add('retailVariantId', ItemVariant.Code);

                    //Item Variant
                    Clear(OrderItemVariantJsonObj);
                    clear(OrderItemVariantJsonArr);
                    Clear(AttributewithKeyJsonArr);
                    OrderItemsJsonObj.Add('itemVariants', OrderItemVariantJsonArr);
                    OrderItemsJsonObj.Get('itemVariants', OrderItemVariantJsonToken);
                    OrderItemVariantJsonArr := OrderItemVariantJsonToken.AsArray();
                    clear(OrderItemVariantJsonObj);

                    OrderItemVariantJsonObj.Add('attributeWithKey', AttributewithKeyJsonArr);
                    OrderItemVariantJsonObj.get('attributeWithKey', AttributewithKeyJsonToken);
                    AttributewithKeyJsonArr := AttributewithKeyJsonToken.AsArray();
                    clear(AttributewithKeyJsonObj);

                    VariantCode := ItemVariant.Code;
                    VariantSepratorCount := STRLEN(DELCHR(VariantCode, '=', DELCHR(VariantCode, '=', i95Setup."i95 Item Variant Seperator")));

                    case VariantSepratorCount of
                        0:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 1";
                                PatternType := 1;
                            end;
                        1:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 2";
                                PatternType := 2;
                            end;
                        2:
                            begin
                                Pattern := i95Setup."i95 Item Variant Pattern 3";
                                PatternType := 3;
                            end;
                    end;

                    ItemVariant.get(SalesLine."No.", SalesLine."Variant Code");
                    VariantCode := ItemVariant.Code;
                    for i := 1 to PatternType do begin
                        Clear(AttributewithKeyJsonObj);
                        Clear(AttributeCode);
                        Clear(AttributeValue);
                        if StrPos(Pattern, i95Setup."i95 Item Variant Seperator") <> 0 then begin
                            AttributeCode := copystr(CopyStr(Pattern, 1, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                            AttributeValue := copystr(copystr(VariantCode, 1, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);

                            Pattern := copystr(CopyStr(Pattern, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") + 1), 1, 30);
                            VariantCode := copystr(CopyStr(VariantCode, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") + 1), 1, 50);
                        end else begin
                            AttributeCode := CopyStr(Pattern, 1, 30);
                            AttributeValue := CopyStr(VariantCode, 1, 30);
                        end;

                        AttributewithKeyJsonObj.Add('attributeCode', AttributeCode);
                        AttributewithKeyJsonObj.Add('attributeValue', AttributeValue);
                        AttributewithKeyJsonObj.Add('attributeType', 'select');

                        AttributewithKeyJsonArr.Add(AttributewithKeyJsonObj);
                    end;
                    OrderItemVariantJsonArr.Add(OrderItemVariantJsonObj);

                    Clear(OrderItemsdiscountAmountJsonArr);
                    Clear(OrderItemsdiscountAmountJsonObj);
                    OrderItemsJsonObj.Add('discount', OrderItemsdiscountAmountJsonArr);
                    OrderItemsJsonObj.Get('discount', OrderItemsdiscountAmountJsonToken);
                    OrderItemsdiscountAmountJsonArr := OrderItemsdiscountAmountJsonToken.AsArray();

                    SalesLine2.Reset();
                    SalesLine2.SetRange(SalesLine2."Document Type", SalesLine2."Document Type"::Order);
                    SalesLine2.SetRange(SalesLine2."Document No.", SalesHeader."No.");
                    SalesLine2.SetRange(SalesLine2."Line No.", SalesLine."Line No.");
                    If SalesLine2.FindFirst() then begin
                        OrderItemsdiscountAmountJsonObj.Add('discountType', 'discount');
                        OrderItemsdiscountAmountJsonObj.Add('discountAmount', format(SalesLine2."Line Discount Amount"));
                    end;
                    OrderItemsdiscountAmountJsonArr.Add(OrderItemsdiscountAmountJsonObj);

                    OrderItemsJsonObj.Add('lineNo', delchr(format(SalesLine."Line No."), '=', ','));
                    OrderItemsJsonArr.Add(OrderItemsJsonObj);
                end;

            until SalesLine.Next() = 0;

        Clear(BillingAddressJsonObj);
        BillingAddressJsonObj.Add('targetAddressId', 'I95DEFAULT');
        BillingAddressJsonObj.Add('isDefaultBilling', true);
        if strpos(SalesHeader."Bill-to Name", ' ') <> 0 then begin
            BillingAddressJsonObj.Add('firstName', copystr(SalesHeader."Bill-to Name", 1, strpos(SalesHeader."Bill-to Name", ' ') - 1));
            BillingAddressJsonObj.Add('lastName', copystr(SalesHeader."Bill-to Name", strpos(SalesHeader."Bill-to Name", ' ') + 1));
        end else begin
            BillingAddressJsonObj.Add('firstName', SalesHeader."Bill-to Name");
            BillingAddressJsonObj.Add('lastName', SalesHeader."Bill-to Name");
        end;
        BillingAddressJsonObj.Add('street', SalesHeader."Bill-to Address");
        BillingAddressJsonObj.Add('street2', SalesHeader."Bill-to Address 2");
        BillingAddressJsonObj.Add('city', SalesHeader."Bill-to City");
        BillingAddressJsonObj.Add('postcode', SalesHeader."Bill-to Post Code");
        BillingAddressJsonObj.Add('countryId', SalesHeader."Bill-to Country/Region Code");
        BillingAddressJsonObj.Add('regionId', SalesHeader."Bill-to County");
        if SalesHeader."Bill-to Contact" = '' then begin
            BillingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        end else begin
            BillingAddressJsonObj.Add('telephone', SalesHeader."Bill-to Contact");
        end;
        InputDataJsonObj.Add('billingAddress', BillingAddressJsonObj);

        Clear(ShippingAddressJsonObj);
        If SalesHeader."Ship-to Code" <> '' then
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Ship-to Code")
        else
            ShippingAddressJsonObj.Add('targetAddressId', SalesHeader."Bill-to Customer No.");
        if strpos(SalesHeader."Ship-to Name", ' ') <> 0 then begin
            ShippingAddressJsonObj.Add('firstName', copystr(SalesHeader."Ship-to Name", 1, strpos(SalesHeader."Ship-to Name", ' ') - 1));
            ShippingAddressJsonObj.Add('lastName', copystr(SalesHeader."Ship-to Name", strpos(SalesHeader."Ship-to Name", ' ') + 1))
        end else begin
            ShippingAddressJsonObj.Add('firstName', SalesHeader."Ship-to Name");
            ShippingAddressJsonObj.Add('lastName', SalesHeader."Ship-to Name");
        end;

        ShippingAddressJsonObj.Add('street', SalesHeader."Ship-to Address");
        ShippingAddressJsonObj.Add('street2', SalesHeader."Ship-to Address 2");
        ShippingAddressJsonObj.Add('city', SalesHeader."Ship-to City");
        ShippingAddressJsonObj.Add('postcode', SalesHeader."Ship-to Post Code");
        ShippingAddressJsonObj.Add('countryId', SalesHeader."Ship-to Country/Region Code");
        ShippingAddressJsonObj.Add('regionId', SalesHeader."Ship-to County");
        if SalesHeader."Ship-to Contact" = '' then begin
            ShippingAddressJsonObj.Add('telephone', SalesHeader."Sell-to Phone No.");
        end else begin
            ShippingAddressJsonObj.Add('telephone', SalesHeader."Ship-to Contact");
        end;
        InputDataJsonObj.Add('shippingAddress', ShippingAddressJsonObj);
        Clear(CustomerId);
        Clear(AvailableLimit);
        CustomerId := SalesHeader."Bill-to Customer No.";
        Customer.get(CustomerId);
        if Customer."Credit Limit (LCY)" > 0 then begin
            AvailableLimit := Customer.CalcAvailableCredit();
            InputDataJsonObj.Add('creditLimitType', 'Amount');
            InputDataJsonObj.Add('creditLimit', Customer."Credit Limit (LCY)");
            InputDataJsonObj.Add('availableLimit', AvailableLimit);
        end;

        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', format(SalesHeader."No."));
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure ChildProductPushData(ItemVariant: Record "Item Variant"; var BodyContent: Text)
    var
        i95Setup: Record "i95 Setup";
        Item: Record Item;
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        InputDataJsonArr: JsonArray;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        AttributewithKeyJsonArr: JsonArray;
        AttributewithKeyJsonObj: JsonObject;
        AttributewithKeyJsonToken: JsonToken;
        AttributeCode: text[30];
        AttributeValue: Text[30];
        PatternType: Integer;
        Pattern: text[50];
        VariantCode: text[50];
        i: Integer;
        VariantSepratorCount: Integer;
    begin
        i95Setup.get();
        i95Setup.TestField("i95 Item Variant Seperator");
        i95Setup.TestField("i95 Item Variant Pattern 1");
        i95Setup.TestField("i95 Item Variant Pattern 2");
        i95Setup.TestField("i95 Item Variant Pattern 3");

        Item.get(ItemVariant."Item No.");

        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;
        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', ItemVariant.Description);

        InputDataJsonObj.Add('targetId', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        InputDataJsonObj.Add('reference', ItemVariant.Description);
        InputDataJsonObj.Add('sku', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        InputDataJsonObj.Add('parentSku', ItemVariant."Item No.");
        InputDataJsonObj.Add('retailVariantId', ItemVariant.Code);
        InputDataJsonObj.Add('dateCreated', format(ItemVariant."i95 Created DateTime"));
        InputDataJsonObj.Add('name', ItemVariant.Description);
        InputDataJsonObj.Add('description', ItemVariant.Description);
        InputDataJsonObj.Add('shortDescription', ItemVariant."Description 2");

        InputDataJsonObj.Add('attributeWithKey', AttributewithKeyJsonArr);
        InputDataJsonObj.get('attributeWithKey', AttributewithKeyJsonToken);
        AttributewithKeyJsonArr := AttributewithKeyJsonToken.AsArray();
        clear(AttributewithKeyJsonObj);

        VariantCode := ItemVariant.Code;

        VariantSepratorCount := STRLEN(DELCHR(VariantCode, '=', DELCHR(VariantCode, '=', i95Setup."i95 Item Variant Seperator")));

        clear(Pattern);
        clear(PatternType);
        case VariantSepratorCount of
            0:
                begin
                    Pattern := i95Setup."i95 Item Variant Pattern 1";
                    PatternType := 1;
                end;
            1:
                begin
                    Pattern := i95Setup."i95 Item Variant Pattern 2";
                    PatternType := 2;
                end;
            2:
                begin
                    Pattern := i95Setup."i95 Item Variant Pattern 3";
                    PatternType := 3;
                end;
        end;

        for i := 1 to PatternType do begin
            Clear(AttributewithKeyJsonObj);
            if StrPos(Pattern, i95Setup."i95 Item Variant Seperator") <> 0 then begin
                AttributeCode := copystr(CopyStr(Pattern, 1, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);
                AttributeValue := copystr(copystr(VariantCode, 1, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") - 1), 1, 30);

                Pattern := copystr(CopyStr(Pattern, StrPos(Pattern, i95Setup."i95 Item Variant Seperator") + 1), 1, 30);
                VariantCode := copystr(CopyStr(VariantCode, strpos(VariantCode, i95Setup."i95 Item Variant Seperator") + 1), 1, 50);
            end else begin
                AttributeCode := CopyStr(Pattern, 1, 30);
                AttributeValue := CopyStr(VariantCode, 1, 30);
            end;

            AttributewithKeyJsonObj.Add('attributeCode', AttributeCode);
            AttributewithKeyJsonObj.Add('attributeValue', AttributeValue);
            AttributewithKeyJsonObj.Add('attributeType', 'select');

            AttributewithKeyJsonArr.Add(AttributewithKeyJsonObj);
        end;

        InputDataJsonArr.Add(AttributewithKeyJsonObj);

        InputDataJsonObj.Add('weight', format(Item."Gross Weight"));
        InputDataJsonObj.Add('price', format(Item."Unit Price"));
        If Item."Base Unit of Measure" <> '' then
            InputDataJsonObj.Add('unitOfMeasure', Item."Base Unit of Measure")
        else
            InputDataJsonObj.Add('unitOfMeasure', i95Setup."Default UOM");

        InputDataJsonObj.Add('isVisible', 1);
        InputDataJsonObj.Add('status', 1);
        InputDataJsonObj.Add('qty', 0);
        InputDataJsonObj.Add('updatedTime', format(ItemVariant."i95 Last Modification DateTime"));

        InputDataJsonObj.WriteTo(BodyContent);

        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('MessageId', 0);
        PushDatajsonObj.Add('TargetId', ItemVariant."Item No." + i95Setup."i95 Item Variant Seperator" + ItemVariant.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

    procedure SalesPersonPushData(SalesPerson: Record "Salesperson/Purchaser"; var BodyContent: Text)
    var
        FirstName: Text[100];
        LastName: Text[100];
        PushDatajsonObj: JsonObject;
        InputDataJsonObj: JsonObject;
        RequestDataJsonArr: JsonArray;
        RequestDataJsonToken: JsonToken;
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        TotalSales: Decimal;
        totalCommission: Decimal;
    begin
        if FirstRecord then
            BodyContentjsonObj.Add('requestData', RequestDataJsonArr);

        FirstRecord := false;

        If StrPos(SalesPerson.Name, ' ') <> 0 then begin
            FirstName := CopyStr(SalesPerson.Name, 1, StrPos(SalesPerson.Name, ' '));
            LastName := copystr(SalesPerson.Name, strpos(SalesPerson.Name, ' ') + 1, StrLen(SalesPerson.Name));
        end else begin
            FirstName := SalesPerson.Name;
            LastName := SalesPerson.Name;
        end;

        BodyContentjsonObj.Get('requestData', RequestDataJsonToken);
        RequestDataJsonArr := RequestDataJsonToken.AsArray();

        PushDatajsonObj.Add('Reference', SalesPerson."E-Mail");
        InputDataJsonObj.Add('salesPersonId', SalesPerson.Code);
        InputDataJsonObj.Add('firstName', FirstName);
        InputDataJsonObj.Add('lastName', LastName);
        InputDataJsonObj.Add('phoneNumber', SalesPerson."Phone No.");
        InputDataJsonObj.Add('percent', SalesPerson."Commission %");
        InputDataJsonObj.Add('userName', SalesPerson.Code);

        Clear(TotalSales);
        Clear(totalCommission);
        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange("Salesperson Code", SalesPerson.Code);
        IF CustomerLedgerEntry.FindSet() then
            repeat
                TotalSales += CustomerLedgerEntry."Sales (LCY)";

            until CustomerLedgerEntry.Next() = 0;
        IF TotalSales <> 0 then begin
            totalCommission := ROUND(TotalSales * SalesPerson."Commission %" / 100);
        end;
        InputDataJsonObj.Add('totalCommission', totalCommission);


        InputDataJsonObj.Add('reference', SalesPerson.Code);
        InputDataJsonObj.Add('targetId', SalesPerson.Code);
        InputDataJsonObj.Add('updatedTime', SalesPerson."i95 Last Modification DateTime");
        InputDataJsonObj.Add('email', SalesPerson."E-Mail");
        InputDataJsonObj.WriteTo(BodyContent);
        PushDatajsonObj.Add('InputData', BodyContent);
        PushDatajsonObj.Add('TargetId', SalesPerson.Code);
        RequestDataJsonArr.Add(PushDatajsonObj);
        BodyContentjsonObj.WriteTo(BodyContent);
    end;

}