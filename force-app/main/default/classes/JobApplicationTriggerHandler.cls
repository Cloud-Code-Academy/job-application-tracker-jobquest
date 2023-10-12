public with sharing class JobApplicationTriggerHandler extends TriggerHandler {
    private List<Job_Application__c>newJobList;
    private Map<Id, Job_Application__c>newJobMap;
    private List<Job_Application__c>oldJobList;
    private Map<Id, Job_Application__c>oldJobMap;

    public JobApplicationTriggerHandler() {
        this.newJobList = (List<Job_Application__c>)Trigger.new;
        this.newJobMap = (Map<Id, Job_Application__c>)Trigger.newMap;
        this.oldJobList = (List<Job_Application__c>)Trigger.old;
        this.oldJobMap = (Map<Id, Job_Application__c>)Trigger.oldMap;

    }
    // public override void beforeInsert() {

    // }
        
    // public override void beforeUpdate() {

    // }

    // public override void beforeDelete () {

    // }

    public override void afterInsert () {
        List<Task> tasksToInsert = new List<Task>();
        for (Job_Application__c job : this.newJobMap.values()) {
            job = newJobMap.get(job.Id);
            Id jobId = job.Id;
            Id jobOwnerId = job.OwnerId;
           
            switch on job.Status__c {
                when 'Saved' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Check if the job description aligns with your interests and values', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Review the highlighted skills to see if the role is a good fit', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Research the company or role and mark your excitement level', 4);
                }
                when 'Applying' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Find and research someone who works at the company and add them as a contact', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Set up an informational interview to learn more about the role/company', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Identify potential referrals to help get your application on the top of the pile', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Customize your work achievements using the job description keywords', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Submit your application on the company website if possible', 4);
                }
                when 'Applied' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Reach out to the hiring manager or recruiter', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Follow up on your application via email weekly', 7);//don't forget reoccurring?
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Continue identifying and saving similar job opportunities', 7); //dont forget reoccuring???
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up weekly networking calls to explore similar companies/roles', 7);  //reoccuring??
                }
                when 'Interviewing' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your blurb or "tell me about yourself" response', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Practice answering behavioral interview questions', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research the company and your interviewers', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up your virtual interview space and test your tech', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up reminder & template to send thank you emails within 24 hours', 1); //set up reminder email?
                }
                when 'Negotiating' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research your market value and know your numbers', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your negotiation scripts', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Evaluate your offer and decline or accept', 3);
                }
                when 'Accepted' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Plan your resignation if applicable', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Take some time to relax and recharge', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare for your first day of onboarding', 14);
                }
                when else {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Prepare template and send a follow-up email thanking the interviewer and asking for feedback', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Review your notes and reflect on areas of improvement', 12);
                }
            }
        }
    insert tasksToInsert;
    }
    
    public override void afterUpdate() {
        List<Task> tasksToInsert = new List<Task>();
        Map<Id, Job_Application__c> statusChangedMap = new Map<Id, Job_Application__c>();
        // for (Job_Application__c job : this.newJobMap.values()) {
        //     for (Job_Application__c jobOld : this.oldJobMap.values()){
        //         if(job.status__c != jobOld.status__c){
        //             statusChangedMap.put(job.Id, job);
        //         }
        //     }
        // } 
        for (Job_Application__c job : this.newJobMap.values()) {
            Job_Application__c oldJob = this.oldJobMap.get(job.Id);
            if (oldJob != null && job.status__c != oldJob.status__c) {
                statusChangedMap.put(job.Id, job);
            }
        }
        for (Job_Application__c job : statusChangedMap.values()) {
            job = statusChangedMap.get(job.Id);
            Id jobId = job.Id;
            Id jobOwnerId = job.OwnerId;
           
            switch on job.Status__c {
                when 'Saved' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Check if the job description aligns with your interests and values', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Review the highlighted skills to see if the role is a good fit', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Research the company or role and mark your excitement level', 4);
                }
                when 'Applying' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Find and research someone who works at the company and add them as a contact', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Set up an informational interview to learn more about the role/company', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Identify potential referrals to help get your application on the top of the pile', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Customize your work achievements using the job description keywords', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Submit your application on the company website if possible', 4);
                }
                when 'Applied' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Reach out to the hiring manager or recruiter', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Follow up on your application via email weekly', 7);//don't forget reoccurring?
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Continue identifying and saving similar job opportunities', 7); //dont forget reoccuring???
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up weekly networking calls to explore similar companies/roles', 7);  //reoccuring??
                }
                when 'Interviewing' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your blurb or "tell me about yourself" response', 3);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Practice answering behavioral interview questions', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research the company and your interviewers', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up your virtual interview space and test your tech', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Set up reminder & template to send thank you emails within 24 hours', 1); //set up reminder email?
                }
                when 'Negotiating' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Research your market value and know your numbers', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare your negotiation scripts', 2);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Evaluate your offer and decline or accept', 3);
                }
                when 'Accepted' {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Plan your resignation if applicable', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Take some time to relax and recharge', 5);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId,'Prepare for your first day of onboarding', 14);
                }
                when else {
                    Task newTask = new Task();
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Prepare template and send a follow-up email thanking the interviewer and asking for feedback', 1);
                    JobAppTaskHelper.configureTask(tasksToInsert, jobId, jobOwnerId, 'Review your notes and reflect on areas of improvement', 12);
                }
            }
        }
    insert tasksToInsert;
    }
    // public override void afterDelete () {

    // }

    // public override void afterUndelete () {


    // }




}
