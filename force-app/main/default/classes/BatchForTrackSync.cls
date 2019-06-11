global class BatchForTrackSync implements Database.Batchable<sObject>,   Database.AllowsCallouts {
     global Database.QueryLocator start(Database.BatchableContext BC) {
          String query;
            List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForTrackSync'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
          		if(lastbatchRun.size()>0)
                Datetime lastJobDate = lastbatchRun[0].CompletedDate;
                query='select FMV1_Guide__c ,Schedule_Track_Id__c,Name,EventApi__Track_Color__c from EventApi__Track__c where (FMV1_Guide__c!=null AND Schedule_Track_Id__c = null) OR (FMV1_Guide__c!=null AND Schedule_Track_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
          		
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventApi__Track__c> records) {  
         system.debug('records value '+records);
        for(EventApi__Track__c obj: records){
            if(obj.Schedule_Track_Id__c==null)
                GuidebookRestApiController.createTrack(obj);
            else
                GuidebookRestApiController.updateTrack(obj);
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        BatchForSessionSync batchSession = new BatchForSessionSync();
        Database.executeBatch(batchSession, 1);
    }
}