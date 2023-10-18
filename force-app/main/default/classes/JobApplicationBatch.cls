global class JobApplicationBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date aMonthAgo = Date.today().addDays(-30); 
        String query = 'SELECT Id, Status__c, Notes__c, Follow_up_Date__c FROM Job_Application__c WHERE Follow_up_Date__c <= :aMonthAgo AND (Status__c != \'Accepted\' AND Status__c != \'Closed\')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {    //Scope has two connotations in Apex batch jobs. 1. related to the records returned from the start method. 2. defines how many records the execute method receives in each iteration of your job. 
        List<Job_Application__c> applicationsToUpdate = new List<Job_Application__c>();
        for (sObject scop : scope) {            
            Job_Application__c application = (Job_Application__c) scop;
            application.Status__c = 'Closed';
            application.Notes__c = 'This job application was closed by an automated process.';
            applicationsToUpdate.add(application);
        }
        if (applicationsToUpdate.size() > 0) {
            List<Database.SaveResult> saveResults = Database.update(applicationsToUpdate, false);  //false allows for partial save as in not all or nothing
            for (Database.SaveResult saveRest : saveResults) {  
                if (!saveRest.isSuccess()) {
                    for (Database.Error err : saveRest.getErrors()) {
                        System.debug('Error updating record with Id: ' + saveRest.getId() + '. Error message: ' + err.getMessage());
                    }
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        sendFinishedEmail();
    }
    private void sendFinishedEmail() {
        User adminUser = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        if (adminUser != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { adminUser.Email });
            mail.setSubject('Job Application Batch Process Completed');
            mail.setPlainTextBody('The batch process for closing old job applications has completed.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}


// see the class ScheduleJobApplicationBatch (implements Schedulable) to see how this class is made schedulable
//the above class cleans up (closes) Job app records that have been left open in which the follow up field is 30 days or over & then sends email to Admin
//to run this apex anon. enter the following two lines: 
//JobApplicationBatch batch = new JobApplicationBatch();
    //Database.executeBatch(batch);