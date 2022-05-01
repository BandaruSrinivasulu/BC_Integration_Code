Table 70001 "i95 API Configuration"
{
    Caption = 'i95Dev API Configuration';
    fields
    {
        field(1; "API Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'API Type';
            OptionMembers = " ","Product","Customer","CustomerGroup","Inventory","SalesOrder","Shipment","Invoice","TierPrices","CancelOrder","EditOrder","TaxBusPostingGroup","TaxProductPostingGroup","TaxPostingSetup","ConfigurableProduct","CustomerDiscountGroup","ItemDiscountGroup","DiscountPrice","ShippingAgent","PaymentMethod","EntityManagement","PaymentJournal","PaymentTerm","SalesQuote","CancelQuote","AccountRecievable","financeCharge","SalesPerson","SalesReturn","SalesCreditMemo","Warehouse","ProductAttributeMapping","SchedulerId","ReaccureToken";
            OptionCaption = ' ,Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken';
        }
        field(2; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Request Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Request Type';
            OptionMembers = "POST","GET","DELETE";
            OptionCaption = 'POST, GET, DELETE';
        }
        field(4; "PushData Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'PushData Url';
        }
        field(5; "PullResponse Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'PullResponse Url';
        }
        field(6; "PullResponseAck Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'PullResponseAck Url';
        }
        field(7; "PushResponse Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'PushResponse Url';
        }
        field(8; "PullData Url"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'PullData Url';
        }
    }
    keys
    {
        key(Key1; "API Type")
        { }
    }

    procedure Initializei95APIConfiguration()
    begin
        //Insert Product API Config
        InsertAPIConfig("API Type"::Product, 'Product Sync', 'Product/PushData', 'Product/PullResponse', 'Product/PullResponseAck', 'Product/PullData', 'Product/PushResponse');
        //Insert Customer API Config
        InsertAPIConfig("API Type"::Customer, 'Customer Sync', 'Customer/PushData', 'Customer/PullResponse', 'Customer/PullResponseAck', 'Customer/PullData', 'Customer/PushResponse');
        //Insert Customer Group API Config
        // InsertAPIConfig("API Type"::CustomerGroup, 'Customer Group Sync', 'CustomerGroup/PushData', 'CustomerGroup/PullResponse', 'CustomerGroup/PullResponseAck', 'CustomerGroup/Pulldata', 'CustomerGroup/PushResponse');
        InsertAPIConfig("API Type"::CustomerGroup, 'Customer Group Sync', 'Pricelevel/PushData', 'Pricelevel/PullResponse', 'Pricelevel/PullResponseAck', 'Pricelevel/Pulldata', 'Pricelevel/PushResponse');


        //Insert Inventory API Config
        InsertAPIConfig("API Type"::Inventory, 'Inventory Sync', 'Inventory/PushData', 'Inventory/PullResponse', 'Inventory/PullResponseAck', '', '');
        //Insert SalesOrder API Config
        InsertAPIConfig("API Type"::SalesOrder, 'Sales Order Sync', 'SalesOrder/PushData', 'SalesOrder/PullResponse', 'SalesOrder/PullResponseAck', 'SalesOrder/PullData', 'SalesOrder/PushResponse');
        //Insert Shipment API Config
        InsertAPIConfig("API Type"::Shipment, 'Sales Shipment Sync', 'Shipment/PushData', 'Shipment/PullResponse', 'Shipment/PullResponseAck', '', '');
        //Insert Invoice API Config
        InsertAPIConfig("API Type"::Invoice, 'Sales Invoice Sync', 'Invoice/PushData', 'Invoice/PullResponse', 'Invoice/PullResponseAck', '', '');
        //Insert TierPrices API Config
        InsertAPIConfig("API Type"::TierPrices, 'Sales Price Sync', 'TierPrices/PushData', 'TierPrices/PullResponse', 'TierPrices/PullResponseAck', '', '');
        //Insert CancelOrder API Config
        InsertAPIConfig("API Type"::CancelOrder, 'Cancel Sales Order Sync', 'cancelorder/PushData', 'cancelorder/PullResponse', 'cancelorder/PullResponseAck', '', '');
        //Insert EditOrder API Config
        InsertAPIConfig("API Type"::EditOrder, 'Edit Order Sync', 'EditOrder/PushData', 'EditOrder/PullResponse', 'EditOrder/PullResponseAck', '', '');
        //Insert TaxBusPostingGroup API Config
        InsertAPIConfig("API Type"::TaxBusPostingGroup, 'Tax Business Posting Group Sync', 'TaxBusPostingGroup/PushData', 'TaxBusPostingGroup/PullResponse', 'TaxBusPostingGroup/PullResponseAck', '', '');
        //Insert TaxProductPostingGroup API Config
        InsertAPIConfig("API Type"::TaxProductPostingGroup, 'Tax Product Posting Group Sync', 'TaxProductPostingGroup/PushData', 'TaxProductPostingGroup/PullResponse', 'TaxProductPostingGroup/PullResponseAck', '', '');
        //Insert TaxPostingSetup API Config
        InsertAPIConfig("API Type"::TaxPostingSetup, 'Tax Posting Setup Sync', 'TaxPostingSetup/PushData', 'TaxPostingSetup/PullResponse', 'TaxPostingSetup/PullResponseAck', '', '');
        //Insert Payment Term API Config
        InsertAPIConfig("API Type"::PaymentTerm, 'Payment Term Sync', 'PaymentTerm/PushData', 'PaymentTerm/PullResponse', 'PaymentTerm/PullResponseAck', '', '');
        //Insert ConfigurableProduct API Config
        InsertAPIConfig("API Type"::ConfigurableProduct, 'Configurable Product Sync', 'ConfigurableProduct/PushData', 'ConfigurableProduct/PullResponse', 'ConfigurableProduct/PullResponseAck', '', '');
        //Insert CustomerDiscountGroup API Config
        InsertAPIConfig("API Type"::CustomerDiscountGroup, 'Customer Discount Group Sync', 'CustomerDiscountGroup/PushData', 'CustomerDiscountGroup/PullResponse', 'CustomerDiscountGroup/PullResponseAck', '', '');
        //Insert ItemDiscountGroup API Config
        InsertAPIConfig("API Type"::ItemDiscountGroup, 'Item Discount Group Sync', 'ItemDiscountGroup/PushData', 'ItemDiscountGroup/PullResponse', 'ItemDiscountGroup/PullResponseAck', '', '');

        //Insert DsicountPrice API Config
        InsertAPIConfig("API Type"::DiscountPrice, 'Discount Price Sync', 'DiscountPrice/PushData', 'DiscountPrice/PullResponse', 'DiscountPrice/PullResponseAck', '', '');

        //Insert Shipping Agent API Config
        InsertAPIConfig("API Type"::ShippingAgent, 'Shipping Agent Sync', 'Mapping/Shipping', '', '', '', '');

        //Insert Payment Method APi Config
        InsertAPIConfig("API Type"::PaymentMethod, 'Payment Method Sync', 'Mapping/Payment', '', '', '', '');

        //Insert EntityManagement API Config
        InsertAPIConfig("API Type"::EntityManagement, 'Entity Management sync', '', '', '', 'Mapping/Entities', 'Mapping/Ack');

        //Insert Payment journal API Config
        InsertAPIConfig("API Type"::PaymentJournal, 'PaymentJournal Sync', 'PaymentJournal/PushData', 'PaymentJournal/PullResponse', 'PaymentJournal/PullResponseAck', 'PaymentJournal/PullData', 'PaymentJournal/PushResponse');

        //Insert Sales Quote API Config
        InsertAPIConfig("API Type"::SalesQuote, 'Sales Quote Sync', 'SalesQuote/PushData', 'SalesQuote/PullResponse', 'SalesQuote/PullResponseAck', 'SalesQuote/PullData', 'SalesQuote/PushResponse');

        //Insert Cancel Sales Quote API Config
        InsertAPIConfig("API Type"::CancelQuote, 'Cancel Sales Quote Sync', 'cancelquote/PushData', 'cancelquote/PullResponse', 'cancelquote/PullResponseAck', '', '');
        //Insert Account Recievable API Config
        InsertAPIConfig("API Type"::AccountRecievable, 'Account Recievable Sync', 'AccountReceivable/PushData', 'AccountReceivable/PullResponse', 'AccountReceivable/PullResponseAck', 'AccountReceivable/PullData', 'AccountReceivable/PushResponse');
        //Insert Finance Charge API Config
        InsertAPIConfig("API Type"::financeCharge, 'Finacial Charge Sync', 'financeCharge/PushData', 'financeCharge/PullResponse', 'financeCharge/PullResponseAck', '', '');

        //Insert Sales Person API Config
        InsertAPIConfig("API Type"::SalesPerson, 'Sales Person Sync', 'SalesPerson/PushData', 'SalesPerson/PullResponse', 'SalesPerson/PullResponseAck', '', '');
        //Insert Sales Return API Config
        InsertAPIConfig("API Type"::SalesReturn, 'Sales Return Sync', 'Returns/PushData', 'Returns/PullResponse', 'Returns/PullResponseAck', 'Returns/PullData', 'Returns/PushResponse');

        //Insert Sales Return API Config
        InsertAPIConfig("API Type"::SalesCreditMemo, 'Sales Credit Memo Sync', 'CreditMemo/PushData', 'CreditMemo/PullResponse', 'CreditMemo/PullResponseAck', 'CreditMemo/PullData', 'CreditMemo/PushResponse');
        //Insert Warehouse API Config
        InsertAPIConfig("API Type"::Warehouse, 'Warehouse Location Sync', 'Warehouse/PushData', 'Warehouse/PullResponse', 'Warehouse/PullResponseAck', '', '');
        //Insert Product Attribute Mapping
        InsertAPIConfig("API Type"::ProductAttributeMapping, 'Product Attribute Mapping sync', 'Mapping/Product', '', '', 'Mapping/ProductList/ERP', '');
        //Insert SchedulerID API Config
        InsertAPIConfig("API Type"::SchedulerId, 'Pull Scheduler ID', '', '', '', 'Index', '');
        //Insert Reaccure Token API Config
        InsertAPIConfig("API Type"::ReaccureToken, 'Pull Access Token', '', '', '', 'Client/Token', '');

    end;

    procedure intilizeEntityMapping()
    var
        EntityMapping: Record "i95 Entity Mapping";
    begin

        IF not EntityMapping.FindFirst() then begin
            EntityMapping."Primary Key" := 'P';
            EntityMapping."Allow Product Oubound Sync" := true;
            EntityMapping."Allow Product Inbound Sync" := true;
            EntityMapping."Allow Inventory Oubound Sync" := true;
            EntityMapping."Allow CustGroup Outbound Sync" := true;
            EntityMapping."Allow CustGroup inbound Sync" := true;
            EntityMapping."Allow Tier Prices Oubound Sync" := true;
            EntityMapping."Allow Customer Oubound Sync" := true;
            EntityMapping."Allow Customer Inbound Sync" := true;
            EntityMapping."Allow SalesOrder Oubound Sync" := true;
            EntityMapping."Allow SalesOrder Inbound Sync" := true;
            EntityMapping."Allow Shipment Oubound Sync" := true;
            EntityMapping."Allow Shipment inbound Sync" := true;
            EntityMapping."Allow Invoice Oubound Sync" := true;
            EntityMapping."Allow Invoice inbound Sync" := true;
            EntityMapping."Allow ESalesOrder Oubound Sync" := true;
            EntityMapping."Allow CustDiscG Oubound Sync" := true;
            EntityMapping."Allow CustDiscG Inbound Sync" := true;
            EntityMapping."Allow ItemDiscG Oubound Sync" := true;
            EntityMapping."Allow ItemDiscG Inbound Sync" := true;
            EntityMapping."Allow DiscPrice Oubound Sync" := true;
            EntityMapping."Allow DiscPrice Inbound Sync" := true;
            EntityMapping."Allow ItemVar Oubound Sync" := true;
            EntityMapping."Allow CancelOrder Oubound Sync" := true;
            EntityMapping."Allow TaxBusPosG Oubound Sync" := true;
            EntityMapping."Allow TaxBusPosG Inbound Sync" := true;
            entityMapping."Allow TaxProdPosG Oubound Sync" := true;
            EntityMapping."Allow TaxProdPosG Inbound Sync" := true;
            entityMapping."Allow TaxPossetup Oubound Sync" := true;
            EntityMapping."Allow TaxPossetup Inbound Sync" := true;
            EntityMapping."Allow CashReci Inputbound Sync" := true;
            EntityMapping."Allow CashReci Outbound Sync" := true;
            EntityMapping."Allow SalesQuote Inbound Sync" := true;
            EntityMapping."Allow SalesQuote Outbound Sync" := true;
            EntityMapping."Allow CanceQuote Inbound Sync" := true;
            EntityMapping."Allow CanceQuote Outbound Sync" := true;
            EntityMapping."Allow AcountRecievable Ib Sync" := true;
            EntityMapping."Allow AcountRecievable Ob Sync" := true;
            EntityMapping."Allow PaymentTerm Inbound Sync" := true;
            EntityMapping."Allow PaymentTerm Oubound Sync" := true;
            EntityMapping."Allow Financecharge Ib Sync" := true;
            EntityMapping."Allow Financecharge Ob Sync" := true;
            EntityMapping."Allow SalesPerson Inbound Sync" := true;
            EntityMapping."Allow SalesPerson Oubound Sync" := true;
            EntityMapping."Allow SalesReturn Ib Sync" := true;
            EntityMapping."Allow SalesReturn Ob Sync" := true;
            EntityMapping."Allow SalesCreditMemo Ib Sync" := true;
            EntityMapping."Allow SalesCreditMemo Ob Sync" := true;
            EntityMapping."Allow Warehouse Ib Sync" := true;
            EntityMapping."Allow Warehouse Ob Sync" := true;
            EntityMapping.Insert(false);
        end;
    end;

    local procedure InsertAPIConfig(APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,PaymentTerm,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,EntityManagement,PaymentJournal,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken; DescriptionTxt: Text; PushDataURL: Text; PullResponseURL: Text; PullResponseACkURL: Text; PullDataURL: Text; PushResponseURL: Text)
    begin
        if not Get(APIType) then begin
            Init();
            "API Type" := APIType;
            Description := CopyStr(DescriptionTxt, 1, 50);
            "PushData Url" := CopyStr(PushDataURL, 1, 50);
            "PullResponse Url" := CopyStr(PullResponseURL, 1, 50);
            "PullResponseAck Url" := CopyStr(PullResponseACkURL, 1, 50);
            "PullData Url" := CopyStr(PullDataURL, 1, 50);
            "PushResponse Url" := CopyStr(PushResponseURL, 1, 50);
            Insert();
        end else begin
            if Description = '' then
                Description := CopyStr(DescriptionTxt, 1, 50);
            if "PushData Url" = '' then
                "PushData Url" := CopyStr(PushDataURL, 1, 50);
            if "PullResponse Url" = '' then
                "PullResponse Url" := CopyStr(PullResponseURL, 1, 50);
            if "PullResponseAck Url" = '' then
                "PullResponseAck Url" := CopyStr(PullResponseACkURL, 1, 50);
            if "PullData Url" = '' then
                "PullData Url" := CopyStr(PullDataURL, 1, 50);
            if "PushResponse Url" = '' then
                "PushResponse Url" := CopyStr(PushResponseURL, 1, 50);
            Modify();
        end;
    end;
}