public class EmailHelper {
    public static Boolean emailSent = false;

    public static void EmailHelperMethod (List<Event> scheduledInterviewList) {
        emailSent = false; 

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        //reminder that the next day a job interview is scheduled
        for (Event interview : scheduledInterviewList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'testemail@example.com'});   //to test I put a different email (to admin)
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
                System.debug('Preparing to send email...');
                Messaging.sendEmail(emailsToSend);
                emailSent = true; 
                System.debug('Email sent.');
            } catch (Exception except) {
                System.debug('Error sending email: ' + except.getMessage());
                throw new EmailException('Failed to send email: ' + except.getMessage());
            }
        }
    }

    public static void ThankYouEmailHelperMethod(List<Event> interviews) {   //sends reminder to send thank you within 24 hrs.
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Event event : interviews) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'testemail@example.com'});  //to test I put a different email in 
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
