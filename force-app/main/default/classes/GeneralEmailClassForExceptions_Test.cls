@isTest
private class GeneralEmailClassForExceptions_Test {
//I tested so much I ran into my limit for emails, so I was unable to test this properly, therefore I commented out the code that used it and used system.debug until I can properly test more
    @isTest static void testSendExceptionEmail() {
        Test.startTest();

        try {
            // Force an exception to occur, you can't divide by 0 in apex without getting an exception
            Integer i = 0;
            Integer result = 10 / i;
        } catch (Exception except) {
            GeneralEmailClassForExceptions.sendExceptionEmailtest('Test Exception', except);
        }

        Test.stopTest();
        
     
        System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');
    }
}
