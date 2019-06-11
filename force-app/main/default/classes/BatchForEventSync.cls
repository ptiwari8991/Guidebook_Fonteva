global class BatchForEventSync implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForEventSync' AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
        if(lastbatchRun.size()>0)
            Datetime lastJobDate = lastbatchRun[0].CompletedDate;
            query ='select FMV1_Guide_ID__c,EventApi__Time_Zone__c, EventApi__Start_Date_Time__c, FMV1_Guide_Description_HTML__c,EventApi__End_Date_Time__c,Name from EventApi__Event__c where FMV1_Guide_ID__c!=null AND Last_Sync_Date__c >= : lastJobDate ';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<EventApi__Event__c> records) {
        for(EventApi__Event__c obj: records){
            GuidebookRestApiController.updateGuides(obj);
        }
    }
    global void finish(Database.BatchableContext BC){    
    }
}