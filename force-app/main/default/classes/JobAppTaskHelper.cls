//This is a number of helper methods
// collection of applications, note s on configureTasks, the earlier tasks use the plural method because it is more likely many applications could be given at once at these status levels
public with sharing class JobAppTaskHelper {
    public static void configureTasks(List<Task> tasksToInsert, List<Job_Application__c> jobApplications, String taskSubject, Integer daysToAdd) {     
        for(Job_Application__c jobApp : jobApplications) {
            Task newTask = new Task(); 
            newTask.WhatId = jobApp.Id;
            newTask.ActivityDate = Date.Today().addDays(daysToAdd);
            newTask.Priority = 'High';
            newTask.OwnerId = jobApp.OwnerId; 
            newTask.Subject = taskSubject;
            newTask.Status = 'Not Started';
            tasksToInsert.add(newTask);
        }
    }

   // single job application (no s)
    public static void configureTask(List<Task> tasksToInsert, Id jobId, Id jobOwnerId, String taskSubject, Integer daysToAdd) {     
        Task newTask = new Task();
        newTask.WhatId = jobId;
        newTask.ActivityDate = Date.Today().addDays(daysToAdd);
        newTask.Priority = 'High';  //I set every task as High priority. User can change it but these tasks are high priority if one wants to get a job
        newTask.OwnerId = jobOwnerId;
        newTask.Subject = taskSubject;
        newTask.Status = 'Not Started';
        tasksToInsert.add(newTask);
    }

    public static List<Task> handleInsertedJobs(Map<Id, Job_Application__c> newJobMap, List<Task> tasksToInsert) { //inserted jobs
        taskDetails(newJobMap.values(), tasksToInsert);
        return tasksToInsert;
    }
    
    public static List<Task> handleUpdatedJobs(Map<Id, Job_Application__c> statusChangedMap, List<Task> tasksToInsert) {  //uses statusChangedMap for Updated jobs
        taskDetails(statusChangedMap.values(), tasksToInsert);
        return tasksToInsert;
    }
    
    public static void taskDetails(List<Job_Application__c> jobs, List<Task> tasksToInsert) {  //for inserting 
        for(Job_Application__c job : jobs) {
            Id jobId = job.Id;
            Id jobOwnerId = job.OwnerId;
            List<Job_Application__c> jobList = new List<Job_Application__c>{ job }; // Creating a list for a single job
            
            switch on job.Status__c {   //I like using the Subject for the task because sometimes I need to see everything there and not have to click again to read more
                when 'Saved' {    //saved and applying are much likely to have several job applications entered at one time, so I gave them the plural version of configureTasks
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    configureTasks(tasksToInsert, singleJobList, 'Check if the job description aligns with your interests and values', 1);
                    configureTasks(tasksToInsert, singleJobList, 'Review the highlighted skills to see if the role is a good fit', 1);
                    configureTasks(tasksToInsert, singleJobList, 'Research the company or role and mark your excitement level', 4);
                }
                when 'Applying' {
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    configureTasks(tasksToInsert, singleJobList, 'Find and research someone who works at the company and add them as a contact', 3);
                    configureTasks(tasksToInsert, singleJobList, 'Set up an informational interview to learn more about the role/company', 3);
                    configureTasks(tasksToInsert, singleJobList, 'Identify potential referrals to help get your application on the top of the pile', 1);
                    configureTasks(tasksToInsert, singleJobList, 'Customize your work achievements using the job description keywords', 2);
                    configureTasks(tasksToInsert, singleJobList, 'Submit your application on the company website if possible', 4);
                }
                
                when 'Applied' {
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Reach out to the hiring manager or recruiter', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Follow up on your application via email weekly', 7);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Continue identifying and saving similar job opportunities', 7);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up weekly networking calls to explore similar companies/roles', 7); 
                }
                when 'Interviewing' {
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your blurb or "tell me about yourself" response', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Practice answering behavioral interview questions', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research the company and your interviewers', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up your virtual interview space and test your tech', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Post Interview: Send thank you emails within 24 hours (you should receive a reminder email)', 1); 
                }
                when 'Negotiating' {
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research your market value and know your numbers', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your negotiation scripts', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Evaluate your offer and decline or accept', 3);
                }
                when 'Accepted' {
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Plan your resignation if applicable', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Take some time to relax and recharge', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare for your first day of onboarding', 14);
                }

                when 'Closed'{
                    List<Job_Application__c> singleJobList = new List<Job_Application__c>{ job };
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Prepare template and send a follow-up email thanking the interviewer and asking for feedback', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Review your notes and reflect on areas of improvement', 12);
                    }
                }
            }
    }
}
