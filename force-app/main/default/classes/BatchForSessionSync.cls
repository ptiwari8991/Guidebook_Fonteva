global class BatchForSessionSync  implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForSessionSync'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
        if(lastbatchRun.size()>0)
            Datetime lastJobDate = lastbatchRun[0].CompletedDate;
        query='select EventApi__Room__c,EventApi__Room__r.FMV1_Location_Id__c,FMV1_Guide__c,Session_Id__c,FMV1_Guidebook_Import_Id__c,EventApi__Start_Date_Time__c,EventApi__End_Date_Time__c,EventApi__Disable_Registration__c,Name,EventApi__Description__c from EventAPI__Schedule_Item__c where (FMV1_Guide__c!=null AND Session_Id__c = null) OR (FMV1_Guide__c!=null AND Session_Id__c != null AND Last_Sync_Date_Schedule__c >= :lastJobDate)';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventAPI__Schedule_Item__c> records) {
        for(EventAPI__Schedule_Item__c obj: records){
            if(obj.Session_Id__c == null){
                GuidebookRestApiController.createSession(obj);
            }else{ 
                GuidebookRestApiController.updateSession(obj);
            }   
        }
    }
    global void finish(Database.BatchableContext BC){
          BatchForAttendeeSync batchAttendee = new BatchForAttendeeSync();
          Database.executeBatch(batchAttendee, 1);
    }
}