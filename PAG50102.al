pageextension 50102 Customer_Card_Net extends "Customer Card" 
{
    layout
    {
        addlast("Invoicing")
        {
            field(Netting;Netting)
            {
                CaptionML = ENU='Netting',SVE= 'Netting';
            }
        }        
    }
}
