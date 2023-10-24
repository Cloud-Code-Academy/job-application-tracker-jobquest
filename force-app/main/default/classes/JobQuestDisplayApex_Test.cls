@isTest
public with sharing class JobQuestDisplayApex_Test {
   
        @isTest static void testGetJobApplications() {
        Account testCo = new Account(Name = 'Test Co');
        insert testCo;
        List<Job_Application__c> applications = new List<Job_Application__c>();
        for(Integer i=0; i<5; i++) {
            applications.add(new Job_Application__c(
                Job_Title__c = 'Test Job ',
                Listing_Pay__c = '10000' + i,
                Salary__c = 10000,
                Employer__c = 'Test Co',
                Company__c = testco.Id));
        }
        insert applications;
        
        Test.startTest();
        
        List<Job_Application__c> returnedApplications = JobQuestDisplayApex.getJobApplications();
        
        Test.stopTest();
        
        System.assertEquals(5, returnedApplications.size(), 'Expected 5 job applications to be returned.');
    }

    @isTest static void testDeleteJobApplication() {
        Account testCo = new Account(Name = 'Test Co');
        insert testCo;
        List<Job_Application__c> application = new List<Job_Application__c>();
        for(Integer i=0; i<1; i++) {
            application.add(new Job_Application__c(
                Job_Title__c = 'Test Job ',
                Listing_Pay__c = '10000' + i,
                Salary__c = 10000,
                Employer__c = 'Test Co',
                Company__c = testco.Id));
        }
        insert application;
        
        
        Test.startTest();
        
        JobQuestDisplayApex.deleteJobApplication(application);
        
        Test.stopTest();
        
        Job_Application__c deletedApp = [SELECT Id FROM Job_Application__c WHERE Id = :application.Id LIMIT 1];
        System.assert(deletedApp == null, 'The job application should be deleted.');
    }
}
