trigger CreateEvent4ScheduleVisit on Case_Activity__c (after Update) {

    for(Case_Activity__c irow:trigger.new) {
    
        If(irow.Case_Activity_Type__c == 'Schedule Audit' && irow.Activity_Start_Date__c <> null
                && irow.Activity_End_Date__c <> null && irow.Status__c <> 'Completed') {
                Event ev = new Event();
                //ev.OwnerId = irow.Ownerid;
                ev.ShowAs = 'Busy';
                ev.Subject = irow.Name;
                ev.IsReminderSet = false;
                ev.IsPrivate = false;
                ev.StartDateTime = irow.Activity_Start_Date__c;
                ev.EndDateTime = irow.Activity_End_Date__c;
                ev.WhatId = irow.id;
         insert ev; 
        }              
    }
    
}