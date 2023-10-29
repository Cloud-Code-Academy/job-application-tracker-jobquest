public with sharing class JobQuestDisplayApex {
    @AuraEnabled(cacheable=true)
    public static List<Job_Application__c> getJobApplications() {  //this returns a list of job Applications that are in Salesforce
        return [SELECT Job_Title__c, Id, Listing_Pay__c, Salary__c, Employer__c, Company__r.Name, Follow_up_Date__c 
                FROM Job_Application__c];
    }
    @AuraEnabled
    public static void deleteJobApplication(String jobId) {   //this deletes Job Applications that have the same Jooble Id.
    delete new Job_Application__c(Id = jobId);
    }
}
