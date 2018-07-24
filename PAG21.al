pageextension 50002 Customer_Card_Net extends "Customer Card" 
{
    layout
    {
        addlast("Invoicing")
        {
            field(Netting;Netting)
            {
            }
        }        
    }
}
