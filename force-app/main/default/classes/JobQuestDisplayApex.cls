public with sharing class JobQuestDisplayApex {
    @AuraEnabled(cacheable=true)
    public static List<Job_Application__c> getJobApplications() {
        return [SELECT Job_Title__c, Id, Listing_Pay__c, Salary__c, Employer__c, Company__r.Name, Follow_up_Date__c 
                FROM Job_Application__c];
    }
    @AuraEnabled
    public static void deleteJobApplication(String jobId) {
    delete new Job_Application__c(Id = jobId);
}

}
