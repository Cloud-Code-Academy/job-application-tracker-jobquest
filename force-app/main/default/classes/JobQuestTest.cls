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
        System.assertEquals(4456, Math.round(takeHomePayList[1].Estimated_Monthly_Paycheck__c), 'This field should equal 4456'); //as long as it rounds right correctly we're good, if this number is right - we can assume the annual number will be correct also
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
        insert jobAppList;  //this will again trigger the after insert trigger
        List<Id> insertedIds = new List<Id>();
            for(Job_Application__c jobApp : jobAppList) {
                insertedIds.add(jobApp.Id);
            }  
        jobNull.Salary__c = 65000;
        jobSalary.Salary__c = 70000;
        update jobAppList; //this change should trigger the after update trigger

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
static void testJobApplicationTrigger_jobAppTaskHelper() {
    // Prepare test data
    Job_Application__c[] jobAppList = new Job_Application__c[] {
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Saved'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applying'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Applied'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Interviewing'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Negotiating'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Accepted'), 
        new Job_Application__c(Job_Title__c = 'Salesforce Dev', Status__c = 'Closed'),
        new Job_Application__c(Job_Title__c = 'Salesforce Dev')  // Defaults to 'Saved'
    };

    insert jobAppList;

    // Retrieve the statuses of the inserted jobs
    Map<Id, String> jobIdToStatus = new Map<Id, String>();
    for (Job_Application__c insertedJob : [SELECT Id, Status__c FROM Job_Application__c WHERE Id IN :jobAppList]) {
        jobIdToStatus.put(insertedJob.Id, insertedJob.Status__c);
    }

    // Group tasks by status
    List<Task> tasksForJobQuest = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId IN :jobIdToStatus.keySet()];
    Map<String, List<Task>> statusToTasks = new Map<String, List<Task>>();
    for (Task task : tasksForJobQuest) {
        String status = jobIdToStatus.get(task.WhatId);
        if (!statusToTasks.containsKey(status)) {
            statusToTasks.put(status, new List<Task>());
        }
        statusToTasks.get(status).add(task);
    }

    // Check for specific task for 'Saved' status
    Boolean foundExpectedTask = false;
    for (Task task : statusToTasks.get('Saved')) {
        if (task.Subject == 'Check if the job description aligns with your interests and values') {
            foundExpectedTask = true;
            break;
        }
    }
    System.assert(foundExpectedTask, 'Expected task subject not found for "Saved" status.');

    
    Assert.areEqual(28, tasksForJobQuest.size(), 'Expected 28 tasks for the job applications');
    Assert.areEqual(6, statusToTasks.get('Saved').size(), 'Expected 6 tasks (3 tasks twice) for Saved status.');
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
    static void testJobApplicationTrigger_jobAppTaskHelperAnotherUpdate(){
        Job_Application__c[] jobAppList = new Job_Application__c[] {
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
       
   
    @isTest
    static User createTestUser(){  //so much is required to put in one test user
        User testUser = new User(
            Alias = 'tuser', 
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Anchorage',
            UserName = 'testuser@example.com' + DateTime.now().getTime(),
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id
        );
        insert testUser;
        return testUser;
    }

    @isTest
    static void testEventTriggerHandlerBeforeInsert(){    
        User testUser = createTestUser();   //see method right above this one
        Event event1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        Event event2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(2), EndDateTime = DateTime.now().addHours(3));
        insert new List<Event>{event1, event2};  
       
        Event overlapE1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addMinutes(30), EndDateTime = DateTime.now().addHours(1).addMinutes(30)); //this overlaps with the first one above
        Event overlapE2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(2).addMinutes(30), EndDateTime = DateTime.now().addHours(3).addMinutes(30)); //this overlaps with 2nd one above
        Event noOverlap = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(4), EndDateTime = DateTime.now().addHours(5));
        List<Event> toInsert = new List<Event>{overlapE1, overlapE2, noOverlap};
         
        try {
            insert toInsert;
            System.assert(false, 'Expected an exception because two events overlap.');
        } 
        catch(Exception except){
            System.assert(except.getMessage().contains('This interview may conflict with another event.'));
        }
    }
    @isTest  //this one kept failing to give an exception until I separated it from the test above it for some reason
    static void immediateOverlappingEventsForSameOwnerBeforeInsert(){
        User testUser = createTestUser();
        Event sameOwnerE1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(5), EndDateTime = DateTime.now().addHours(6));
        Event sameOwnerE2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(5).addMinutes(30), EndDateTime = DateTime.now().addHours(6).addMinutes(30));
                
        try {
            insert sameOwnerE1;
            Assert.isTrue(true, 'No exception expected');
            insert sameOwnerE2;
            System.assert(false, 'Expected an exception because two events for the same owner overlap.');
        } 
        catch(Exception except) {
            System.assert(except.getMessage().contains('This interview may conflict with another event.'));
        }
    }

    @isTest  
    static void testEventTriggerHandlerBeforeUpdate(){    //I had to write a last paragraph of code on the EventTriggerHandler just to pass this one
        User testUser = createTestUser();  
        Event event1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        Event event2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(2), EndDateTime = DateTime.now().addHours(3));
        insert new List<Event>{event1, event2};  
        
        event1.StartDateTime = DateTime.now();
        event1.EndDateTime = DateTime.now().addHours(3); // Overlaps with event2 now
        event2.StartDateTime = DateTime.now().addHours(1);
        event2.EndDateTime = DateTime.now().addHours(2);

        try {
            update new List<Event>{event1, event2};
            System.assert(false, 'Expected an exception because the updated events overlap.');
        } 
        catch(Exception except) {
            System.assert(except.getMessage().contains('This interview may conflict with another event.'));
        }
    }
}