Page 70012 "i95 API Log Factbox"
{
    Caption = 'i95Dev API Sync Details';
    PageType = CardPart;
    SourceTable = "i95 API Call Log Entry";

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
                    field("i95 API Request"; Rec.ReadFromBlobField(APIDataToRead::"i95 API Request"))
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
                    field("i95 API Result"; Rec.ReadFromBlobField(APIDataToRead::"i95 API Result"))
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
        APIDataToRead: Option "i95 API Request","i95 API Result";
}