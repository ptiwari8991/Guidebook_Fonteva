import { LightningElement ,track}from 'lwc';
import setMetaData from '@salesforce/apex/GuidebookApiController.setMetaData';
import getApiKeyName from '@salesforce/apex/GuidebookApiController.getApiKeyName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class GuidebookApiController  extends LightningElement {
   @track msg = '';
    msgchange(event){
        this.msg = event.target.value;
    }
   @track data= '';
    async connectedCallback() {
      const data =  await getApiKeyName({ amountOfRecords:1});
      this.data = data;
      this.tableLoadingState = false;
      } 
   handleClick() {
      /*eslint-disable no-console*/
      var inputCmp = this.template.querySelector(".inputCmp");
      var apikey = inputCmp.value;
      console.log('Target value '+ apikey);
      setMetaData({ apikey });
      const toastEvnt = new  ShowToastEvent( {
         title: 'API Key Saved Successfully' ,
         message: this.msg ,
         variant: 'success' ,
      });
      this.dispatchEvent (toastEvnt);
   }
}