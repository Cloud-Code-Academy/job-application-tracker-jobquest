@isTest
private class GeneralEmailClassForExceptions_Test {

    @isTest static void testSendExceptionEmail() {
        Test.startTest();

        try {
            // Force an exception to occur
            Integer i = 0;
            Integer result = 10 / i;
        } catch (Exception except) {
            GeneralEmailClassForExceptions.sendExceptionEmailtest('Test Exception', except);
        }

        Test.stopTest();
        
     
        System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');
    }
}
