public class EmailHelper {
    public static Boolean emailSent = false;

    public static void EmailHelperMethod (List<Event> scheduledInterviewList) {
        emailSent = false; 

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for (Event interview : scheduledInterviewList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'testemail@example.com'});  
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
            try {
                Messaging.sendEmail(emailsToSend);
                emailSent = true; 
            } catch (Exception e) {
                throw new EmailException('Failed to send email: ' + e.getMessage());
            }
        }
    }

    public static void ThankYouEmailHelperMethod(List<Event> interviews) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Event event : interviews) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'testemail@example.com'});  
            mail.setSubject('Reminder: Send Your Thank-You Note');
            mail.setPlainTextBody('Just a friendly reminder to send a thank-you note following your interview earlier today.');
            mails.add(mail);
        }
        
        if(mails.size() > 0) {
            try {
                Messaging.sendEmail(mails);
            } catch (Exception e) {
                throw new EmailException('Failed to send thank you email: ' + e.getMessage());
            }
        }
    }

    public class EmailException extends Exception {}
}
