import { LightningElement,api } from 'lwc';

export default class ConfirmationModal extends LightningElement {

  @api title;
  @api popUpMessage;
  @api functionality;

  handleOk(event) {
    const selectedEvent = new CustomEvent("confirm", {
      detail: {
        confirmationOutput: true,
        functionality: this.functionality
      }
    });
    this.dispatchEvent(selectedEvent);
  }

  handleCancel(event) {
    const selectedEvent = new CustomEvent("confirm", {
      detail: {
        confirmationOutput: false,
        functionality: this.functionality
      }
    });
    this.dispatchEvent(selectedEvent);
  }
}