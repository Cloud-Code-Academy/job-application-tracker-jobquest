@isTest
public with sharing class JobQuestDisplayApex_Test {  //this tests the apex part of the LWC JobQuestDisplay, does it return the right amount of job applications?
   
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
        
    Assert.areEqual(5, returnedApplications.size(), 'Expected 5 job applications to be returned.');
    }
}

   