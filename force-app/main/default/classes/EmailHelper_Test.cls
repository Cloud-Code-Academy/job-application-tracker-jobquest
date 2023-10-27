@IsTest(SeeAllData=false)
private class EmailHelper_Test {       //creating a user to help test the methods below
    private static User createTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
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

    @IsTest
    static void testEmailHelperMethod() {   //this tests the method to remind user of upcoming job interview the day before   
        EmailHelper.emailSent = false;
        User testUser = createTestUser();
        Job_Application__c jobAp = new Job_Application__c(Job_Title__c = 'Salesforce Dev');
        insert jobAp;
        List<Event> scheduledInterviewList = new List<Event>();
            scheduledInterviewList.add(new Event(
                Subject = 'Interview ',
                StartDateTime = DateTime.now().addDays(1),
                EndDateTime = DateTime.now().addDays(1),
                Name_or_Names_of_Interviewer__c = 'Holly Peak',
                Job_Application__c = jobAp.Id,
                OwnerId = testUser.Id
            ));
        
        insert scheduledInterviewList;
        Test.startTest();
        EmailHelper.EmailHelperMethod(scheduledInterviewList);
        Assert.areEqual(true, EmailHelper.emailSent, 'Email should be sent');
        Assert.areEqual(1, Limits.getEmailInvocations(), 'One reminder email should be sent');
        Test.stopTest();
    }
    
    @IsTest
    static void testThankYouEmailHelperMethod() {//this tests the method of sending a reminder to thank interviewers via email within 24 hrs.  
        User testUser = createTestUser();
        Job_Application__c jobAp = new Job_Application__c(Job_Title__c = 'Salesforce Dev');
        insert jobAp;
        List<Event> scheduledInterviewList = new List<Event>();
            scheduledInterviewList.add(new Event(
                Subject = 'Interview ',
                StartDateTime = DateTime.now().addHours(6).addDays(1),
                EndDateTime = DateTime.now().addHours(6).addDays(1), 
                Name_or_Names_of_Interviewer__c = 'Holly Peak',
                Job_Application__c = jobAp.Id,
                OwnerId = testUser.Id));
        insert scheduledInterviewList;
        Test.startTest();
        EmailHelper.ThankYouEmailHelperMethod(scheduledInterviewList);
        Assert.areEqual(1, Limits.getEmailInvocations(), '1 thank-you email should be sent');  
        Test.stopTest();
    }
}