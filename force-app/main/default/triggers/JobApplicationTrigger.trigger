trigger JobApplicationTrigger on Job_Application__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    JobApplicationTriggerHandler handler = new JobApplicationTriggerHandler();
    handler.run();
}