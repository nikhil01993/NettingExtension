page 50110 "Netting Setup"
{
    PageType = Card;
    SourceTable = 50109;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {   
            group(Netting)
            {                
                field("Export Path";"Export Path")
                {                    
                    CaptionML = ENU = 'Export Path' , SVE = 'Sökväg export';                    
                }
                field("Customer Posting Group";"Customer Posting Group")
                {
                    CaptionML = ENU = 'Customer Posting Group', SVE = 'Kundbokföringsmall';
                }
                field("Vendor Posting Group";"Vendor Posting Group")
                {
                    CaptionML = ENU = 'Vendor Posting Group' , SVE = 'Leverantörsbokföringsmall';
                }
                field("Import Path";"Import Path")
                {
                    CaptionML = ENU = 'Import Path' , SVE='Sökväg import';
                }
            }            
        }
    }
    
    trigger OnOpenPage();
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END;
    end;
}