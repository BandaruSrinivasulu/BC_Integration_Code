codeunit 70018 "I95 UpdateProductWithMapping"
{
    trigger OnRun()
    begin

        CreateItem(InventorySetupG, ItemLedgEntryG, NewItemG, SourceNoG, i95SetupG, NoSeriesMgtG, SourceRecordIDG, ResultDataJsonArrayG, ResultJsonTokenG, ResultDataJsonTokenG, ResultDataJsonObjectG, i95WebServiceExecuteCUG);
    end;

    procedure CreateItem(var InventorySetup: Record "Inventory Setup"; var ItemLedgEntry: Record "Item Ledger Entry"; var NewItem: Record Item; var SourceNo: Code[20]; var i95Setup: Record "i95 Setup"; var NoSeriesMgt: Codeunit NoSeriesManagement; var SourceRecordID: RecordId; Var ResultDataJsonArrayG: JsonArray;
var ResultJsonTokenG: JsonToken; var ResultDataJsonTokenG: JsonToken; var ResultDataJsonObjectG: JsonObject; var i95WebServiceExecuteCUG: Codeunit "i95 Webservice Execute")
    var
        RedDescription: Text;
        ProductAttributeMapping: Record "i95 Product Attribute Mapping";
        ItemRef: RecordRef;
        ItemFieldRef: FieldRef;
        index: Integer;
        Attribute: Text;
        Attribute1: Integer;
        Attribute2: Code[100];
        Attribute3: Decimal;
        NewItemRef: RecordRef;
        NewItemFieldRef: FieldRef;
        ResultJsonValueL: JsonValue;
        ResultJsonTokenL: JsonToken;
        DecimalValue: Decimal;
        countL: Integer;
    begin
        Clear(countL);
        clear(SourceRecordIDAs);
        InventorySetup.Get();
        i95Setup.get();
        If SourceNo <> '' then begin
            NewItem.reset();
            NewItem.SetCurrentKey("i95 Reference ID");
            NewItem.SetRange("i95 Reference ID", SourceNo);
            If not NewItem.FindFirst() then begin
                NewItem.init();

                If i95Setup."i95 Use Item Nos. from E-COM" then begin

                    IF ResultDataJsonObjectG.Contains('No.') then
                        IF ResultDataJsonObjectG.get('No.', ResultJsonTokenL) then begin
                            ResultJsonValueL := ResultJsonTokenL.AsValue();
                            NewItem.Validate("No.", ResultJsonValueL.AsCode());
                        end;
                end else
                    if i95Setup."Product Nos." <> '' then begin
                        NewItem.validate("No.", NoSeriesMgt.GetNextNo(i95Setup."Product Nos.", 0D, true))
                    end else
                        NewItem.validate("No.", NoSeriesMgt.GetNextNo(InventorySetup."Item Nos.", 0D, true));

                NewItem."i95 Created By" := 'i95';
                NewItem."i95 Created DateTime" := CurrentDateTime();
                NewItem."i95 Creation Source" := NewItem."i95 Creation Source"::i95;
                NewItem.insert();
            end;
            //New item creation with mapping start

            // NewItemRef.Open(Database::Item);
            NewItem.Seti95APIUpdateCall(true);
            If i95Setup."Default UOM" <> '' then
                NewItem.Validate("Base Unit of Measure", i95Setup."Default UOM");
            //NewItem.Validate(NewItem."Tax Group Code", TaxGroupCode);
            If i95Setup."i95 Gen. Prod. Posting Group" <> '' then
                NewItem.Validate("Gen. Prod. Posting Group", i95Setup."i95 Gen. Prod. Posting Group");
            if i95Setup."i95 Inventory Posting Group" <> '' then
                NewItem.Validate("Inventory Posting Group", i95Setup."i95 Inventory Posting Group");
            If i95Setup."i95 Tax Group Code" <> '' then
                NewItem.Validate("Tax Group Code", i95Setup."i95 Tax Group Code");
            NewItem.Modify();
            ItemRef.Open(Database::Item);
            NewItemRef.GetTable(NewItem);
            countL := ItemRef.FieldCount;
            //ProductAttributeMapping.Reset();
            // IF ProductAttributeMapping.FindSet() then
            //repeat
            index := 0;
            repeat

                Clear(ResultJsonValueL);
                Clear(ResultJsonTokenL);
                Clear(DecimalValue);


                index := index + 1;
                ItemFieldRef := ItemRef.FieldIndex(Index);
                if ResultDataJsonObjectG.Contains(format(ItemFieldRef.Name)) = true then begin

                    IF ResultDataJsonObjectG.get(format(ItemFieldRef.Name), ResultJsonTokenL) then begin
                        ResultJsonValueL := ResultJsonTokenL.AsValue();

                        if not ResultJsonValueL.IsNull() then begin
                            IF ItemFieldRef.Type = ItemFieldRef.Type::Text then begin
                                IF ResultJsonValueL.AsText() <> '' then begin
                                    NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                    NewItemFieldRef.Validate(ResultJsonValueL.AsText());
                                    NewItemRef.Modify();
                                end;
                            end else
                                if ItemFieldRef.Type = ItemFieldRef.Type::Code then begin
                                    IF ResultJsonValueL.AsCode() <> '' then begin
                                        IF not (ItemFieldRef.Name = 'No.') then begin
                                            NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                            NewItemFieldRef.Validate(ResultJsonValueL.AsCode());
                                            NewItemRef.Modify();
                                        end;

                                    end;

                                end else
                                    if ItemFieldRef.Type = ItemFieldRef.Type::Decimal then begin
                                        IF not ResultJsonValueL.IsNull() then begin
                                            NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                            IF format(ResultJsonValueL) <> '' then
                                                DecimalValue := Round(ResultJsonValueL.AsDecimal(), 0.01, '=');
                                            NewItemFieldRef.Validate(DecimalValue);
                                            NewItemRef.Modify();
                                        end;

                                    end else
                                        if ItemFieldRef.Type = ItemFieldRef.Type::Integer then begin
                                            IF ResultJsonValueL.AsInteger() <> 0 then begin
                                                NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                NewItemFieldRef.Validate(ResultJsonValueL.AsInteger());
                                                NewItemRef.Modify();
                                            end;

                                        end else
                                            if (ItemFieldRef.Type = ItemFieldRef.Type::Option) or (ItemFieldRef.Type = ItemFieldRef.Type::DateFormula) then begin
                                                NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                NewItemFieldRef.Validate(ResultJsonValueL.AsOption());
                                                NewItemRef.Modify();
                                            end else
                                                if ItemFieldRef.Type = ItemFieldRef.Type::DateTime then begin
                                                    IF ResultJsonValueL.AsDateTime() <> 0DT then begin
                                                        NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                        NewItemFieldRef.Validate(ResultJsonValueL.AsDateTime());
                                                        NewItemRef.Modify();
                                                    end;
                                                end else
                                                    if ItemFieldRef.Type = ItemFieldRef.Type::Boolean then begin
                                                        IF ResultJsonValueL.AsBoolean() <> false then begin
                                                            NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                            NewItemFieldRef.Validate(ResultJsonValueL.AsBoolean());
                                                            NewItemRef.Modify();
                                                        end;
                                                    end else
                                                        if ItemFieldRef.Type = ItemFieldRef.Type::Date then begin
                                                            IF ResultJsonValueL.AsDate() <> 0D then begin
                                                                NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                                NewItemFieldRef.Validate(ResultJsonValueL.AsDate());
                                                                NewItemRef.Modify();
                                                            end;
                                                        end else
                                                            if ItemFieldRef.Type = ItemFieldRef.Type::Time then begin
                                                                IF ResultJsonValueL.AsTime() <> 0T then begin
                                                                    NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                                    NewItemFieldRef.Validate(ResultJsonValueL.AsTime());
                                                                    NewItemRef.Modify();
                                                                end;
                                                            end else
                                                                if ItemFieldRef.Type = ItemFieldRef.Type::Guid then begin
                                                                    IF ResultJsonValueL.AsBigInteger() <> 0 then begin
                                                                        NewItemFieldRef := NewItemRef.Field(ItemFieldRef.Number);
                                                                        NewItemFieldRef.Validate(ResultJsonValueL.AsBigInteger());
                                                                        NewItemRef.Modify();
                                                                    end;
                                                                end;
                            NewItemRef.Modify();
                        end;
                    end;
                end;
            until index = countL;

            /*if not SourceJsonObject.Contains(JsonTag) then
                 exit('');
             SourceJsonObject.get(JsonTag, SourceJsonToken);
             ReturnJsonValue := SourceJsonToken.AsValue();
             if not ReturnJsonValue.IsNull() then
                 exit(ReturnJsonValue.AsText());


          IF format(ItemFieldRef.Type) = 'Text' then begin
              Attribute := i95WebserviceExecuteCUG.ProcessJsonTokenasText(Format(ItemFieldRef.Name), ResultDataJsonObjectG);
              IF Attribute <> '' then begin
                  IF Format(ItemFieldRef.Name) = ProductAttributeMapping.BCAttribute then begin
                      NewItemFieldRef := ItemRef.Field(index);
                      NewItemFieldRef.Validate(Attribute);
                      NewItemRef.Modify();
                  end else
                      IF Format(ItemFieldRef.Name) = 'Description' then begin
                          Clear(RedDescription);//changes for reducing desc
                          RedDescription := CopyStr(Attribute, 1, 50);
                      end else
                          IF Format(ItemFieldRef.Name) = 'Description 2' then
                              NewItemFieldRef := ItemRef.Field(index);
                  NewItemFieldRef.Validate(RedDescription);
                  NewItemRef.Modify();
              end;

              NewItemRef.Modify();
          end else
              IF Format(ItemFieldRef.Type) = 'Code' then begin
                  Attribute2 := i95WebServiceExecuteCUG.ProcessJsonTokenasCode(Format(ItemFieldRef.Name), ResultDataJsonObjectG);
                  IF Attribute2 <> '' then begin
                      IF Format(ItemFieldRef.Name) = ProductAttributeMapping.BCAttribute then begin
                          NewItemFieldRef := ItemRef.Field(index);
                          NewItemFieldRef.Value(Attribute2);
                          NewItemRef.Modify();
                      end else
                          IF Format(ItemFieldRef.Name) = 'Base Unit of Measure' then begin
                              NewItemFieldRef := ItemRef.Field(index);
                              IF i95Setup."Default UOM" <> '' then
                                  NewItemFieldRef.Validate(i95Setup."Default UOM");
                              NewItemRef.Modify();
                          end else
                              IF Format(ItemFieldRef.Name) = 'Gen. Prod. Posting Group' then begin
                                  NewItemFieldRef := ItemRef.Field(index);
                                  IF i95Setup."i95 Gen. Prod. Posting Group" <> '' then
                                      NewItemFieldRef.Validate(i95Setup."i95 Gen. Prod. Posting Group");
                                  NewItemRef.Modify();
                              end else
                                  IF Format(ItemFieldRef.Name) = 'Inventory Posting Group' then begin
                                      NewItemFieldRef := ItemRef.Field(index);
                                      if i95Setup."i95 Inventory Posting Group" <> '' then
                                          NewItemFieldRef.Validate(i95Setup."i95 Inventory Posting Group");
                                      NewItemRef.Modify();
                                  end else
                                      IF Format(ItemFieldRef.Name) = 'Tax Group Code' then begin
                                          NewItemFieldRef := ItemRef.Field(index);
                                          If i95Setup."i95 Tax Group Code" <> '' then
                                              NewItemFieldRef.Validate(i95Setup."i95 Tax Group Code");
                                          NewItemRef.Modify();
                                      end else

                                          IF Format(ItemFieldRef.Name) = 'i95 Last Modified By' then begin
                                              NewItemFieldRef := ItemRef.Field(index);
                                              NewItemFieldRef.Validate(copystr(UserId(), 1, 80));
                                              NewItemRef.Modify();
                                          end else
                                              IF Format(ItemFieldRef.Name) = 'i95 Reference ID' then begin
                                                  NewItemFieldRef := ItemRef.Field(index);
                                                  NewItemFieldRef.Validate(SourceNo);
                                                  NewItemRef.Modify();
                                              end;
                      NewItemRef.Modify();
                  end;
              end else
                  if Format(ItemFieldRef.Type) = 'Decimal' then begin
                      Attribute3 := i95WebServiceExecuteCUG.ProcessJsonTokenasDecimal(Format(ItemFieldRef.Name), ResultDataJsonObjectG);
                      IF Attribute3 <> 0 then begin
                          IF Format(ItemFieldRef.Name) = ProductAttributeMapping.BCAttribute then begin

                              IF Format(ItemFieldRef.Name) = 'Cost' then begin
                                  If NewItem."Costing Method" = NewItem."Costing Method"::Standard then begin
                                      NewItemFieldRef := ItemRef.Field(index);
                                      NewItemFieldRef.Validate(Attribute3);
                                      NewItemRef.Modify();
                                  end else begin
                                      ItemLedgEntry.SETCURRENTKEY("Item No.");
                                      ItemLedgEntry.SETRANGE("Item No.", NewItem."No.");

                                      IF ItemLedgEntry.ISEMPTY() THEN
                                          NewItemFieldRef := ItemRef.Field(index);
                                      NewItemFieldRef.Validate(Attribute3);
                                      NewItemRef.Modify();
                                  end;
                              end else begin
                                  NewItemFieldRef := ItemRef.Field(index);
                                  NewItemFieldRef.Validate(Attribute3);
                                  NewItemRef.Modify();
                              end;
                          end;
                      end;

                  end else
                      if Format(ItemFieldRef.Type) = 'Integer' then begin
                          Attribute1 := i95WebServiceExecuteCUG.ProcessJsonTokenasInteger(Format(ItemFieldRef.Name), ResultDataJsonObjectG);
                          IF Attribute1 <> 0 then begin
                              IF Format(ItemFieldRef.Name) = ProductAttributeMapping.BCAttribute then begin
                                  NewItemFieldRef := ItemRef.Field(index);
                                  NewItemFieldRef.Validate(Attribute1);
                                  NewItemRef.Modify();
                              end;
                          end;
                      end else
                          if Format(ItemFieldRef.Type) = 'Option' then begin
                              IF Format(ItemFieldRef.Name) = 'i95 Sync Status' then begin
                                  NewItemFieldRef := ItemRef.Field(index);
                                  NewItemFieldRef.Validate(NewItem."i95 Sync Status"::"Waiting for Response");
                                  NewItemRef.Modify();
                              end;
                              IF Format(ItemFieldRef.Name) = 'i95 Last Modification Source' then begin
                                  NewItemFieldRef := ItemRef.Field(index);
                                  NewItemFieldRef.Validate(NewItem."i95 Last Modification Source"::i95);
                                  NewItemRef.Modify();
                              end;
                          end else
                              if Format(ItemFieldRef.Type) = 'DateTime' then begin
                                  IF Format(ItemFieldRef.Name) = 'i95 Last Modification DateTime' then begin
                                      NewItemFieldRef := ItemRef.Field(index);
                                      NewItemFieldRef.Validate(CurrentDateTime());
                                      NewItemRef.Modify();
                                  end;
                                  IF Format(ItemFieldRef.Name) = 'i95 Last Sync DateTime' then begin
                                      NewItemFieldRef := ItemRef.Field(index);
                                      NewItemFieldRef.Validate(CurrentDateTime());
                                      NewItemRef.Modify();
                                  end;
                              end;

          NewItemRef.Modify();*/

            // until index = 250;

            //until ProductAttributeMapping.Next() = 0;


            //New item creation with mapping end

            // NewItem.Validate(NewItem."Description 2", Description);

            //NewItem.Modify(false);

            SourceRecordIDAs := NewItemRef.RecordId();

            //NewItem.Seti95APIUpdateCall(true);
            // NewItem."i95 Last Modification DateTime" := CurrentDateTime();
            //NewItem."i95 Last Modified By" := copystr(UserId(), 1, 80);
            //NewItem."i95 Last Sync DateTime" := CurrentDateTime();
            // NewItem."i95 Sync Status" := NewItem."i95 Sync Status"::"Waiting for Response";
            // NewItem."i95 Last Modification Source" := NewItem."i95 Last Modification Source"::i95;
            // NewItem."i95 Reference ID" := SourceNo;
            //NewItem.Modify(false);
        end;
    end;

    procedure GetSourceRecordID(Var SourceRecordIDP: RecordId;

    Var
        ItemNo: code[20])
    begin
        SourceRecordIDP := SourceRecordIDAs;
        ItemNo := NewItemG."No.";

    end;

    procedure set(var InventorySetupP: Record "Inventory Setup"; var ItemLedgEntryP: Record "Item Ledger Entry"; var NewItemP: Record Item; var SourceNoP: Code[20]; var i95SetupP: Record "i95 Setup"; var NoSeriesMgtP: Codeunit NoSeriesManagement; var SourceRecordIDP: RecordId; Var ResultDataJsonArrayP: JsonArray;
var ResultJsonTokenP: JsonToken; var ResultDataJsonTokenP: JsonToken; var ResultDataJsonObjectP: JsonObject; var i95WebServiceExecuteCUP: Codeunit "i95 Webservice Execute")
    begin
        InventorySetupG := InventorySetupP;
        ItemLedgEntryG := ItemLedgEntryP;
        NewItemG := NewItemP;
        SourceNoG := SourceNoP;
        i95SetupG := i95SetupP;
        NoSeriesMgtG := NoSeriesMgtP;
        SourceRecordIDG := SourceRecordIDP;
        ResultDataJsonArrayG := ResultDataJsonArrayP;
        ResultDataJsonObjectG := ResultDataJsonObjectP;
        ResultDataJsonTokenG := ResultDataJsonTokenP;
        ResultJsonTokenG := ResultJsonTokenP;
        i95WebServiceExecuteCUG := i95WebServiceExecuteCUP;


    end;


    var
        InventorySetupG: Record "Inventory Setup";
        ItemLedgEntryG: Record "Item Ledger Entry";
        NewItemG: Record Item;
        SourceNoG: Code[20];

        i95SetupG: Record "i95 Setup";
        SourceRecordIDAs: RecordId;
        NoSeriesMgtG: Codeunit NoSeriesManagement;
        SourceRecordIDG: RecordId;
        ResultDataJsonArrayG: JsonArray;
        ResultJsonTokenG: JsonToken;
        ResultDataJsonTokenG: JsonToken;
        ResultDataJsonObjectG: JsonObject;
        i95WebServiceExecuteCUG: Codeunit "i95 Webservice Execute";

}