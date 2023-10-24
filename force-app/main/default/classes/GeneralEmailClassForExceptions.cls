public with sharing class GeneralEmailClassForExceptions {
    
    public static void sendExceptionEmailtest (String subject, Exception except) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { 'test@example.com' });  //this would be replaced by method to get the email of the appropriate role.  I used my own email to test it.
        mail.setSubject(subject);
        mail.setPlainTextBody('An error occurred: ' + except.getMessage() + '\n\nStack Trace:\n' + except.getStackTraceString());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}