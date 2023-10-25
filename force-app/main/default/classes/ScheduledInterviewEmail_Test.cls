@isTest
public with sharing class ScheduledInterviewEmail_Test {

    private static User anotherTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        // Creating a user to help test the methods below
        User user = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'testuser' + DateTime.now().getTime() + '@test.com'
        );
        insert user;
        return user;
    }

    @isTest 
    static void ScheduledInterviewEmailReminderTest() {
        // Create test data
        User user = anotherTestUser();
        Job_Application__c testJob = new Job_Application__c(Job_Title__c = 'Dev');
        insert testJob;
    
        // Schedule an event for the next day with the Subject 'Job Interview'
        List<Event> scheduledInterviewList = new List<Event>();
        scheduledInterviewList.add(new Event(
            Subject = 'Job Interview',
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(1).addHours(1),
            Name_or_Names_of_Interviewer__c = 'Test Interviewer',
            WhatId = testJob.Id,
            OwnerId = user.Id
        ));
        insert scheduledInterviewList;
        System.debug(scheduledInterviewList);
        EmailHelper.EmailHelperMethod(scheduledInterviewList);
        // Directly invoke the scheduled job's logic 
        ScheduledInterviewEmail reminder = new ScheduledInterviewEmail();
        
        Test.startTest();
        reminder.execute(null); 
        Test.stopTest();
        System.debug('Email Sent Count: ' + Limits.getEmailInvocations());
        // Assert that an email was sent
        Integer emailSentCount = Limits.getEmailInvocations();
        System.assertEquals(1, emailSentCount, 'Expected 1 reminder email to be sent');
    }
}
