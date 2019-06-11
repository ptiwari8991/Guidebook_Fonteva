/* Class is used to Create,Update records for ScheduleItem,Track,Attendee,RegistrationItem,Room,Venue,Speaker Objects.*/

public class GuidebookRestApiController {
    
    /*Method to Map Session object Data */
    public static GuidebookSession getSessionData(EventAPI__Schedule_Item__c sessionObj){
        
        List<decimal> listLocations = new List<decimal>();
        if(sessionObj.EventApi__Room__r.FMV1_Location_Id__c != null)
            listLocations.add(sessionObj.EventApi__Room__r.FMV1_Location_Id__c);
        List<decimal> listTracks = new List<decimal>();
        EventAPI__Schedule_Item__c  sessionObjTrack =  [select id , name , session_Id__c,(select id , name , EventApi__Track__c ,EventApi__Track__r.Schedule_Track_Id__c ,EventAPI__Schedule_Item__c from EventApi__Track_Schedule_Items__r) from EventAPI__Schedule_Item__c where id=:sessionObj.id LIMIT 1];
        for(EventApi__Track_Schedule_Item__c obj: sessionObjTrack.EventApi__Track_Schedule_Items__r){
            if(obj.EventApi__Track__c != null)
                listTracks.add(obj.EventApi__Track__r.Schedule_Track_Id__c);
        }
        GuidebookSession gAtt= new GuidebookSession();
        gAtt.guide=integer.valueOf(sessionObj.FMV1_Guide__c);
        gAtt.name=sessionObj.Name;
        if(String.isNotBlank(sessionObj.FMV1_Guidebook_Import_Id__c))
            gAtt.import_id= sessionObj.FMV1_Guidebook_Import_Id__c;
        if(String.isNotBlank(sessionObj.EventApi__Description__c))
            gAtt.description_html= sessionObj.EventApi__Description__c;
        gAtt.add_to_schedule= sessionObj.EventApi__Disable_Registration__c;
        gAtt.start_time= sessionObj.EventApi__Start_Date_Time__c;
        gAtt.end_time= sessionObj.EventApi__End_Date_Time__c;
        
        if(listLocations.size()>0)
            gAtt.locations= listLocations;
        if(listTracks.size()>0)
            gAtt.schedule_tracks= listTracks;
        
        return gAtt;
        
    }
    
    /* Method To Create ScheduleItem From Fonteva To GuideBook */ 
    public static list<EventAPI__Schedule_Item__c> createSession(EventAPI__Schedule_Item__c sessionObj){
        
        GuidebookSession gAtt = getSessionData(sessionObj);
        
        String jsonstring = Json.serialize(gAtt,true); 
        System.debug('jsonstring'+jsonstring);
        
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/sessions/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Created'){
            GuidebookSession session= GuidebookSession.parse(response.getBody());
            sessionObj.session_Id__c = session.id;
            sessionObj.Last_Sync_Date_Schedule__c= System.now(); 
            update sessionObj;
        }
        
        return null ;
        
    }
    
    /* Method To Update ScheduleItem From Fonteva To GuideBook */
    public static list<EventAPI__Schedule_Item__c> updateSession(EventAPI__Schedule_Item__c sessionObj){
        
        GuidebookSession gAtt = getSessionData(sessionObj);        
        String jsonstring = Json.serialize(gAtt,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/sessions/'+((sessionObj.session_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='OK'){
            sessionObj.Last_Sync_Date_Schedule__c= System.now(); 
            update sessionObj;
        }
        
        return null ;
        
    }
    
    /*Method to Map speaker object Data */
    
    public static GuidebookSpeaker getSpeakerData(EventApi__Speaker__c speakerObj){
        
        GuidebookSpeaker speaker = new GuidebookSpeaker();
        speaker.allow_rating = speakerObj.allow_rating__c;
        speaker.disable_todo = speakerObj.Disable_Todo__c;
        speaker.guide =  integer.valueOf(speakerObj.FMV1_Guide__c);
        if(string.isNotBlank(speakerObj.Import_Id__c))
            speaker.import_id = speakerObj.Import_Id__c;
        speaker.name = speakerObj.Name;
        
        return speaker;
        
    }
    /* Method to Create speaker object Data From Fonteva to Guidebook */
    public static list<EventApi__Speaker__c> createSpeakers(EventApi__Speaker__c speakerObj){
        
        GuidebookSpeaker speaker = getSpeakerData(speakerObj);
        
        String jsonstring = Json.serialize(speaker,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt GuidebookapiKey = [select API_Key__c , Username__c from Guidebook__mdt limit 1];
        string endPoint='https://builder.guidebook.com/open-api/v1/custom-lists/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',GuidebookapiKey.API_Key__c,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        system.debug('response=='+response);
        if(response.getStatus()=='Created'){
            GuidebookSpeaker guide = GuidebookSpeaker.parse(response.getBody());
            speakerObj.Speaker_Id__c = guide.id;//Decimal.valueOf(response.getBody().substringBetween(':', ','));
            speakerObj.Last_Sync_Date__c= System.now(); 
            update speakerObj;
        }
        return null;
    }
    
    /* Method to Update speaker object Data From Fonteva to Guidebook */
    
    public static list<EventApi__Speaker__c> updateSpeakers(EventApi__Speaker__c speakerObj){
        
        GuidebookSpeaker speaker = getSpeakerData(speakerObj);
        
        String jsonstring = Json.serialize(speaker,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt GuidebookapiKey = [select API_Key__c , Username__c from Guidebook__mdt limit 1];
        if(speakerObj.Speaker_Id__c != null){
            string endPoint='https://builder.guidebook.com/open-api/v1/custom-lists/'+((speakerObj.Speaker_Id__c).round(System.RoundingMode.DOWN))+'/';
            HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',GuidebookapiKey.API_Key__c,jsonstring);
            HttpResponse response = IntegrationHelper.GetResponse(req);
            if(response.getStatus()=='OK'){
                speakerObj.Last_Sync_Date__c= System.now(); 
                update speakerObj;
            }
            
        }
        return null;
    }
    
    /* Method to Map attendee object Data */
    public static GuidebookAttendee getAttendeeData(EventApi__Attendee__c attendeeObj){
        
        GuidebookAttendee attendee = new GuidebookAttendee();
        if(string.isNotBlank(attendeeObj.EventApi__First_Name__c))
            attendee.first_name = attendeeObj.EventApi__First_Name__c;
        if(string.isNotBlank(attendeeObj.EventApi__Last_Name__c))
            attendee.last_name = attendeeObj.EventApi__Last_Name__c;
        attendee.guide = Integer.valueOf(attendeeObj.FMV1_Guide__c);
        // attendee.guide_id = Integer.valueOf(attendeeObj.FMV1_Guide__c);
        attendee.revoked = attendeeObj.FMV1_Revoked__c;
        if(string.isNotBlank(attendeeObj.EventApi__Email__c))
            attendee.email = attendeeObj.EventApi__Email__c;
        if(string.isNotBlank(attendeeObj.FMV1_Guidebook_Import_Id__c))
            attendee.import_id = attendeeObj.FMV1_Guidebook_Import_Id__c;
        
        return attendee;
        
    }
    
    /* Method to Create Attendee object Data From Fonteva to Guidebook */
    public static list<EventApi__Attendee__c> createAttendees(EventApi__Attendee__c attendeeObj){
        
        GuidebookAttendee attendee = getAttendeeData(attendeeObj);
        String jsonstring = Json.serialize(attendee,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt GuidebookapiKey = [select API_Key__c , Username__c from Guidebook__mdt limit 1];
        string endPoint='https://builder.guidebook.com/open-api/v1/attendees/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',GuidebookapiKey.API_Key__c,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Created'){
            GuidebookAttendee guideAttendee = GuidebookAttendee.parse(response.getBody());
            attendeeObj.Attendee_Id__c = guideAttendee.Id;
            attendeeObj.Last_Sync_Date__c= System.now(); 
            update attendeeObj;
        }
        return null;
    } 
    
    /* Method to Update Attendee object Data From Fonteva to Guidebook */
    public static list<EventApi__Attendee__c> updateAttendees(EventApi__Attendee__c attendeeObj){
        
        GuidebookAttendee attendee = getAttendeeData(attendeeObj);
        String jsonstring = Json.serialize(attendee,true); 
        System.debug('jsonstring'+jsonstring);
        Guidebook__mdt GuidebookapiKey = [select API_Key__c , Username__c from Guidebook__mdt limit 1];
        string endPoint='https://builder.guidebook.com/open-api/v1/attendees/'+((attendeeObj.Attendee_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',GuidebookapiKey.API_Key__c,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='OK'){
            attendeeObj.Last_Sync_Date__c= System.now(); 
            update attendeeObj;
        }
        return null;
    } 
    
    /* Method to Update Guide Data From Fonteva to Guidebook */
    public static list<EventApi__Event__c> updateGuides(EventApi__Event__c guideObj){
        
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
    
    /* Method to Map Registration object Data */
    public static GuidebookRegistrationItem getRegistrationItemData(EventApi__Registration_Item__c regItemObj){
        List<Integer> listAttendees = new List<Integer>();
        listAttendees.add(integer.valueOf(regItemObj.FMV1_Attendee_id__c));
        
        List<Integer> listSessions = new List<Integer>();
        listSessions.add(integer.valueOf(regItemObj.FMV1_Schedule_Item_id__c));
        
        GuidebookRegistrationItem gAtt= new GuidebookRegistrationItem();
        gAtt.guide=integer.valueOf(regItemObj.FMV1_Guide__c);
        gAtt.name=regItemObj.FMV1_Name__c;
        
        if(listAttendees.size()>0)
            gAtt.attendees= listAttendees;
        if(listSessions.size()>0)
            gAtt.sessions= listSessions;
        
        return gAtt;        
    }
    /* Method to Update Registration object Data From Fonteva To Guidebook */
    public static list<EventApi__Registration_Item__c> updateRegistrationItem(EventApi__Registration_Item__c regItemObj){   
        
        GuidebookRegistrationItem gAtt= getRegistrationItemData(regItemObj);
        
        String jsonstring = Json.serialize(gAtt,true); 
        System.debug('jsonstring'+jsonstring);
        
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/personalized-schedules/'+((regItemObj.Registration_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus() =='OK'){
            regItemObj.Last_Sync_Date__c= System.now(); 
            update regItemObj;
        }
        return null ; 
    }
    
    /* Method to Create Registration object Data From Fonteva To Guidebook */
    public static list<EventApi__Registration_Item__c> createRegistrationItem(EventApi__Registration_Item__c regItemObj){   
        
        GuidebookRegistrationItem gAtt= getRegistrationItemData(regItemObj);
        
        String jsonstring = Json.serialize(gAtt,true); 
        System.debug('jsonstring'+jsonstring);
        
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/personalized-schedules/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus() =='Created'){
            GuidebookRegistrationItem  obj = GuidebookRegistrationItem.parse(response.getBody());
            regItemObj.Registration_Id__c = obj.id;
            regItemObj.Last_Sync_Date__c= System.now(); 
            update regItemObj;
        }
        return null ; 
    }
    
    /* Method to Create Registration object Data From Guidebook To Fonteva */
    public static list<EventApi__Registration_Item__c> getRegistrationItem(){
        
        Map<Decimal,EventApi__Attendee__c> mapAttendee=new Map<Decimal,EventApi__Attendee__c>();
        Map<Decimal,EventAPI__Schedule_Item__c> mapSession=new Map<Decimal,EventAPI__Schedule_Item__c>();
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        
        string endPoint='https://builder.guidebook.com/open-api/v1/personalized-schedules/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'GET',apiKeyvalue,null);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        
        Reponsevalue regobjList = (Reponsevalue) JSON.deserialize(response.getBody(), Reponsevalue.class);
        set<Decimal> setAttendeeId=new set<Decimal>();
        set<Decimal> setSessionId = new set<Decimal>();
        string attId ;
        string sesId ;
        if(regobjList.results.size() >0 && regobjList.results != null){
            for(results obj: regobjList.results){
                if(obj.attendees.size()>0){
                    for(Decimal attendeeId:obj.attendees){
                        setAttendeeId.add(attendeeId);
                    }               
                }
                if(obj.sessions.size()>0){
                    for(Decimal sessionId :obj.sessions){
                        setSessionId.add(sessionId);
                    }               
                }
            }
        }
        if(setAttendeeId.size()>0){
            for( EventApi__Attendee__c attendee:[select id,Attendee_Id__c from EventApi__Attendee__c where Attendee_Id__c IN: setAttendeeId]){
                mapAttendee.put(attendee.Attendee_Id__c, attendee);
            }
        }
        if(setSessionId.size()>0){
            for( EventAPI__Schedule_Item__c session:[select id,session_Id__c from EventAPI__Schedule_Item__c where session_Id__c IN: setSessionId]){
                mapSession.put(session.session_Id__c, session);
            }
        }
        List<EventApi__Registration_Item__c> lstItem= new list<EventApi__Registration_Item__c>();
        for(results obj: regobjList.results){
            EventApi__Registration_Item__c regObj = new EventApi__Registration_Item__c();
            for(Decimal attendeeId:obj.attendees){
                if(mapAttendee.containsKey(attendeeId)){
                    attId = mapAttendee.get(attendeeId).Id;
                }
            }
            for(Decimal sessionId:obj.sessions){
                if(mapSession.containsKey(sessionId))
                    sesId =mapSession.get(sessionId).Id;
            }
            regObj.EventApi__Attendee__c= attId;
            regObj.EventApi__Schedule_Item__c = sesId;
            regObj.FMV1_Name__c=obj.name;
            regObj.Registration_Id__c=obj.id;
            if(regObj.EventApi__Attendee__c != null && regObj.EventApi__Schedule_Item__c != null)
                lstItem.add(regObj);
        }
        if(lstItem.size()>0){
            upsert lstItem Registration_Id__c;  
        } 
        return null;
    } 
    public class results{
        public  Decimal id;
        public  Decimal guide;
        public  String name;
        public  List<Decimal> attendees;
        public  List<Decimal> sessions;  
    }
    public class Reponsevalue{
        public List<results> results;
    }
    
    /* Method to map Track object records */
    public static GuidebookTrack getTrackData(EventApi__Track__c trackObj){
        GuidebookTrack gAtt = new GuidebookTrack();
        gAtt.name=trackObj.Name; 
        gAtt.guide=integer.valueOf(trackObj.FMV1_Guide__c);
        if(String.isNotBlank(trackObj.EventApi__Track_Color__c))
            gAtt.color=trackObj.EventApi__Track_Color__c;
        return gAtt;
    }
    
    /* Method to Create Track object record from Fonteva to Guidebook */
    public static list<EventApi__Track__c> createTrack(EventApi__Track__c trackObj){
        
        GuidebookTrack gAtt = getTrackData(trackObj);
        String jsonstring = Json.serialize(gAtt,true);  
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        string endPoint='https://builder.guidebook.com/open-api/v1/schedule-tracks/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Created'){      
            GuidebookTrack obj = GuidebookTrack.parse(response.getBody());
            trackObj.Schedule_Track_Id__c=obj.id;
            trackObj.Last_Sync_Date__c= System.now(); 
            update trackObj;
        }
        return null;
    }
    /* Method to Update Track object record from Fonteva to Guidebook */
    public static list<EventApi__Track__c> updateTrack(EventApi__Track__c trackObj){
        
        GuidebookTrack gAtt =getTrackData(trackObj);
        String jsonstring = Json.serialize(gAtt,true);  
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c; 
        string endPoint='https://builder.guidebook.com/open-api/v1/schedule-tracks/'+((trackObj.Schedule_Track_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='OK'){
            trackObj.Last_Sync_Date__c= System.now(); 
            update trackObj;
        }
        return null;  
    }
    
    /* Method to Update Venue object record from Fonteva to Guidebook */
    public static list<EventApi__Venue__c> updateVenue(EventApi__Venue__c venueObj){
        
        GuidebookVenue gAtt = getVenueData(venueObj);
        String jsonstring = Json.serialize(gAtt,true); 
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c; 
        string endPoint='https://builder.guidebook.com/open-api/v1/locations/'+((venueObj.FMV1_Location_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='OK'){
            venueObj.Last_Sync_Date__c= System.now(); 
            update venueObj;
        }
        return null;  
    }
    /* Method to Create Venue object record from Fonteva to Guidebook */
    public static list<EventApi__Venue__c> createVenue(EventApi__Venue__c venueObj){
        
        GuidebookVenue gAtt = getVenueData(venueObj);
        String jsonstring = Json.serialize(gAtt,true);  
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        string endPoint='https://builder.guidebook.com/open-api/v1/locations/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Created'){         
            GuidebookVenue obj = GuidebookVenue.parse(response.getBody());
            venueObj.FMV1_Location_Id__c=obj.id;
            venueObj.Last_Sync_Date__c= System.now(); 
            update venueObj;
        }
        return null;
    }
    /* Method to map Venue object records */
    public static GuidebookVenue getVenueData(EventApi__Venue__c venueObj){
        
        GuidebookVenue gAtt = new GuidebookVenue();
        GuidebookVenue.Address  address = new GuidebookVenue.Address();
        gAtt.name=venueObj.Name; 
        gAtt.guide=integer.valueOf(venueObj.FMV1_Guide__c);
        gAtt.location_type=Integer.valueOf(venueObj.FMV1_location_Type__c);
        if(String.isNotBlank(venueObj.FMV1_Guidebook_Location_Import_Id__c))
            gAtt.import_id=venueObj.FMV1_Guidebook_Location_Import_Id__c;
        if(venueObj.FMV1_Guidebook_Location_Latitude__c!=null)
            gAtt.latitude=venueObj.FMV1_Guidebook_Location_Latitude__c;
        if(venueObj.FMV1_Guidebook_Location_Longitude__c!=null)
            gAtt.longitude=venueObj.FMV1_Guidebook_Location_Longitude__c;
        if(String.isNotBlank(venueObj.EventApi__City__c))
            address.city =venueObj.EventApi__City__c;
        if(String.isNotBlank(venueObj.EventApi__State__c))
            address.state=venueObj.EventApi__State__c;
        if(String.isNotBlank(venueObj.EventApi__Street__c))
            address.street=venueObj.EventApi__Street__c;
        if(String.isNotBlank(venueObj.EventApi__Postal_Code__c))
            address.zipcode=venueObj.EventApi__Postal_Code__c;
        if(String.isNotBlank(venueObj.EventApi__Country__c))
            address.country=venueObj.EventApi__Country__c;
        gAtt.address=address; 
        return gAtt;
    }
    
    /* Method to map Room object records */
    public static GuidebookRoom getRoomData(EventApi__Room__c roomObj){
        
        GuidebookRoom gAtt = new GuidebookRoom();
        GuidebookRoom.Address  address = new GuidebookRoom.Address();
        gAtt.name=roomObj.Name; 
        gAtt.guide=integer.valueOf(roomObj.FMV1_Guide__c);
        gAtt.location_type=Integer.valueOf(roomObj.EventApi__Venue__r.FMV1_location_Type__c);
        if(String.isNotBlank(roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Import_Id__c))
            gAtt.import_id=roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Import_Id__c;
        if(roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Latitude__c!=null)
            gAtt.latitude=roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Latitude__c;
        if(roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Longitude__c!=null)
            gAtt.longitude=roomObj.EventApi__Venue__r.FMV1_Guidebook_Location_Longitude__c;
        if(String.isNotBlank(roomObj.EventApi__Venue__r.EventApi__City__c))
            address.city =roomObj.EventApi__Venue__r.EventApi__City__c;
        if(String.isNotBlank(roomObj.EventApi__Venue__r.EventApi__State__c))
            address.state=roomObj.EventApi__Venue__r.EventApi__State__c;
        if(String.isNotBlank(roomObj.EventApi__Venue__r.EventApi__Street__c))
            address.street=roomObj.EventApi__Venue__r.EventApi__Street__c;
        if(String.isNotBlank(roomObj.EventApi__Venue__r.EventApi__Postal_Code__c))
            address.zipcode=roomObj.EventApi__Venue__r.EventApi__Postal_Code__c;
        if(String.isNotBlank(roomObj.EventApi__Venue__r.EventApi__Country__c))
            address.country=roomObj.EventApi__Venue__r.EventApi__Country__c;
        gAtt.address=address;
        return gAtt;
    }
    /* Method to Create Room object record from Fonteva to Guidebook */
    public static list<EventApi__Room__c> createRoom(EventApi__Room__c roomObj){
        
        GuidebookRoom gAtt = getRoomData(roomObj);
        String jsonstring = Json.serialize(gAtt,true);  
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        string endPoint='https://builder.guidebook.com/open-api/v1/locations/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'POST',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Created'){         
            GuidebookRoom obj = GuidebookRoom.parse(response.getBody());
            roomObj.FMV1_Location_Id__c=obj.id;
            roomObj.Last_Sync_Date__c= System.now(); 
            update roomObj;
        }
        return null;
        
        
    }
    /* Method to Update Venue object record from Fonteva to Guidebook */
    public static list<EventApi__Room__c> updateRoom(EventApi__Room__c roomObj){
        GuidebookRoom gAtt = getRoomData(roomObj);
        String jsonstring = Json.serialize(gAtt,true);  
        Guidebook__mdt apiKey =  [select API_Key__c,Username__c from Guidebook__mdt limit 1]; 
        String apiKeyvalue =  apiKey.API_Key__c;
        string endPoint='https://builder.guidebook.com/open-api/v1/locations/'+((roomObj.FMV1_Location_Id__c).round(System.RoundingMode.DOWN))+'/';
        HttpRequest req =  IntegrationHelper.getRequestObject(endPoint,'PUT',apiKeyvalue,jsonstring);
        HttpResponse response = IntegrationHelper.GetResponse(req);
        if(response.getStatus()=='Ok'){   
            roomObj.Last_Sync_Date__c= System.now(); 
            update roomObj;
        }
        
        return null;
    }
}