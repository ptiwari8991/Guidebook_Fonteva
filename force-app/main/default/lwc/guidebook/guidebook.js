import { LightningElement,track,api} from 'lwc';
import getGuides from '@salesforce/apex/GuidebookApiController.getGuides';
import SyncData from '@salesforce/apex/GuidebookApiController.SyncData';

const columns=[
     {label: 'Guide Name', fieldName: 'Name', type: 'text'},
      {label: 'Description', fieldName: 'FMV1_Guide_Description_HTML__c', type: 'Text',title:'FMV1_Guide_Description_HTML__c'},
      {label: 'Start Time', fieldName: 'EventApi__Start_Date_Time__c', type: 'Text'},
      {label: 'End Time', fieldName: 'EventApi__End_Date_Time__c', type: 'Text'}
  ];
export default class Guidebook extends LightningElement {
        @track data = [];
        @api recordId;
        @api guideId;
        @api guideName;
        @api startDatetime;
        @api endDatetime;
        @api guideDescription;
        @api columns = columns;
   
      async connectedCallback() {
          /*eslint-disable no-console*/
          console.log('recordId '+ this.name);
        const data =  await getGuides({ amountOfRecords: 100 });
        this.data = data;
        this.tableLoadingState = false;    
    }
    
    getSelectedName(event) {
        
         /*eslint-disable no-console*/
        
         console.log('I am in Method Now')
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            /*eslint-disable no-console*/
          
          this.guideId = selectedRows[i].FMV1_Guide_ID__c;
          console.log(this.guideId);
          this.guideName = selectedRows[i].Name;
          this.startDatetime = selectedRows[i].EventApi__Start_Date_Time__c;
          this.endDatetime = selectedRows[i].EventApi__End_Date_Time__c;
          this.guideDescription = selectedRows[i].FMV1_Guide_Description_HTML__c;   

        }
    }
    syncData(){
         /*eslint-disable no-console*/
        // console.log($recordId);
         console.log(this.guideName);
         //console.log(recordId);
        SyncData({eventId:this.recordId,guideId:this.guideId,Name:this.guideName,description:this.guideDescription,startDate:this.startDatetime,endDate:this.endDatetime});
    }
       
    
}