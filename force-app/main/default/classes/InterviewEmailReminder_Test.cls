@isTest
private class InterviewEmailReminder_Test {
    
    @isTest static void testInterviewEmailReminder() {
        Job_Application__c testJob = new Job_Application__c(Job_Title__c = 'Dev');
        insert testJob;

        DateTime tomorrowAt9AM = DateTime.newInstance(System.today().addDays(1), Time.newInstance(9, 0, 0, 0));
        DateTime tomorrowAt10AM = tomorrowAt9AM.addHours(1);

        Event testEvent = new Event(
            Subject = 'Job Interview',
            StartDateTime = tomorrowAt9AM,
            EndDateTime = tomorrowAt10AM,
            Name_or_Names_of_Interviewer__c = 'Test Interviewer',
            WhatId = testJob.Id
        );
        insert testEvent;
        
        Test.startTest();
        InterviewEmailReminder.InterviewEmailReminderMethod();
        Test.stopTest();
        
        System.assert(EmailHelper.emailSent, 'Expected an email to be sent.');
    }
}