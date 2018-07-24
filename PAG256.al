pageextension 50005 Payment_Journal_Net extends "Payment Journal" 
{
    actions
    {
        addlast("F&unctions")
        {
            action("Netting Vendor")
            {
                CaptionML = ENU='Import Netting',
                            SVE='Importera Netting';
                Image = Import;
                Promoted = true;
                PromotedCategory = "Report";
            }
        }       
    }
}