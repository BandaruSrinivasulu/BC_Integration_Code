Page 70000 "i95 Setup"
{
    Caption = 'i95Dev Setup';
    PageType = Card;
    SourceTable = "i95 Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Base Url"; Rec."Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Base i95Dev Url';
                    trigger OnValidate()
                    begin
                        if (Rec."Base Url" <> '') and (CopyStr(Rec."Base Url", STRLEN(Rec."Base Url"), 1) <> '/') then
                            Rec."Base Url" := copystr(Rec."Base Url", 1, 149) + '/';
                    End;
                }
                field("Subscription Key"; Rec."Subscription Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Subscription Key';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Client ID';
                }
                field(Authorization; APIAuthorizationToken)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the API Authorization';
                    MultiLine = true;
                    Editable = AuthTokenEditable;
                    trigger OnValidate()
                    begin
                        Rec.SetAuthorizationToken(APIAuthorizationToken);
                    end;
                }
                field("Instance Type"; Rec."Instance Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of Instance';
                }
                field("Endpoint Code"; Rec."Endpoint Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Endpoint code';
                }
                field("Content Type"; Rec."Content Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of Content';
                }
                field(PullDataPacketSize; Rec."Pull Data Packet Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pull Data Packet Size';
                }
                field("i95 Default Warehouse"; Rec."i95 Default Warehouse")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95 Default Warehouse';
                }
                field("Default Guest Customer No."; Rec."Default Guest Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default Guest Customer No.';
                }
                field("i95 Customer Posting Group"; Rec."i95 Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95 Customer Posting Group';
                }
                field("i95 Gen. Bus. Posting Group"; Rec."i95 Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95 General Business Posting Group';
                }
                field("Default UOM"; Rec."Default UOM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default Unit Of Measure';
                }
                field("i95 Gen. Prod. Posting Group"; Rec."i95 Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default Gen. Prod. Posting Group';
                }
                field("i95 Inventory Posting Group"; Rec."i95 Inventory Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default Inventory Posting Group';
                }
                field("i95 Tax Group Code"; Rec."i95 Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default Tax Group Code';
                }
                field("i95 Shipping Charge G/L Acc"; Rec."i95 Shipping Charge G/L Acc")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shipping Charge G/L Account';
                }
                field("Customer Nos."; Rec."Customer Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default i95Dev Customer No Series';
                }
                field("Order Nos."; Rec."Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default i95Dev Sales Order No Series';
                }
                field("i95 Use Item Nos. from E-COM"; Rec."i95 Use Item Nos. from E-COM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether Item No. assigned same as E-Commerce';
                    trigger OnValidate()
                    begin
                        If Rec."i95 Use Item Nos. from E-COM" then begin
                            Rec."Product Nos." := '';
                            DefaultProductNosEnable := false
                        end else
                            DefaultProductNosEnable := true;
                    end;
                }
                field("Product Nos."; Rec."Product Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Default i95Dev Product No Series';
                    Enabled = DefaultProductNosEnable;
                }
                field("Schedular ID"; Rec."Schedular ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Schedular ID for Sync';
                    Editable = false;
                }
                /*  field(IsConfigurationUpdated; IsConfigurationUpdated)
                  {
                      ApplicationArea = All;
                      ToolTip = 'Specifies the is Entity Mapping is Updated or not';
                      Editable = false;
                  }*/
                field("i95 Item Variant Seperator"; Rec."i95 Item Variant Seperator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Item Variant Seperator';
                }
                field("i95 Item Variant Pattern 1"; Rec."i95 Item Variant Pattern 1")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Item Variant Type 1.Use Item Variant Separator to seperate each Item attributes.';
                }
                field("i95 Item Variant Pattern 2"; Rec."i95 Item Variant Pattern 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Item Variant Type 2.Use Item Variant Separator to seperate each Item attributes.';
                }
                field("i95 Item Variant Pattern 3"; Rec."i95 Item Variant Pattern 3")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Item Variant Type 3.Use Item Variant Separator to seperate each Item attributes.';
                }
                field("I95 Default Template Name"; Rec."I95 Default Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Default Template Name For Cash Reciept Journal';
                }
                field("I95 Default Batch Name"; Rec."I95 Default Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Default Batch Name For Cash Reciept Journal';
                }
                field("i95 Enable Company"; Rec."i95 Enable Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this field if you want use the Company Account Feature';
                }
                field("i95 Contact Nos."; Rec."i95 Contact Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify the Contact No. Series';
                }
                field("i95 Enable BillPay"; Rec."i95 Enable BillPay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this field if you want use the Bill Pay Feature';
                }
                field("i95 Enable MultiWarehouse"; Rec."i95 Enable MultiWarehouse")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this field if you want use the MultiWarehouse Feature';
                }
                field("i95 Enable Customer Specific Pricing"; Rec."i95 Enable CustSpec Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable Pricing for Customer';
                }
                field("i95Dev EnableAllCustmr Pricing"; Rec."i95Dev EnableAllCustmr Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable Pricing for All Customers';
                }
                field("i95Dev CPG Pricing"; Rec."i95Dev CPG Pricing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable Pricing for Customer Price Group';
                }
                field("i95 Enable MSI"; Rec."i95 Enable MSI")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this field if you want use the MSI Feature';
                }
                field("i95 Enable ProdAtriButeMapping"; Rec."i95 Enable ProdAtriButeMapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable this field if you want use the Product Attribute Mapping Feature';
                }

                // field(Refreshtokendate; Rec.Refreshtokendate)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the Refresh token date';
                // }
                // field(Refreshtokentime; Rec.Refreshtokentime)
                // {
                //     ApplicationArea = All;
                //     ToolTip = ' Specifies the Refresh token time';
                // }
                // field(accesstokendate; Rec.accesstokendate)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the Access token Date';
                // }
                // field(accesstokentime; Rec.accesstokentime)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the Access token time';
                // }
                // field(accesstokenExpirytime; Rec.accesstokenExpirytime)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the access token expire time';
                // }
                // field(RefreshtokenExpirytime; Rec.RefreshtokenExpirytime)
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the refresh token expire time';
                // }

            }

        }
    }

    actions
    {
        area(Processing)
        {
            group("PushData")
            {
                action("Push Shipping Methods to Cloud")
                {
                    Caption = 'Push Sales Shipping Methods';
                    ToolTip = 'Process  Shipping Methods PushData API';
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        ShipAgentService: Record "Shipping Agent Services";
                        ShippingAgent: Record "Shipping Agent";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                        ConfirmationString: Label 'Do you want to Push Sales Shipping Methods to Cloud';
                    begin
                        IF Dialog.Confirm(ConfirmationString, false) then begin
                            ShipAgentService.Reset();
                            // ShipAgentService.SetRange("Sent to Cloud", false);
                            IF ShipAgentService.FindSet() then
                                repeat
                                    i95PushWebService.SalesAgentPushData(ShipAgentService);
                                until ShipAgentService.Next() = 0;
                        end;
                    end;
                }


                action("Push Payment Methods to Cloud")
                {

                    Caption = 'Push Payment Methods';
                    ToolTip = 'Process  Payment Methods PushData API';
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        PaymentMethod: Record "Payment Method";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                        ConfirmationString: Label 'Do you want to Push Payment Methods to Cloud';
                    begin
                        IF Dialog.Confirm(ConfirmationString, false) then begin
                            PaymentMethod.Reset();
                            // PaymentMethod.SetRange("Sent to Cloud", false);
                            IF PaymentMethod.FindSet() then
                                repeat
                                    i95PushWebService.PaymentMethodPushData(PaymentMethod);
                                until PaymentMethod.Next() = 0;

                        end;
                    end;
                }
                action("Push Product Attribute Mapping to Cloud")
                {

                    Caption = 'Product Attribute Mapping';
                    ToolTip = 'Process Product Attribute Mapping PushData API';
                    ApplicationArea = All;
                    trigger OnAction()
                    var
                        Item: Record Item;
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        i95PushWebService.ProductAttributesPushData(Item);
                    end;
                }
            }

            group(PullData)
            {

                action(EntityMappingpull)
                {

                    Caption = 'Pull Entity mapping';
                    ToolTip = 'Process Entity Mapping PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::EntityManagement, SchedulerType::PullData);
                    end;
                }

            }
            action("ImportLicensefile")
            {

                Caption = 'Upload i95Dev Cloud License file';
                ToolTip = 'It is used for Uploading i95Dev Cloud License file';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Runuploadlicensefile();
                end;
            }

            // action(OneTimeInventorySync)
            // {
            //     ApplicationArea = All;
            //     Caption = 'One Time Inventory Sync';
            //     ToolTip = 'One Time Inventory Sync';

            //     trigger OnAction()
            //     var
            //         allItems: Record Item;
            //         SyncStatus: Option "Stock Not Initialised","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";

            //     begin
            //         allItems.Reset();
            //         allItems.SetFilter("Item Category Code", '<>FINISHED');
            //         if allItems.FindSet() then begin
            //             allItems.ModifyAll("i95 Inventory Sync Status", SyncStatus::"Sync Complete", false);
            //         end;
            //         Message('One Time Inventory Sync is Activated');

            //         // allItems.Reset();
            //         // allItems.SetFilter("Item Category Code", '<>FINISHED');
            //         // if allItems.FindSet() then begin
            //         //     allItems.ModifyAll("i95 Sync Status", SyncStatus::"Sync Complete", false);
            //         // end;
            //     end;
            // }
        }
    }

    procedure Runuploadlicensefile()
    var
        Varaible: Text;
        // FileTempBlob: Record TempBlob;
        FileTempBlob: Codeunit "Temp Blob";
        SubstringL: Text;

    begin
        IF i95Setup.FindSet() then;

        Clear(SubscriptionKey);
        Clear(ServiceUrl);
        Clear(Token);
        Clear(CustomerId);
        Clear(InstanceType);
        Clear(EndpointCode);
        Clear(SubscriptionKeyL);
        Clear(ServiceUrlL);
        Clear(TokenL);
        Clear(CustomerIdL);
        Clear(InstanceTypeL);
        Clear(EndpointCodeL);
        Clear(Varaible);
        Clear(FileInstream);

        //FileTempBlob.Blob.CreateInStream(FileInstream);

        FileTempBlob.CreateInStream(FileInstream);

        IF UploadIntoStream(DialogTitle, '', 'All Files (*.txt)|*.txt', FileName, FileInstream) then begin


            /* FileInstream.ReadText(Filestring);
             SubscriptionKey := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
             FileInstream.ReadText(Filestring);
             ServiceUrl := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
             FileInstream.ReadText(Filestring);
             Token := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
             FileInstream.ReadText(Filestring);
             CustomerId := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
             FileInstream.ReadText(Filestring);
             InstanceType := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
             FileInstream.ReadText(Filestring);
             EndpointCode := CopyStr(Filestring, StrPos(Filestring, '|') + 1);*/






            while not (FileInstream.EOS) do begin
                FileInstream.ReadText(Filestring);

                IF StrPos(Filestring, 'SubscriptionKey') > 0 then begin
                    SubscriptionKey := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                end else
                    if StrPos(Filestring, 'ServiceUrl') > 0 then begin
                        ServiceUrl := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                    end else
                        if StrPos(Filestring, 'Token') > 0 then begin
                            Token := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                        end else
                            if StrPos(Filestring, 'CustomerId') > 0 then begin
                                CustomerId := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                            end else
                                if StrPos(Filestring, 'InstanceType') > 0 then begin
                                    InstanceType := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                                end else
                                    if StrPos(Filestring, 'EndpointCode') > 0 then begin
                                        EndpointCode := CopyStr(Filestring, StrPos(Filestring, '|') + 1);
                                    end;



            end;

            i95Setup."Subscription Key" := SubscriptionKey;
            i95Setup."Base Url" := ServiceUrl + '/';
            i95Setup."Client ID" := CustomerId;
            IF InstanceType = 'Staging' then
                i95Setup."Instance Type" := i95Setup."Instance Type"::Staging
            else
                IF InstanceType = 'Production' then
                    i95Setup."Instance Type" := i95Setup."Instance Type"::Production;

            i95Setup.Authorization.CreateOutStream(AuthorizationOutstream, TextEncoding::Windows);
            Varaible := 'Bearer ';
            AuthorizationOutstream.WriteText(Varaible + Token);
            i95Setup."Endpoint Code" := EndpointCode;
            i95Setup.Modify();
        end;
    end;

    trigger OnOpenPage()
    begin
        Rec.RESET();
        IF NOT Rec.GET() THEN BEGIN
            Rec.INIT();
            Rec.INSERT();
        END;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        APIAuthorizationToken := Rec.GetAuthorizationToken();
        AuthTokenEditable := CurrPage.Editable();
        DefaultProductNosEnable := Rec."i95 Use Item Nos. from E-COM";
        //Rec."Pull Data Packet Size" := 30;
        Rec."i95 Item Variant Seperator" := '-';
        Rec."i95 Item Variant Pattern 1" := 'Color';
        Rec."i95 Item Variant Pattern 2" := 'Color-Style';
        Rec."i95 Item Variant Pattern 3" := 'Color-Style-Size';
    end;

    var
        APIAuthorizationToken: Text;
        [InDataSet]
        AuthTokenEditable: Boolean;
        DefaultProductNosEnable: Boolean;
        SchedulerType: Option PushData,PullData;
        CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID;
        FileInstream: InStream;
        FileName: Text;
        xmlportno: Integer;
        DialogTitle: Label 'Please Select i95Dev Cloud License File...';
        Filestring: Text;
        SubscriptionKeyL: Text;
        ServiceUrlL: Text;
        TokenL: Text;
        CustomerIdL: Text;
        InstanceTypeL: Text;
        EndpointCodeL: Text;
        SubscriptionKey: Text;
        ServiceUrl: Text;
        Token: Text;
        CustomerId: Text;
        InstanceType: Text;
        EndpointCode: Text;
        AuthorizationOutstream: OutStream;
        i95Setup: Record "i95 Setup";
        LineString: Text;
        FindString: Integer;
        JobQueueEntry: Record "Job Queue Entry";
}