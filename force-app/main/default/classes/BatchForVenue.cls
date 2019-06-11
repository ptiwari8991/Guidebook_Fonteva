global class BatchForVenue implements Database.Batchable<sObject>,   Database.AllowsCallouts {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        List<AsyncApexJob> lastbatchRun = [SELECT id,ApexClass.Name,CompletedDate,Status FROM AsyncApexJob where ApexClass.Name='BatchForVenue'AND Status='Completed' Order By CompletedDate Desc LIMIT 1];
        if(lastbatchRun.size()>0)
                Datetime lastJobDate = lastbatchRun[0].CompletedDate;
            query='select Name,FMV1_Guide__c,Last_Sync_Date__c,FMV1_location_Type__c,EventApi__City__c,EventApi__State__c,EventApi__Country__c,EventApi__Street__c,EventApi__Postal_Code__c,FMV1_Guidebook_Location_Import_Id__c,FMV1_Guidebook_Location_Latitude__c,FMV1_Guidebook_Location_Longitude__c,FMV1_Location_Id__c from EventApi__Venue__c where (FMV1_Guide__c!=null AND FMV1_Location_Id__c = null) OR (FMV1_Guide__c!=null AND FMV1_Location_Id__c != null AND Last_Sync_Date__c >= :lastJobDate)';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EventApi__Venue__c> records) {  
        system.debug('records value '+records);
        for(EventApi__Venue__c obj: records){
            if(obj.FMV1_Location_Id__c==null){
                GuidebookRestApiController.createVenue(obj);
            }else{
                GuidebookRestApiController.updateVenue(obj);
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){    
        BatchForRoomSync batchRoom = new BatchForRoomSync();
        Database.executeBatch(batchRoom, 1);
    }
}