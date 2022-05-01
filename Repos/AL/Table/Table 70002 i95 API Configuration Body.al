Table 70002 "i95 API Configuration Body"
{
    Caption = 'i95Dev API Configuration Body';
    fields
    {
        field(1; "API Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'API Type';
            OptionMembers = " ","Product","Customer","CustomerGroup","Inventory","SalesOrder","Shipment","Invoice","TierPrices","CancelOrder","EditOrder","TaxBusPostingGroup","TaxProductPostingGroup","TaxPostingSetup","ConfigurableProduct","CustomerDiscountGroup","ItemDiscountGroup","DiscountPrice","ShippingAgent","PaymentMethod","EntityManagement","PaymentJournal","PaymentTerm","SalesQuote","CancelQuote","AccountRecievable","financeCharge","SalesPerson","SalesReturn","SalesCreditMemo","Warehouse","ProductAttributeMapping","SchedulerId","ReaccureToken";
            OptionCaption = ' ,Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken';
        }
        field(2; "Scheduler Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Scheduler Type';
            OptionMembers = " ",PushData,PullResponse,PullResponseACK,PullData,PushResponse;
            OptionCaption = ' ,Push Data, Pull Response, Pull Response ACK, Pull Data, Push Response';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
            BlankZero = true;
        }
        field(4; "Tag Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Tag Name';
        }
        field(5; "Tag Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Type';
            OptionMembers = " ","Text","Field";
            OptionCaption = ' ,Text, Field';
        }
        field(6; "Tag Text Value"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Tag Value';
        }
        field(7; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(8; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Name" WHERE("Object ID" = FIELD("Table No.")));
        }
        field(9; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
            BlankZero = true;
            TableRelation = Field."No." where(TableNo = field("Table No."));
        }
        field(10; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName WHERE("TableNo" = FIELD("Table No."), "No." = FIELD("Field No.")));
        }
    }
    keys
    {
        key(Key1; "API Type", "Line No.")
        { }
    }
}