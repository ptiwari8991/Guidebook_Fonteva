global class BatchForSpeaker  implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
            List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForSpeaker'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
            if(lastbatchRun.size()>0)
                Datetime lastJobDate = lastbatchRun[0].CompletedDate;
                query='select FMV1_Guide__c,allow_rating__c,Disable_Todo__c,Name,Import_Id__c,Speaker_Id__c from EventApi__Speaker__c where (FMV1_Guide__c!=null AND Speaker_Id__c = null) OR (FMV1_Guide__c!=null AND Speaker_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
             
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<EventApi__Speaker__c> records) {  
        for(EventApi__Speaker__c obj: records){
            if(obj.Speaker_Id__c==null){
                GuidebookRestApiController.createSpeakers(obj);
            }
            else{
                GuidebookRestApiController.updateSpeakers(obj);
        }
    }
    }
    global void finish(Database.BatchableContext BC){
        BatchForRegistrationItem batchReg = new BatchForRegistrationItem();
        Database.executeBatch(batchReg, 1);
    }
}