@isTest
public with sharing class JobApplicationTriggerHandler_Test {

@isTest
static void testJobApplicationTrigger_takeHomePayBeforeInsert(){     //this tests the method to determine net pay after taxes and withholding
    Job_Application__c[] jobAppList = new Job_Application__c[]{};
    
    Job_Application__c jobNull = new Job_Application__c(
        Job_Title__c = 'Salesforce Dev'
    );
    jobAppList.add(jobNull);
    
    Job_Application__c jobSalarySingle = new Job_Application__c(
        Job_Title__c = 'Jr. Salesforce Dev - Single',
        Salary__c = 65000,
        Single_or_Married_filing_Jointly__c = 'Filing Single'
    );
    jobAppList.add(jobSalarySingle);
    
    Job_Application__c jobSalaryMarried = new Job_Application__c(
        Job_Title__c = 'Jr. Salesforce Dev - Married',
        Salary__c = 65000,
        Single_or_Married_filing_Jointly__c = 'Filing Married (jointly)'
    );
    jobAppList.add(jobSalaryMarried);
    
    insert jobAppList;
    
    Map<Id, Job_Application__c> insertedJobApps = new Map<Id, Job_Application__c>(
        [SELECT Id, Take_Home_Pay__c, Estimated_Monthly_Paycheck__c, Estimated_Weekly_Paycheck__c, Single_or_Married_filing_Jointly__c 
         FROM Job_Application__c
         WHERE Id IN: jobAppList]
    );
    
    Assert.areEqual(null, insertedJobApps.get(jobNull.Id).Estimated_Monthly_Paycheck__c, 'This field should be null');
    System.assertEquals(4456, Math.round(insertedJobApps.get(jobSalarySingle.Id).Estimated_Monthly_Paycheck__c), 'Single Filing - This field should equal 4456');
    Assert.areEqual(53467.00, insertedJobApps.get(jobSalarySingle.Id).Take_Home_Pay__c, 'Single Filing - Take_Home_Pay__c should equal 53467.00');
    System.assertEquals(4666, Math.round(insertedJobApps.get(jobSalaryMarried.Id).Estimated_Monthly_Paycheck__c), 'Married Filing - This field should equal 4666');
    Assert.areEqual(55991.50, insertedJobApps.get(jobSalaryMarried.Id).Take_Home_Pay__c, 'Married Filing - Take_Home_Pay__c should equal 55991.50');
    Assert.areEqual(null, insertedJobApps.get(jobNull.Id).Estimated_Weekly_Paycheck__c, 'For a null salary, the weekly paycheck should also be null');
    System.assertEquals(1028, Math.round(insertedJobApps.get(jobSalarySingle.Id).Estimated_Weekly_Paycheck__c), 'For the given salary for filing single, the weekly paycheck should be 1028');

}


    @isTest
    static void testJobApplicationTrigger_setPrimaryContactBeforeUpdate() {  //this tests basically the same thing but after update.
        //Create test data
        Account account = new Account(Name = 'Mirand');
        insert account;
        Contact con = new Contact(LastName = 'Connie', AccountId = account.Id);
        insert con;
        Job_Application__c job0 = new Job_Application__c(Job_Title__c = 'Salesforce Dev', Job_Rating__c = '2 - Fair'); //no company listed
        Job_Application__c job1 = new Job_Application__c(Job_Title__c = 'Jr Salesforce Dev', Company__c = account.Id);
        List<Job_Application__c> jobAppList = new List<Job_Application__c> { job0, job1 };
        
        insert jobAppList;
        update jobAppList;  //update calls trigger so I no need to call the method

        List<Job_Application__c> results = [SELECT Id, Company__c, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobAppList]; //query on job apps

        System.assertEquals(null, results[0].Primary_Contact__c, 'Primary_Contact__c field should remain null since there was no associated company.'); //assert that without a company app won't have a primary contact
        System.assertEquals(con.Id, results[1].Primary_Contact__c, 'Primary_Contact__c field should be set to the contact related to the account.'); //believing in my trigger lol, I assert that the Primary Contact field will have a contact assigned
    }

    @isTest
    static void testJobApplicationTrigger_takeHomePayBeforeUpdate(){   //and more testing on the same method as above, I tried combining it with each of the others but for some reason it wouldn't work
        Job_Application__c[] jobAppList = new Job_Application__c[]{};
        
        Job_Application__c jobNull = new Job_Application__c(   //jobNull means Salary field is null
            Job_Title__c = 'Salesforce Dev'
        );
        jobAppList.add(jobNull);
        
        Job_Application__c jobSalarySingle = new Job_Application__c(
            Job_Title__c = 'Jr. Salesforce Dev - Single',
            Salary__c = 65000,
            Single_or_Married_filing_Jointly__c = 'Filing Single'
        );
        jobAppList.add(jobSalarySingle);
    
        Job_Application__c jobSalaryJoint = new Job_Application__c(
            Job_Title__c = 'Jr. Salesforce Dev - Jointly',
            Salary__c = 65000,
            Single_or_Married_filing_Jointly__c = 'Filing Married (jointly) '
        );
        jobAppList.add(jobSalaryJoint);
        
        insert jobAppList;  //this will trigger the after insert trigger
        
        
        jobNull.Salary__c = 65000;
        jobNull.Single_or_Married_filing_Jointly__c = 'Filing Single'; // setting filing status for the null record
        
        jobSalarySingle.Salary__c = 70000;
    
        jobSalaryJoint.Salary__c = 70000;
        
        update jobAppList; //this change should trigger the after update trigger so I don't have to call the method
        
        
        Map<Id, Job_Application__c> updatedJobApps = new Map<Id, Job_Application__c>(
            [SELECT Id, Take_Home_Pay__c, Estimated_Monthly_Paycheck__c, Estimated_Weekly_Paycheck__c, Single_or_Married_filing_Jointly__c 
             FROM Job_Application__c
             WHERE Id IN: jobAppList]
        );
        
        System.assertEquals(4456, Math.round(updatedJobApps.get(jobNull.Id).Estimated_Monthly_Paycheck__c), 'Single Filing after update from null salary - This field should equal 4456');
        Assert.areEqual(53467.00, updatedJobApps.get(jobNull.Id).Take_Home_Pay__c, 'Single Filing after update from null salary - Take_Home_Pay__c should equal 53467.00');
        
        System.assertEquals(4749, Math.round(updatedJobApps.get(jobSalarySingle.Id).Estimated_Monthly_Paycheck__c), 'Single Filing after salary update - This field should equal 4749');
        Assert.areEqual(56984.50, updatedJobApps.get(jobSalarySingle.Id).Take_Home_Pay__c, 'Single Filing after salary update - Take_Home_Pay__c should equal 56984.50');
        System.assertEquals(5001, Math.round(updatedJobApps.get(jobSalaryJoint.Id).Estimated_Monthly_Paycheck__c), 'Married Filing Jointly after salary update - This field should equal 5000');
        Assert.areEqual(60009.00, updatedJobApps.get(jobSalaryJoint.Id).Take_Home_Pay__c, 'Married Filing Jointly after salary update - Take_Home_Pay__c should equal 6009.00');
        System.assertEquals(1028, Math.round(updatedJobApps.get(jobNull.Id).Estimated_Weekly_Paycheck__c), 'Single Filing after update from null salary - Weekly paycheck should be 1028');
        System.assertEquals(1096, Math.round(updatedJobApps.get(jobSalarySingle.Id).Estimated_Weekly_Paycheck__c), 'Single Filing after salary update - Weekly paycheck should be 1096');
        System.assertEquals(1154, Math.round(updatedJobApps.get(jobSalaryJoint.Id).Estimated_Weekly_Paycheck__c), 'Married Filing Jointly after salary update - Weekly paycheck should be 1154');
}
    
    
@isTest
static void testJobApplicationTrigger_jobAppTaskHelper() {  //we test whether the right number of tasks were inserted depending on status
    // Prepare test data
    Job_Application__c[] jobAppList = new Job_Application__c[] {
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Saved'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applying'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applied'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Accepted'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Closed'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev')  // this one Defaults to 'Saved'
    };

    insert jobAppList;

    // Get the statuses of the inserted jobs
    Map<Id, String> jobIdToStatus = new Map<Id, String>();
    for (Job_Application__c insertedJob : [SELECT Id, Status__c FROM Job_Application__c WHERE Id IN :jobAppList]) { //first we get the Ids of the above inserts job apps
        jobIdToStatus.put(insertedJob.Id, insertedJob.Status__c);  //we make a map where Id is key to Status
    }
    List<Task> tasksForJobQuest = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId IN :jobIdToStatus.keySet()]; //we make a list of tasks assigned to the Id of the job apps we inserted and we will loop them
    Map<String, List<Task>> statusToTasks = new Map<String, List<Task>>();  //here we create a map to pair status to task after we loop the tasks
    for (Task task : tasksForJobQuest) {
        String status = jobIdToStatus.get(task.WhatId);  //here we get the task.WhatId 
        if (!statusToTasks.containsKey(status)) {   
            statusToTasks.put(status, new List<Task>());
        }
        statusToTasks.get(status).add(task);  //we end up with a map - status paired to task
    }

    
    Boolean foundExpectedTask = false;
    for (Task task : statusToTasks.get('Saved')) {  //we have a loop through (saved status) tasks until we find one which has the right Subject to make the Boolean true, then we stop.
        if (task.Subject == 'Check if the job description aligns with your interests and values') {
            foundExpectedTask = true;
            break;
        }
    }
    System.assert(foundExpectedTask, 'Expected task subject not found for "Saved" status.');

    
    Assert.areEqual(28, tasksForJobQuest.size(), 'Expected 29 tasks for the job applications');
    Assert.areEqual(6, statusToTasks.get('Saved').size(), 'Expected 6 tasks (3 tasks twice) for Saved status.');
    Assert.areEqual(5, statusToTasks.get('Applying').size(), 'Expected 5 tasks for Applying status');
    Assert.areEqual(4, statusToTasks.get('Applied').size(), 'Expected 4 tasks for Applied status');
    Assert.areEqual(5, statusToTasks.get('Interviewing').size(), 'Expected 5 tasks for Interviewing status');
    Assert.areEqual(3, statusToTasks.get('Negotiating').size(), 'Expected 3 tasks for Negotiating status');
    Assert.areEqual(3, statusToTasks.get('Accepted').size(), 'Expected 3 tasks for Accepted status');
    Assert.areEqual(2, statusToTasks.get('Closed').size(), 'Expected 3 tasks for Closed status');
}

   
    @isTest
    static void testJobApplicationTrigger_jobAppTaskHelperAfterUpdate() { //we use certain statuses and test for certain task Subjects or other task fields
       
        Job_Application__c[] jobAppList = new Job_Application__c[] {
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'),     
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating')
        };
        insert jobAppList; //this will trigger the after insert trigger

        jobAppList[0].Status__c = 'Negotiating';
        jobAppList[1].Status__c = 'Accepted';
        update jobAppList; //this should trigger the after update trigger

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
    @isTest
    static void testJobApplicationTrigger_jobAppTaskHelperAnotherUpdate(){    //now we do it all over again for update the test kept failing when I joined it with insert, its more complicated with update, because
        Job_Application__c[] jobAppList = new Job_Application__c[] {         // you have to add the job app insert status tasks to the updated status tasks 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Saved'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applying'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applied'),
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Accepted'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Closed'), 
            new Job_Application__c(Job_Title__c = 'Salesforce Dev') 
            };
            insert jobAppList;
        
            jobAppList[0].Status__c = 'Applying';
            jobAppList[1].Status__c = 'Applied';
            jobAppList[2].Status__c = 'Interviewing';
            jobAppList[3].Status__c = 'Negotiating';
            jobAppList[4].Status__c = 'Accepted';
            jobAppList[5].Status__c = 'Accepted'; //stayed same
            jobAppList[6].Status__c = 'Closed';
            jobAppList[7].Status__c = 'Saved';
            update jobAppList;
        
        Test.startTest();
            Map<Id, String> jobIdToStatus = new Map<Id, String>();
            for (Job_Application__c updatedJob : [SELECT Id, Status__c FROM Job_Application__c WHERE Id IN :jobAppList]) {
                jobIdToStatus.put(updatedJob.Id, updatedJob.Status__c);
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
        
            Assert.areEqual(48, tasksForJobQuest.size(), 'Expected 48 tasks for the job applications');
            
            System.assertEquals(8, statusToTasks.get('Applying').size(), 'Expected 8 tasks for Applying status');//[0] has 3 tasks from saved insert + 5 applying after updat
            System.assertEquals(9, statusToTasks.get('Applied').size(), 'Expected 9 tasks for Applied status'); //[1] has 5 applying after insert + 4 applied update
            System.assertEquals(9, statusToTasks.get('Interviewing').size(), 'Expected 9 tasks for Interviewing status');//[2] 4 applied insert + 5 Interviewing
            System.assertEquals(8, statusToTasks.get('Negotiating').size(), 'Expected 8 tasks for Negotiating status'); //[3] 5 tasks after insert + 3 after update
            System.assertEquals(9, statusToTasks.get('Accepted').size(), 'Expected 9 tasks for Accepted status'); // [5] didn't update so 3 and [4] had 3 + 3 after update 
            System.assertEquals(2, statusToTasks.get('Closed').size(), 'Expected 2 tasks for Closed status'); //[6] 2 tasks for closed status
            System.assertEquals(3, statusToTasks.get('Saved').size(), 'Expected 3 tasks for Saved status.'); //[7]just has saved status which is 3 tasks
            List<Task> closedTasks = statusToTasks.get('Closed');
            Boolean foundExpectedTask = false;
            for (Task task : closedTasks) {
                if (task.Subject == 'Review your notes and reflect on areas of improvement') {
                    foundExpectedTask = true;
                    break;
                }
            }
            System.assert(foundExpectedTask, 'Expected task subject not found for "Closed" status.');
        Test.stopTest();
        }
}