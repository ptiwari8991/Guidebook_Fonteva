public class GuidebookApiController {
    
    @AuraEnabled
    public static list<EventApi__Event__c> getGuides(){
        
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/guides/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'GET',apiKeyvalue,null);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        
        Reponsevalue wrapper = (Reponsevalue) JSON.deserialize(response.getBody(), Reponsevalue.class);
        
        List<EventApi__Event__c> sObjs= new list<EventApi__Event__c>();
        for(results obj: wrapper.results){
            EventApi__Event__c regObj = new EventApi__Event__c();
            regObj.FMV1_Guide_ID__c = obj.id;
            regObj.Name = obj.name;
            regObj.EventApi__End_Date_Time__c = obj.end_date;
            regObj.EventApi__Start_Date_Time__c = obj.start_date;
            regObj.EventApi__Time_Zone__c = obj.timezone;
            regObj.FMV1_Guide_Description_HTML__c = obj.description_html;
            sObjs.add(regObj);
            
        }  
        return sObjs;
    } 

    /*Method to update Guides from Fonteva To GuideBook */
    @AuraEnabled
    public static list<EventApi__Event__c> updateGuides(Decimal guideId){
        
        EventApi__Event__c guideObj=[select FMV1_Guide_ID__c,EventApi__Time_Zone__c, EventApi__Start_Date_Time__c,EventApi__Description__c, FMV1_Guide_Description_HTML__c,EventApi__End_Date_Time__c,Name from EventApi__Event__c where FMV1_Guide_ID__c=:guideId limit 1];
        
        
        GuidebookGuide guide = new GuidebookGuide();
        if(string.isNotBlank(guideObj.FMV1_Guide_Description_HTML__c))
            guide.description_html = guideObj.FMV1_Guide_Description_HTML__c;
        guide.timezone  = guideObj.EventApi__Time_Zone__c;
        guide.end_date = guideObj.EventApi__End_Date_Time__c;
        guide.start_date = guideObj.EventApi__Start_Date_Time__c;
        if(string.isNotBlank(guideObj.Name))
            guide.name = guideobj.Name;
        
        String jsonstring = Json.serialize(guide,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt GuidebookapiKey = [select API_Key__c , Username__c from Guidebook__mdt limit 1];
        string endPoint='https://builder.guidebook.com/open-api/v1/guides/'+((guideobj.FMV1_Guide_ID__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',GuidebookapiKey.API_Key__c,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='OK'){
            guideobj.Last_Sync_Date__c= System.now(); 
            update guideobj;
        }
        return null;
    }
    
    /* Method To Fetch Current Event Record Data */
    @AuraEnabled
    public static EventApi__Event__c getEvent(ID eventId){
        return [select id ,FMV1_Guide_ID__c,Name, EventApi__End_Date__c,EventApi__Start_Date__c, EventApi__Event_Key__c from EventApi__Event__c where Id =: eventId];
    }
    
    /* Method to Update Event With Selected Guide */
    @AuraEnabled
    public static void SyncData(ID eventId , decimal guideId , string Name, string description, datetime startDate , datetime endDate){
        
        EventApi__Event__c   eventData= [select id ,FMV1_Guide_Description_HTML__c,Name,EventApi__End_Date__c,EventApi__Start_Date__c,FMV1_Guide_ID__c from EventApi__Event__c where Id =: eventId ];
        eventData.FMV1_Guide_ID__c = GuideId;
        eventData.FMV1_Guide_Description_HTML__c = description;
        eventData.Name = name;      // This Field is required in salesforce org so we mapped this field with Name.
        eventData.EventApi__End_Date__c = Date.valueOf(endDate) ;
        eventData.EventApi__Start_Date__c = Date.valueOf(startDate);
        eventData.EventApi__Start_Date_Time__c = startDate;
        eventData.EventApi__End_Date_Time__c = endDate;
        update eventData;
    }
    
    public class results{
        public  Decimal id;
        public  String name;
        public  datetime end_date;
        public  string description_html ;
        public  datetime start_date;
        public  string timezone ;
    }
    
    public class Reponsevalue{
        public List<results> results;
    }
    
    /* Method to Update/Insert Custom MetaData Types */
    
    public static void setMetaData(string apiKey){
        User usr = [SELECT ID,Username, Name FROM User WHERE ID = :UserInfo.getUserId()];
        Guidebook_Setting__c GuidebookapiKey ;
        If(string.isNotBlank(usr.Username))
         GuidebookapiKey = Guidebook_Setting__c.getValues(usr.Username);
         If(GuidebookapiKey != null){
            GuidebookapiKey.Api_Key__c ='JWT '+ apiKey;
            update GuidebookapiKey;
        }else{
            Guidebook_Setting__c Guidebook = new Guidebook_Setting__c();
            Guidebook.Name = usr.Username;
            Guidebook.Api_Key__c = 'JWT '+ apiKey;
            insert Guidebook;
        }
        
    }
}