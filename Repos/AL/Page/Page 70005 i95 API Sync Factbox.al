Page 70005 "i95 API Sync Factbox"
{
    Caption = 'i95Dev API Sync Details';
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
                    field("i95 Sync Request"; Rec.ReadFromBlobField(APIDataToRead::"i95 Sync Request"))
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the i95Dev Sync Request';
                        MultiLine = true;
                    }
                    field(Response; 'Response')
                    {
                        ApplicationArea = All;
                        HideValue = true;
                    }
                    field("i95 Sync Result"; Rec.ReadFromBlobField(APIDataToRead::"i95 Sync Result"))
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Specifies the i95Dev Sync Result';
                        MultiLine = true;
                    }

                }
            }

        }
    }
    var
        APIDataToRead: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result";
}