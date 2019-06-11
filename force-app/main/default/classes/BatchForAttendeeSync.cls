global class BatchForAttendeeSync implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForAttendeeSync'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
        if(lastbatchRun.size()>0)
                Datetime lastJobDate = lastbatchRun[0].CompletedDate;
            query='select FMV1_Guidebook_Import_Id__c,Attendee_Id__c,FMV1_Revoked__c,EventApi__First_Name__c,EventApi__Last_Name__c,EventApi__Email__c,FMV1_Guide__c from EventApi__Attendee__c where (FMV1_Guide__c!=null AND Attendee_Id__c = null) OR (FMV1_Guide__c!=null AND Attendee_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
      
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventApi__Attendee__c> records) {
        for(EventApi__Attendee__c obj: records){
            if(obj.Attendee_Id__c==null)
                GuidebookRestApiController.createAttendees(obj);
            else
                GuidebookRestApiController.updateAttendees(obj);
        }
    }
    
    global void finish(Database.BatchableContext BC){    
        BatchForSpeaker batchSpeaker = new BatchForSpeaker();
        Database.executeBatch(batchSpeaker, 1);
    }
}