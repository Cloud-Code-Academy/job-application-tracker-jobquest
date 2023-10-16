public class InterviewEmailReminder {
    public static void InterviewEmailReminderMethod() {
        Date dayAfter = System.Today().addDays(1);
        
        Event[] scheduledInterviewList = [SELECT Id, Subject, StartDateTime, EndDateTime, WhatId, Name_or_Names_of_Interviewer__c, Job_Application__c
                                        FROM Event 
                                        WHERE Subject = 'Job Interview' 
                                        AND DAY_ONLY(StartDateTime) = :dayAfter];
                  
                                                        
                                                        
        if(scheduledInterviewList != null)
            EmailHelper.EmailHelperMethod(scheduledInterviewList);
    }        
}
