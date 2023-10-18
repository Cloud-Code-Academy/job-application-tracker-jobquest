/**  Please Note: This trigger only checks for schedule conflicts when an interview is being scheduled.  
*/
trigger EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    EventTriggerHandler handler = new EventTriggerHandler();
    handler.run();
}    