public class InterviewEmailReminder {
    public static void InterviewEmailReminderMethod() {   //this goes through all the events & searches for an interview taking place the next day
        Date dayAfter = System.Today().addDays(1);
        
        Event[] scheduledInterviewList = [SELECT Id, Subject, StartDateTime, EndDateTime, WhatId, Name_or_Names_of_Interviewer__c, Job_Application__c
                                        FROM Event 
                                        WHERE Subject = 'Job Interview' 
                                        AND DAY_ONLY(StartDateTime) = :dayAfter];
                  
                                                        
                                                        
        if(!scheduledInterviewList.isEmpty()){
            EmailHelper.EmailHelperMethod(scheduledInterviewList);//email Helper sends the reminder email
        }
    }   
    public static void ThankYouNoteReminderMethod() {
        Date today = System.Today();                         //this looks for interviews scheduled the same day and sends a reminder to send the thank you email (template in org)
        
        Event[] concludedInterviewList = [SELECT Id, Subject, StartDateTime, EndDateTime, WhatId, Name_or_Names_of_Interviewer__c, Job_Application__c
                                          FROM Event 
                                          WHERE Subject = 'Job Interview' 
                                          AND DAY_ONLY(StartDateTime) = :today];
                  
        if(concludedInterviewList != null)
            EmailHelper.ThankYouEmailHelperMethod(concludedInterviewList);  //the email helper is called to send the email
    }        
}     
