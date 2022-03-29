import { LightningElement,track,wire } from 'lwc';
import loadCases from '@salesforce/apex/data_table.loadCases';
import {loadStyle} from 'lightning/platformResourceLoader'
import REMOVEROW from '@salesforce/resourceUrl/removeRow'

export default class data_table extends LightningElement {
    @track caseData;
    @track caseColumns = [
    { label: 'Id', fieldName: 'Id', type: 'text'},
    { label: 'Name', fieldName: 'Name', type: 'text'}
    ];

    @wire(loadCases)
    getCaseRecord(result){
        if (result.data) {
            this.caseData = result.data;
        }
    }

    renderedCallback(){ 
        Promise.all([
            loadStyle( this, REMOVEROW)
            ]).then(() => {
                console.log( 'Files loaded' );
            })
            .catch(error => {
                console.log( 'error',error );
        });
    }

}