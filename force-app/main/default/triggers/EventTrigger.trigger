/**  Please Note: This trigger only checks for schedule conflicts if a new interview is being scheduled.  
The trigger does not check for conflicts for other types of events. The reason for this is that SOQL query limits 
could be reached if every type of event was checked.   15 minutes are added before the interviews 
in order to account for preparation & running over on time (see expandedStartTime, expandedEndTime)
*/
trigger EventTrigger on Event (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert || Trigger.isBefore && Trigger.isUpdate) {
    for (Event event : Trigger.new) {
        if (event.Subject == 'Job Interview') {
        DateTime expandedStartTime = event.StartDateTime.addMinutes(15);
        DateTime expandedEndTime = event.EndDateTime.addMinutes(15);
    
            
        List<Event> overlappingEvents = [SELECT Id, StartDateTime, EndDateTime 
                                        FROM Event 
                                        WHERE (StartDateTime < :expandedEndTime AND EndDateTime > :expandedStartTime)
                                        AND Id != :event.Id];  
            if (!overlappingEvents.isEmpty()) {
                for (Event overlappingEvent : overlappingEvents) {
                    if ((event.StartDateTime >= overlappingEvent.StartDateTime && event.StartDateTime < overlappingEvent.EndDateTime) ||
                        (event.EndDateTime > overlappingEvent.StartDateTime && event.EndDateTime <= overlappingEvent.EndDateTime)) {
                        event.addError('This interview may conflict with another event.');}
                    else {
                        event.addError('That won\'t give much time between interviews!');
                    }
                }
            }
        }
    }
    }
}      
    