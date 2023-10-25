@isTest
private class ThankYouEmailHelperMethod_Test {   //this method is also tested in the EmailHelper test

    @isTest
    static void testThankYouEmailHelperMethod() {
    // Get today's date and time
    DateTime now = System.now();
    DateTime endOfInterview = now.addHours(1); 

    // Create a list of Events
    List<Event> concludedInterviewList = new List<Event>();

    Event jobInterview = new Event(
    Subject = 'Job Interview',
    WhatId = 'a00Hs000018qM6gIAE', // This should ideally not be hardcoded, but it is just a fake test, and I didn't want to have to do a SOQL to get jobApp Id and owner Id
    StartDateTime = now,
    EndDateTime = endOfInterview,
    OwnerId = '005Hs00000DtiS8IAJ' // This should ideally not be hardcoded, but it is just a fake test, and there are limits to DML and SOQL statements
    );

    concludedInterviewList.add(jobInterview); 

    Test.startTest();

    EmailHelper.ThankYouEmailHelperMethod(concludedInterviewList);

    System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');

    Test.stopTest();
    }
}
        
       