public class JobApplicationTriggerHandler extends TriggerHandler {
    public static Boolean isTriggerRunning = false;  //to avoid recursion

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
    public override void beforeInsert() {
        // The code below calculates estimated take home pay when a salary is inserted
        for (Job_Application__c newJobApp : this.newJobList) {
            if(newJobApp.Salary__c != null) {
                Boolean isSingle = (newJobApp.Single_or_Married_filing_Jointly__c == 'Filing Single');
                new JobApplicationTriggerHandlerHelper2(newJobApp, isSingle);
            }
        }
    }
    //The trigger below checks for job application records without primary contacts before updates. 
    //Then assigns the null fields a contact related to the company of the job application. 
    //The decision was made not to use the Contact-Application Assoc. object for this as it is a look up to the same object.
    public override void beforeUpdate() {   //note Primary Contact is only assigned before Update (not before Insert), this is to give user more time to manually assign a primary contact
        Set<Id> setJobId = new Set<Id>();
        Map<Id,Id> jobAccountIdMap = new Map<Id,Id>();
        for(Job_Application__c job : newJobMap.values()){   //trigger.newMap
            if (job.Primary_Contact__c == null && job.Company__c != null) {
                setJobId.add(job.Id);
                jobAccountIdMap.put(job.Id, job.Company__c);  //note: here we store the job app Id as key, and the job app AccountId is stored on the field (lookup field) Company__c
            }
        }
        if(!setJobId.isEmpty()) {
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
            for(Contact contact : [ SELECT Id, AccountId 
                                    FROM Contact 
                                    WHERE AccountId 
                                    IN :jobAccountIdMap.values() //we look for contacts with Account Ids that match the Company__c (Account Id) in Job Applications
                                    ORDER BY AccountId 
                                    LIMIT 1]) {   //note limit one
                contactsMap.put(contact.AccountId, contact);  
            }

            for(Job_Application__c job : newJobMap.values()){   //trigger.newMap
                if(setJobId.contains(job.Id) && contactsMap.containsKey(job.Company__c)) {   //remember the contactsMap key is the account Id
                    job.Primary_Contact__c = contactsMap.get(job.Company__c).Id; //here we set the Primary Contact field , by getting the Id of the contact that has the matching AccountId
                }
            }
        }
        // The code below calculates estimated take home pay when a salary is updated. 
        for (Job_Application__c newJobApp : this.newJobMap.values()) {
        Job_Application__c oldJobApp = this.oldJobMap.get(newJobApp.Id); //this.oldJobMap is trigger.oldMap
        if(oldJobApp.Salary__c == null || newJobApp.Salary__c != oldJobApp.Salary__c) {   
            Boolean isSingle = (newJobApp.Single_or_Married_filing_Jointly__c == 'Filing Single');
            new JobApplicationTriggerHandlerHelper2(newJobApp, isSingle);
        }
    }
    }
    public override void afterInsert() {
        if (isTriggerRunning) {
            return;
        }  //this means if the trigger is already running (set to true) it will exit this method

        isTriggerRunning = true; //if not already running, set to true
        try {
            List<Task> tasksToInsert = JobAppTaskHelper.handleInsertedJobs(this.newJobMap, new List<Task>());
                insert tasksToInsert;
        } 
        catch (Exception except) {
            GeneralEmailClassForExceptions.sendExceptionEmailtest('Error in Job Application Trigger Handler:', except);
        } 
        finally {
            isTriggerRunning = false;  //no matter what, ifTriggerRunning will be set to false at this point
        }
    }

    public override void afterUpdate() {
    if (isTriggerRunning) { 
        return;  //exit if already running
    }
    isTriggerRunning = true; //if false, set it to true
    try {
        List<Task> tasksToInsert = new List<Task>();
        Map<Id, Job_Application__c> statusChangedMap = getStatusChangedJobs();  //this method is described below 
        
        tasksToInsert.addAll(JobAppTaskHelper.handleUpdatedJobs(statusChangedMap, new List<Task>()));

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    } 
    catch (Exception except) {
        GeneralEmailClassForExceptions.sendExceptionEmailtest('Error in Job Application Trigger Handler:', except);  
    } 
    finally {
        isTriggerRunning = false;  //trigger is reset to false
    }
    }
    private Map<Id, Job_Application__c> getStatusChangedJobs() {
    Map<Id, Job_Application__c> statusChangedMap = new Map<Id, Job_Application__c>();
    for (Job_Application__c job : this.newJobList) {
        Job_Application__c oldJob = this.oldJobMap.get(job.Id);  //this.oldJobMap corresponds to trigger.oldMap
        if (oldJob != null && job.Status__c != oldJob.Status__c) {   //since we don't want a recursive trigger we are checking to make sure the status has actually changed.
            statusChangedMap.put(job.Id, job);
        }
    }
    return statusChangedMap;
    }
}