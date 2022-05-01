codeunit 70013 "i95 Update Product"
{

    trigger OnRun()
    begin

        CreateItem(InventorySetupG, ItemLedgEntryG, NewItemG, SourceNoG, NameG, PriceG, WeightG, CostG, DescriptionG, SkuG, i95SetupG, NoSeriesMgtG, SourceRecordIDG);
    end;

    procedure CreateItem(var InventorySetup: Record "Inventory Setup"; var ItemLedgEntry: Record "Item Ledger Entry"; var NewItem: Record Item; var SourceNo: Code[20]; var Name: Text; var Price: Decimal; var Weight: Decimal; var Cost: Decimal; var Description: Text; var Sku: text; var i95Setup: Record "i95 Setup"; var NoSeriesMgt: Codeunit NoSeriesManagement; var SourceRecordID: RecordId)
    var
        RedDescription: Text;
    begin

        clear(SourceRecordIDAs);
        InventorySetup.Get();
        i95Setup.get();
        If SourceNo <> '' then begin
            /*NewItem.reset();
            NewItem.SetCurrentKey("i95 Reference ID");
            NewItem.SetRange("i95 Reference ID", SourceNo);
            If not NewItem.FindFirst() then begin*/
            NewItem.init();

            If i95Setup."i95 Use Item Nos. from E-COM" then
                NewItem.Validate("No.", Sku)
            else
                if i95Setup."Product Nos." <> '' then
                    NewItem.validate("No.", NoSeriesMgt.GetNextNo(i95Setup."Product Nos.", 0D, true))
                else
                    NewItem.validate("No.", NoSeriesMgt.GetNextNo(InventorySetup."Item Nos.", 0D, true));

            NewItem."i95 Created By" := 'i95';
            NewItem."i95 Created DateTime" := CurrentDateTime();
            NewItem."i95 Creation Source" := NewItem."i95 Creation Source"::i95;
            NewItem.insert();
            // end;

            NewItem.Validate(NewItem.Description, Name);
            NewItem.validate(NewItem."Unit Price", Price);

            If NewItem."Costing Method" = NewItem."Costing Method"::Standard then
                NewItem.validate(NewItem."Unit Cost", Cost)
            else begin
                ItemLedgEntry.SETCURRENTKEY("Item No.");
                ItemLedgEntry.SETRANGE("Item No.", NewItem."No.");
                IF ItemLedgEntry.ISEMPTY() THEN
                    NewItem.validate(NewItem."Unit Cost", Cost);
            end;

            NewItem.Validate(NewItem."Gross Weight", Weight);
            If i95Setup."Default UOM" <> '' then
                NewItem.Validate(NewItem."Base Unit of Measure", i95Setup."Default UOM");
            //NewItem.Validate(NewItem."Tax Group Code", TaxGroupCode);
            If i95Setup."i95 Gen. Prod. Posting Group" <> '' then
                NewItem.Validate(NewItem."Gen. Prod. Posting Group", i95Setup."i95 Gen. Prod. Posting Group");
            if i95Setup."i95 Inventory Posting Group" <> '' then
                NewItem.Validate(NewItem."Inventory Posting Group", i95Setup."i95 Inventory Posting Group");
            If i95Setup."i95 Tax Group Code" <> '' then
                NewItem.Validate(NewItem."Tax Group Code", i95Setup."i95 Tax Group Code");

            Clear(RedDescription);//changes for reducing desc
            RedDescription := CopyStr(Description, 1, 50);
            NewItem.Validate(NewItem."Description 2", RedDescription);
            // NewItem.Validate(NewItem."Description 2", Description);

            NewItem.Modify(false);

            SourceRecordIDAs := NewItem.RecordId();

            /* NewItem.Seti95APIUpdateCall(true);
             NewItem."i95 Last Modification DateTime" := CurrentDateTime();
             NewItem."i95 Last Modified By" := copystr(UserId(), 1, 80);
             NewItem."i95 Last Sync DateTime" := CurrentDateTime();
             NewItem."i95 Sync Status" := NewItem."i95 Sync Status"::"Waiting for Response";
             NewItem."i95 Last Modification Source" := NewItem."i95 Last Modification Source"::i95;
             NewItem."i95 Reference ID" := SourceNo;*/
            NewItem.Modify(false);


        end;
    end;

    procedure GetSourceRecordID(Var SourceRecordIDP: RecordId; Var ItemNo: code[20])
    begin
        SourceRecordIDP := SourceRecordIDAs;
        ItemNo := NewItemG."No.";

    end;

    procedure set(var InventorySetupP: Record "Inventory Setup"; var ItemLedgEntryP: Record "Item Ledger Entry"; var NewItemP: Record Item; var SourceNoP: Code[20]; var NameP: Text; var PriceP: Decimal; var WeightP: Decimal; var CostP: Decimal; var DescriptionP: Text; var SkuP: text; var i95SetupP: Record "i95 Setup"; var NoSeriesMgtP: Codeunit NoSeriesManagement; var SourceRecordIDP: RecordId)
    begin
        InventorySetupG := InventorySetupP;
        ItemLedgEntryG := ItemLedgEntryP;
        NewItemG := NewItemP;
        SourceNoG := SourceNoP;
        NameG := NameP;
        PriceG := PriceP;
        WeightG := WeightP;
        CostG := CostP;
        DescriptionG := DescriptionP;
        SkuG := SkuP;
        i95SetupG := i95SetupP;
        NoSeriesMgtG := NoSeriesMgtP;
        SourceRecordIDG := SourceRecordIDP;

    end;






    var
        InventorySetupG: Record "Inventory Setup";
        ItemLedgEntryG: Record "Item Ledger Entry";
        NewItemG: Record Item;
        SourceNoG: Code[20];
        NameG: Text;
        PriceG: Decimal;
        WeightG: Decimal;
        CostG: Decimal;

        DescriptionG: Text;
        SkuG: text;
        i95SetupG: Record "i95 Setup";
        SourceRecordIDAs: RecordId;
        NoSeriesMgtG: Codeunit NoSeriesManagement;
        SourceRecordIDG: RecordId;
}