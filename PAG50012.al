report 50012 "Export Netting"
{
    UsageCategory = Tasks;
    ProcessingOnly = true;
    CaptionML = ENU = 'Export Netting' , SVE = 'Export Netting'; 
    UseRequestPage = false;

    trigger OnInitReport();
    begin
        ExportNetting.Run;
    end;
    
    var
        ExportNetting : Codeunit "Export Netting";
}