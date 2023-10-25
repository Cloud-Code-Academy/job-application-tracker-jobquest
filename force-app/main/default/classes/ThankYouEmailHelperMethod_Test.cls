@isTest
private class ThankYouEmailHelperMethod_Test {   

    @isTest
    static user makeUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        //creating a user 
        User user = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + DateTime.now().getTime() + '@test.com' 
        );
        insert user;
        return user;

        
    }
    

    @isTest
    static void testThankYouEmailHelperMethod() {
    Job_Application__c testJob = new Job_Application__c(Job_Title__c = 'Dev 999');
    insert testJob;
   
    ThankYouEmailHelperMethod_Test.makeUser();
    User user = [SELECT Id FROM User WHERE LastName = 'Test' LIMIT 1];
    testJob = [SELECT Id FROM Job_Application__c WHERE Job_Title__c = 'Dev 999' LIMIT 1];

    DateTime now = System.now();
    DateTime endOfInterview = now.addHours(1); 

    
    List<Event> concludedInterviewList = new List<Event>();  

    Event jobInterview = new Event(
    Subject = 'Job Interview',
    WhatId = testJob.Id, 
    StartDateTime = now,
    EndDateTime = endOfInterview,
    OwnerId = user.Id 
    );

    concludedInterviewList.add(jobInterview); 

    Test.startTest();

    EmailHelper.ThankYouEmailHelperMethod(concludedInterviewList);

    System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');

    Test.stopTest();
    }
}
        
       