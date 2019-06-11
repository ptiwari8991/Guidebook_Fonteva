global class BatchForRoomSync implements Database.Batchable<sObject>,   Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         Datetime lastJobDate;
        String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForRoomSync'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
        if(lastbatchRun.size()>0)
                 lastJobDate = lastbatchRun[0].CompletedDate;
            query='select Name,FMV1_Guide__c,FMV1_Location_Id__c,EventApi__Venue__r.FMV1_location_Type__c,EventApi__Venue__r.FMV1_Guidebook_Location_Import_Id__c,EventApi__Venue__r.FMV1_Guidebook_Location_Latitude__c,EventApi__Venue__r.FMV1_Guidebook_Location_Longitude__c,EventApi__Venue__r.EventApi__City__c,EventApi__Venue__r.EventApi__State__c,EventApi__Venue__r.EventApi__Street__c,EventApi__Venue__r.EventApi__Country__c,EventApi__Venue__r.EventApi__Postal_Code__c from EventApi__Room__c where (FMV1_Guide__c!=null AND FMV1_Location_Id__c = null) OR (FMV1_Guide__c!=null AND FMV1_Location_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventApi__Room__c > records) {  
        // system.debug('records value '+records);
        for(EventApi__Room__c  obj: records){
            if(obj.FMV1_Location_Id__c==null){
                GuidebookRestApiController.createRoom(obj);
            }else{
                GuidebookRestApiController.updateRoom(obj);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){    
        BatchForTrackSync batchTrack = new BatchForTrackSync();
        Database.executeBatch(batchTrack, 1);

    }
}