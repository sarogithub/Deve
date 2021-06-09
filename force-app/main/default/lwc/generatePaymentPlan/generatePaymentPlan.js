import { LightningElement, api } from 'lwc';
import getCaseAndPPDDetails from "@salesforce/apex/PaymentPlanController.GetCaseAndPPDDetails";
import PaymentPlanInitiation from "@salesforce/apex/PaymentPlanController.PaymentPlanInitiation";
import updatePaymentPlanDetails from "@salesforce/apex/PaymentPlanController.updatePaymentPlanDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GeneratePaymentPlan extends LightningElement {
    @api recordId;
    caseDetail = {};
    btnEnablement;

    totalPPAmtChange = false;
    PPTypeOrNoOfInstallmentChange = false;
    disableGenerateBtn = false;
    disableUpdatePPDBtn = false;

    popUpMessage = '';
    title;
    showModal = false;

    infoMessageTitle;
    infoMessageDescription;
    iconName;
    className;

    showInfoMessage = false;
    functionality;
    isLoading = false;
    spinnerLoadingMessage = 'Please wait...';
    isValid = false;
    inputParams;
    subscription;

    connectedCallback(){   
        this.showInfoMessage = false;
        this.showModal = false;
        this.totalPPAmtChange = false;
        this.PPTypeOrNoOfInstallmentChange = false;
        this.disableGenerateBtn = false;
        this.disableUpdatePPDBtn = false;

        document.addEventListener("lwc://refreshView", () => {
            console.log('event');
        });
        this.isLoading = true;

        getCaseAndPPDDetails(
            {
                recordId : this.recordId
            }
        ).then(result => {
            if(result) {
                let parsedOutput = JSON.parse(result);
                this.caseDetail = parsedOutput.caseDetails;
                this.btnEnablement = parsedOutput.btnEnablement;

                if(parsedOutput.dontAllowUsertoCreateOrUpdatePPD === 'true'){
                    this.disableGenerateBtn = true;
                    this.disableUpdatePPDBtn = true;

                    this.infoMessageTitle = 'Payment Plan Details Update is Not Allowed';
                    this.infoMessageDescription = 'One or More Payment is done, so you are not allowed to update the Payment Plan Details. Kindly go to the Individual Payment Plan Detail record and update it.'
                    this.className = 'infoBox';
                    this.iconName = 'utility:info';
                    //this.showInfoMessage = true; - commented to not to show the info message on screen
                }else if(this.btnEnablement === 'disableGenerateBtn'){
                    this.disableGenerateBtn = true;
                }else if(this.btnEnablement === 'disableUpdatePPDBtn'){
                    this.disableUpdatePPDBtn = true;
                }
                this.isLoading = false;
            }
        }).catch(error => {     
            console.log('error.body.message'); 
            const evt = new ShowToastEvent({
                title: "Error",
                message: error.body.message,
                variant: "error",
            });
            this.dispatchEvent(evt);
       });
    }

    openModalForGeneratePPDConfirm(){
        this.title = 'Generate Payment Plan Detail';
        this.functionality = 'GeneratePPD';
        this.showModal = true;
    }

    generatePaymentPlan(){
        this.isLoading = true;
        PaymentPlanInitiation(
            {
                caseRecString : JSON.stringify(this.caseDetail)
            }
        ).then(result => {
            if(result){
                let parsedOutput = JSON.parse(result);
                if(parsedOutput.status === 'Success'){
                    this.disableGenerateBtn = true;
                    this.disableUpdatePPDBtn = false;
                    document.dispatchEvent(new CustomEvent("aura://refreshView"));
                    this.isLoading = false;

                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Payment Plan Details Created Successfully",
                        variant: "success",
                    });
                    this.dispatchEvent(evt);
                }
            }
        }).catch(error => {      
            const evt = new ShowToastEvent({
                title: "Error",
                message: error.body.message,
                variant: "error",
            });
            this.dispatchEvent(evt);
        });
    }

    updatePaymentPlanValidation(){
        this.isValid = false;

        if((this.caseDetail.PP_Type_Backup__c != this.caseDetail.PP_Type__c || 
            this.caseDetail.No_Of_Installment_Backup__c != this.caseDetail.No_Of_Installment__c || 
            this.caseDetail.PP_Begin_Date_Backup__c != this.caseDetail.PP_Begin_Date__c)
            && typeof this.caseDetail.PP_Type_Backup__c != 'undefined' 
            && typeof this.caseDetail.No_Of_Installment_Backup__c != 'undefined'
            && typeof this.caseDetail.PP_Begin_Date_Backup__c != 'undefined'
            && this.caseDetail.PP_Type_Backup__c != null
            && this.caseDetail.No_Of_Installment_Backup__c != null
            && this.caseDetail.PP_Begin_Date_Backup__c != null) {
                this.PPTypeOrNoOfInstallmentChange = true;
        }else if(this.caseDetail.Total_PP_Amount_Backup__c != this.caseDetail.Total_PP_Amount__c && 
            typeof this.caseDetail.Total_PP_Amount_Backup__c != 'undefined' && 
            this.caseDetail.Total_PP_Amount_Backup__c != null ){
            this.totalPPAmtChange = true;
        }

        if(this.PPTypeOrNoOfInstallmentChange){
            this.popUpMessage = 'PP Type or No Of Installment or PP Begin Date is changed, so system will regenerate the Payment Plan Details. Existing records will be deleted';
            this.title = 'Delete Existing Payment Plan Detail';
            this.functionality = 'UpdatePPD';
            this.showModal = true;
            this.isValid = true;
        }else if(this.totalPPAmtChange){
            this.popUpMessage = 'Total PP Amount is changed, so system will update the existing payment plan details';
            this.title = 'Update Existing Payment Plan Detail Amount';
            this.functionality = 'UpdatePPD';
            this.showModal = true;
            this.isValid = true;
        }else{
            this.infoMessageTitle = 'No Change in Payment Plan Header';
            this.infoMessageDescription = 'There is no change in Payment Plan Header. Kindly update the payment plan header details and click Refresh Button.'
            this.className = 'infoBox';
            this.iconName = 'utility:info';
            this.showInfoMessage = true;
        }
    }

    handleOnConfirmFromModal(event){
        if(event.detail.confirmationOutput){
            if(event.detail.functionality === 'UpdatePPD'){
                if(this.isValid === true){
                    this.updatePaymentPlanDetailsApex();
                    this.showModal = false;
                }
            }else if(event.detail.functionality === 'GeneratePPD'){
                this.generatePaymentPlan();
                this.showModal = false;
            }
        }
        if(!event.detail.confirmationOutput){
            this.showModal = false;
        }
    }

    refresh(){
        this.connectedCallback();
    }

    updatePaymentPlanDetailsApex(){
        this.isLoading = true;

        this.inputParams = {
            totalPPAmtChange : this.totalPPAmtChange,
            PPTypeOrNoOfInstallmentChange : this.PPTypeOrNoOfInstallmentChange,
            caseId : this.caseDetail.Id
        }

        updatePaymentPlanDetails(
            {
                inputParams : JSON.stringify(this.inputParams)
            }
        ).then(result => {
            if(result){
                let parsedOutput = JSON.parse(result);
                if(parsedOutput.status === 'Success'){
                    this.disableGenerateBtn = true;
                    this.disableUpdatePPDBtn = true;
                    document.dispatchEvent(new CustomEvent("aura://refreshView"));
                    this.isLoading = false;

                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Payment Plan Details Re-Created Successfully",
                        variant: "success",
                    });
                    this.dispatchEvent(evt);
                }
            }
        }).catch(error => {      
            const evt = new ShowToastEvent({
                title: "Error",
                message: error.body.message,
                variant: "error",
            });
            this.dispatchEvent(evt);
        });
    }
}