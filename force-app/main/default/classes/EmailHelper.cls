public class EmailHelper {
    public static Boolean emailSent = false;   //can also be used in testing

    public static void EmailHelperMethod (List<Event> scheduledInterviewList) {
        emailSent = false; 

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Event interview : scheduledInterviewList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'lisamhackler@gmail.com'});
            mail.setSubject('Tomorrow is a big day! Are you ready for a ' + interview.Subject);
            String body = 'You have an interview scheduled on ' + interview.StartDateTime.format();
            
            if(interview.Name_or_Names_of_Interviewer__c != null) {
                body += '\nInterviewer(s): ' + interview.Name_or_Names_of_Interviewer__c;
            }
            
            if(interview.Job_Application__c != null) {
                body += '\nJob Application: ' + interview.Job_Application__c;
            }
            
            mail.setPlainTextBody(body);
            emailsToSend.add(mail);
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
            emailSent = true; 
        }
    }
}

             