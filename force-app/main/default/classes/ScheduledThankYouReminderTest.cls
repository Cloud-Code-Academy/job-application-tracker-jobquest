@isTest
private class ScheduledThankYouReminderTest {
    @isTest
    
     private static User createTestUser() {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
    //creating a user to help test the method below
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
           
            User testUser = createTestUser();
            
            List<Event> scheduledInterviewList = new List<Event>();
            scheduledInterviewList.add(new Event(
                Subject = 'Interview ',
                StartDateTime = DateTime.now().addHours(6).addDays(1),
                EndDateTime = DateTime.now().addHours(6).addDays(1), 
                Name_or_Names_of_Interviewer__c = 'Holly Peak',
                Job_Application__c = 'a00Hs000018qLdoIAE', 
                OwnerId = testUser.Id
            ));
        
        insert scheduledInterviewList;

            
        ScheduledThankYouReminder reminder = new ScheduledThankYouReminder();
        String cron = '0 0 17 * * ?';
        
        Test.startTest();
        
        
        //System.schedule('Test_ScheduledThankYouReminder', cron, reminder);
        
        String cronExp = '0 0 18 * * ?';  // This represents 6 pm every day
        System.schedule('ThankYouNoteReminderJob', cronExp, reminder);
        System.assertEquals(1, Limits.getEmailInvocations(), '1 thank-you email should be sent');
        Test.stopTest();
            
        System.assertEquals(1, Limits.getEmailInvocations(), '1 thank-you email should be sent');   
           
    }
}    
    
    
    
    
    
    