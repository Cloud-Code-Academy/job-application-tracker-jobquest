global class JobApplicationBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date aMonthAgo = Date.today().addDays(-30); 
        // query will ask for  <= :aMonthAgo so it will be 30 days or more 
        String query = 'SELECT Id, Status__c, Notes__c FROM Job_Application__c WHERE Follow_up_Date__c <= :aMonthAgo AND (Status__c != \'Accepted\' AND Status__c != \'Closed\')';
        return Database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Job_Application__c> applicationsToUpdate = new List<Job_Application__c>();
        for (sObject sc : scope) {
            Job_Application__c application = (Job_Application__c) sc;
            application.Status__c = 'Closed';
            application.Notes__c = 'This job application was closed by an automated process.';
            applicationsToUpdate.add(application);
        }
        if(applicationsToUpdate.size() > 0) {
            update applicationsToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {
        sendFinishedEmail();
    }
    private void sendFinishedEmail() {
        // Fetch System Admin's email. This assumes there's only one System Admin or sends to the first one found.
        User adminUser = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        if(adminUser != null) {
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