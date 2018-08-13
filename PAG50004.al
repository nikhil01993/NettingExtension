pageextension 50004 Cash_Receipt_Journal_Ext extends "Cash Receipt Journal" 
{
    // version CHG-10203,NAVW111.00.00.19846,PE6.03,SC0034,SC0356,SC0380

    actions
    {
        addlast("F&unctions")
        {
            action("Netting Customer")
            {
                CaptionML = ENU='Import Netting',
                            SVE='Importera Netting';
                Image = Import;
                Promoted = true;
                PromotedCategory = "Process";
            }            
        }
    }
}