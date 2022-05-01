Page 70006 "i95 API Response Factbox"
{
    Caption = 'i95Dev API Response Details';
    PageType = CardPart;
    SourceTable = "i95 Sync Log Entry";
    layout
    {
        area(Content)
        {
            Grid(General)
            {
                GridLayout = Rows;

                group(General1)
                {
                    ShowCaption = false;
                    field(Request; 'Request')
                    {
                        ApplicationArea = All;
                        HideValue = true;
                    }
                    field("i95 Response Request"; Rec.ReadFromBlobField(APIDataToRead::"i95 Response Request"))
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the i95Dev Response Request';
                        MultiLine = true;
                    }
                    field(Response; 'Response')
                    {
                        ApplicationArea = All;
                        HideValue = true;
                    }
                    field("i95 Response Result"; Rec.ReadFromBlobField(APIDataToRead::"i95 Response Result"))
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the i95Dev Response Result';
                        MultiLine = true;
                    }

                }
            }

        }
    }
    var
        APIDataToRead: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result";
}

