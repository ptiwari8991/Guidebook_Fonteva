global class BatchForRegistrationItem implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForRegistrationItem'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
             if(lastbatchRun.size()>0)
                Datetime lastJobDate = lastbatchRun[0].CompletedDate;
            query='select FMV1_Name__c, Registration_Id__c, FMV1_Guide__c, FMV1_Schedule_Item_id__c, FMV1_Attendee_id__c from EventApi__Registration_Item__c where (FMV1_Guide__c!=null AND Registration_Id__c = null) OR (FMV1_Guide__c!=null AND Registration_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventApi__Registration_Item__c> records) {  
        system.debug('records value '+records);
        for(EventApi__Registration_Item__c obj: records){
            if(obj.Registration_Id__c == null){
                GuidebookRestApiController.createRegistrationItem(obj);
            }else{ 
                GuidebookRestApiController.updateRegistrationItem(obj);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){    
    }
}