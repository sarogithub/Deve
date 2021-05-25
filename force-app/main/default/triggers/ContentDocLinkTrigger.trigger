trigger ContentDocLinkTrigger on ContentDocumentLink (after insert) {
    ContentDocLinkTriggerCtrl.updateCaseInContentVersion(trigger.new, Trigger.operationType);
}