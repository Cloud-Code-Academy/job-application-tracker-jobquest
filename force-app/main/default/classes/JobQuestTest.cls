@isTest
public with sharing class JobQuestTest {
    @isTest
    static void testJobApplicationTrigger_takeHomePayBeforeInsert(){
        Job_Application__c[] jobAppList = new Job_Application__c[]{};
        Job_Application__c jobNull = new Job_Application__c(
            Job_Title__c = 'Salesforce Dev'
        ); 
        jobAppList.add(jobNull);
        Job_Application__c jobSalary = new Job_Application__c(
            Job_Title__c = 'Jr. Salesforce Dev',
            Salary__c = 65000
        ); 
        jobAppList.add(jobSalary);
        insert jobAppList;
        List<Id> insertedIds = new List<Id>();
            for(Job_Application__c jobApp : jobAppList) {
                insertedIds.add(jobApp.Id);
            }  
        List<Job_Application__c> takeHomePayList = [SELECT Id, Take_Home_Pay__c, Estimated_Monthly_Paycheck__c 
                        FROM Job_Application__c
                        WHERE Id
                        IN: insertedIds];
                      

        Assert.areEqual(null, takeHomePayList[0].Estimated_Monthly_Paycheck__c, 'This field should be null'); //if the salary is null the estimated paycheck will be too
        System.assertEquals(4456, Math.round(takeHomePayList[1].Estimated_Monthly_Paycheck__c), 'This field should equal 4456'); //as long as it rounds right we're good, if this number is right - we can assume the annual number will be correct also
        Assert.areEqual(53467.00, takeHomePayList[1].Take_Home_Pay__c, 'Take_Home_Pay__c should equal 53467.00');//and it correct
    }

    @isTest
    static void testJobApplicationTrigger_setPrimaryContactBeforeUpdate() {
        //Create test data
        Account account = new Account(Name = 'Mirand');
        insert account;
        Contact con = new Contact(LastName = 'Connie', AccountId = account.Id);
        insert con;
        Job_Application__c job0 = new Job_Application__c(Job_Title__c = 'Salesforce Dev', Job_Rating__c = '2 - Fair'); //no company listed
        Job_Application__c job1 = new Job_Application__c(Job_Title__c = 'Jr Salesforce Dev', Company__c = account.Id);
        List<Job_Application__c> jobAppList = new List<Job_Application__c> { job0, job1 };
        
        insert jobAppList;
        update jobAppList;  //update calls trigger no need to call the method

        List<Job_Application__c> results = [SELECT Id, Company__c, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobAppList]; //query on job apps

        System.assertEquals(null, results[0].Primary_Contact__c, 'Primary_Contact__c field should remain null since there was no associated company.'); //assert that without a company app won't have a primary contact
        System.assertEquals(con.Id, results[1].Primary_Contact__c, 'Primary_Contact__c field should be set to the contact related to the account.'); //believing in my trigger lol, I assert that the Primary Contact field will have a contact assigned
    }

    @isTest
    static void testJobApplicationTrigger_takeHomePayBeforeUpdate(){
        Job_Application__c[] jobAppList = new Job_Application__c[]{};
        Job_Application__c jobNull = new Job_Application__c(
            Job_Title__c = 'Salesforce Dev'
        ); 
        jobAppList.add(jobNull);

        Job_Application__c jobSalary = new Job_Application__c(
            Job_Title__c = 'Jr. Salesforce Dev',
            Salary__c = 65000
        ); 
        jobAppList.add(jobSalary);
        insert jobAppList;
        List<Id> insertedIds = new List<Id>();
            for(Job_Application__c jobApp : jobAppList) {
                insertedIds.add(jobApp.Id);
            }  

        jobNull.Salary__c = 65000;
        jobSalary.Salary__c = 70000;
        update jobAppList;

        List<Job_Application__c> takeHomePayList = [SELECT Id, Take_Home_Pay__c, Estimated_Monthly_Paycheck__c 
                        FROM Job_Application__c
                        WHERE Id
                        IN: insertedIds];
                      
        Assert.areEqual(4456, Math.round(takeHomePayList[0].Estimated_Monthly_Paycheck__c), 'This field should equal 4456'); 
        System.assertEquals(4749, Math.round(takeHomePayList[1].Estimated_Monthly_Paycheck__c), 'This field should equal 4749'); 
        Assert.areEqual(53467.00, takeHomePayList[0].Take_Home_Pay__c, 'Take_Home_Pay__c should equal 53467.00');
        Assert.areEqual(56984.50, takeHomePayList[1].Take_Home_Pay__c, 'Take_Home_Pay__c should equal 56984.50');
    } 
    @isTest
    static void testJobApplicationTrigger_jobAppTaskHelperAfterInsert(){
        Job_Application__c[] jobAppList = new Job_Application__c[] {
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Saved'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applying'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applied'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Accepted'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Closed'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev')};//defaults to 'Saved'

        insert jobAppList;

        Map<Id, String> jobIdToStatus = new Map<Id, String>();

        for (Job_Application__c insertedJob : [SELECT Id, Status__c FROM Job_Application__c WHERE Id IN :jobAppList]) {
            jobIdToStatus.put(insertedJob.Id, insertedJob.Status__c);
        }
        List<Task> tasksForJobQuest = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId IN :jobIdToStatus.keySet()];
        Map<String, List<Task>> statusToTasks = new Map<String, List<Task>>();
        for (Task task : tasksForJobQuest) {
            String status = jobIdToStatus.get(task.WhatId);
                if (!statusToTasks.containsKey(status)) {
                    statusToTasks.put(status, new List<Task>());
                }
                statusToTasks.get(status).add(task);
            }
        List<Task> savedTasks = statusToTasks.get('Saved');
        Boolean foundExpectedTask = false;
        for (Task task : savedTasks) {
            if (task.Subject == 'Check if the job description aligns with your interests and values') {
                foundExpectedTask = true;
                break;
            }
        }
        System.assert(foundExpectedTask, 'Expected task subject not found for "Saved" status.');
        
        System.assertEquals(28, tasksForJobQuest.size(), 'Expected 28 tasks for the job applications');
        System.assertEquals(6, statusToTasks.get('Saved').size(), 'Expected 6 tasks (3 tasks twice) for Saved status.'); //counted the first "Saved" and the default "Saved" at the end.
        Assert.areEqual(5, statusToTasks.get('Applying').size(), 'Expected 5 tasks for Applying status');
        Assert.areEqual(4, statusToTasks.get('Applied').size(), 'Expected 4 tasks for Applied status');
        Assert.areEqual(5, statusToTasks.get('Interviewing').size(), 'Expected 5 tasks for Interviewing status');
        Assert.areEqual(3, statusToTasks.get('Negotiating').size(), 'Expected 3 tasks for Negotiating status');
        Assert.areEqual(3, statusToTasks.get('Accepted').size(), 'Expected 3 tasks for Accepted status');
        Assert.areEqual(2, statusToTasks.get('Closed').size(), 'Expected 2 tasks for Closed status');
      
    }
    @isTest
    static void testJobApplicationTrigger_jobAppTaskHelperAfterUpdate() {
    
        Job_Application__c[] jobAppList = new Job_Application__c[] {
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'),     
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating')
        };
        insert jobAppList;

        jobAppList[0].Status__c = 'Negotiating';
        jobAppList[1].Status__c = 'Accepted';
        update jobAppList;

        List<Task> tasksForJobQuest =   [SELECT Id, WhatId, Subject, Priority, Status 
                                        FROM Task 
                                        WHERE WhatId 
                                        IN :jobAppList];

        for (Task task : tasksForJobQuest) {
            if (task.WhatId == jobAppList[0].Id) { 
            Assert.isNotNull(task.Subject, 'The Subject should list a task');
            System.assertEquals('High', task.Priority);
            System.assertEquals('Not Started', task.Status);
            }
            else if(task.WhatId == jobAppList[1].Id) {
            Assert.isNotNull(task.Subject, 'The Subject should list a task');
            Assert.areEqual('High', task.Priority);
            Assert.areEqual('Not Started', task.Status);   
            }
        }   
    }
}