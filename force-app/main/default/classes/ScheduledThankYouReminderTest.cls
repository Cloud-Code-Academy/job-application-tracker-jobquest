@isTest
private class ScheduledThankYouReminderTest {
    @isTest
    
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        //creating a user to help test the methods below
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

    @IsTest
    static void testScheduledThankYouReminder() {
        // Prepare the test user and event data
        User testUser = createTestUser();
        Job_Application__c testJob = new Job_Application__c(Job_Title__c = 'Dev');
        insert testJob;

        DateTime todayAt9AM = DateTime.newInstance(System.today(), Time.newInstance(9, 0, 0, 0));   
        DateTime todayAt10AM = todayAt9AM.addHours(1);

        Event testEvent = new Event(
            Subject = 'Job Interview',
            StartDateTime = todayAt9AM,
            EndDateTime = todayAt10AM,
            Name_or_Names_of_Interviewer__c = 'Test Interviewer',
            WhatId = testJob.Id,
            OwnerId = testUser.Id);
        insert testEvent;

        Test.startTest();
        ScheduledThankYouReminder reminder = new ScheduledThankYouReminder();
        reminder.execute(null);
        System.assertEquals(1, Limits.getEmailInvocations(), 'Expected 1 thank-you email to be sent');
        Test.stopTest();
    }
}