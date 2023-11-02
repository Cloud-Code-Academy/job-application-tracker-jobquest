@isTest
private class GeneralEmailClassForExceptions_Test {

    @isTest static void testSendExceptionEmail() {
        Test.startTest();

        try {
            // Force an exception to occur, you can't divide by 0 in apex without getting an exception
            Integer i = 0;
            Integer result = 10 / i;
        } catch (Exception except) {
            GeneralEmailClassForExceptions.sendExceptionEmailtest('Test Exception', except);
            System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');  //test would not pass until I put assertion before Test.stopTest
        }
        Test.stopTest();
    }
}
