public with sharing class GeneralEmailClassForExceptions {
    
    public static void sendExceptionEmailtest (String subject, Exception except) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { 'lisamhackler@gmail.com' });  //this would be replaced by an org email for admins, not hardcoded
        mail.setSubject(subject);
        mail.setPlainTextBody('An error occurred: ' + except.getMessage() + '\n\nStack Trace:\n' + except.getStackTraceString());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}