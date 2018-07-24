codeunit 50011 NettingSubscriber
{
    trigger OnRun();
    begin
    end;

    [EventSubscriber(ObjectType::Page, 255, 'OnAfterActionEvent', 'Netting Customer', true, true)]    
    procedure CashReceiptImportNetting(var Rec : Record 81);    
    var
        ImportNetting_loc : Report 50006;

    begin
        ImportNetting_loc.SetGenJnlLine(Rec);
        ImportNetting_loc.RUNMODAL;
    end;

    [EventSubscriber(ObjectType::Page, 256, 'OnAfterActionEvent', 'Netting Vendor', true, true)]    
    procedure PaymentImportNetting(var Rec : Record 81);    
    var
        ImportNetting_loc : Report 50007;

    begin
        ImportNetting_loc.SetGenJnlLine(Rec);
        ImportNetting_loc.RUNMODAL;
    end;
}