import { LightningElement, api } from 'lwc';
import fetchCaseListAssociated from "@salesforce/apex/associatedCaseList.fetchCaseListAssociated";
import { NavigationMixin } from 'lightning/navigation';

export default class AssociatedCaseList extends NavigationMixin(LightningElement) {
    @api recordId;
    caseAssociateArray = [];
    hasData = false;

    connectedCallback(){
        fetchCaseListAssociated({
            caseRecordId : this.recordId
        })
        .then(result => {
            let outputVar = JSON.parse(result);
            console.log( ' outputVar.status' + outputVar.status );
            console.log( ' outputVar.caseAssociate' + JSON.stringify(outputVar.caseAssociate));

            if(outputVar.status === 'success'){
                this.caseAssociateArray = outputVar.caseAssociate;
                if(this.caseAssociateArray.length > 0){
                    this.hasData = true;
                }
            }else if(outputVar.status === 'error'){
                this.hasData = true;
            }
        }).catch(error => {
            this.hasData = false;
        });
    }

    openTab(event) {
        this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
            if (isConsole) {
                this.invokeWorkspaceAPI('getFocusedTabInfo').then(focusedTab => {
                    this.invokeWorkspaceAPI('isSubtab', {
                        tabId: focusedTab.tabId
                    }).then(isSubtab => {
                        if(isSubtab){
                            let parentTabId = focusedTab.tabId.split('_')[0];
                            this.invokeWorkspaceAPI('openSubtab', {
                                parentTabId: parentTabId,
                                recordId: event.target.dataset.id,
                                focus: true
                            }).then(tabId => {
                                console.log("Solution #2 - SubTab ID: ", tabId);
                            });
                        }else{
                            this.invokeWorkspaceAPI('openSubtab', {
                                parentTabId: focusedTab.tabId,
                                recordId: event.target.dataset.id,
                                focus: true
                            }).then(tabId => {
                                console.log("Solution #2 - SubTab ID: ", tabId);
                            });
                        }
                    });
                });
            }else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: event.target.dataset.id,
                        objectApiName: (event.target.dataset.objectname === 'Case' ? 'Case' : 'Account'),
                        actionName: 'view'
                    }
                });
            }
        });
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });
            window.dispatchEvent(apiEvent);
        });
    }
}