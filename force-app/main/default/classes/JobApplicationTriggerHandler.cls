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
    public override void beforeInsert() {

    }
        

    public override void beforeUpdate() {

    }

    public override void beforeDelete () {

    }

    public override void afterInsert () {
        List<Task> tasksToInsert = new List<Task>();
        Task newTask = new Task();
        
        for (Job_Application__c job : this.newJobMap.values()) {
            job = newJobMap.get(job.Id);
            switch on job.Status__c {
            when 'Saved' {
                newTask.Subject = 'Alignment with Interest and Values';
                newTask.WhatId = job.Id;
                newTask.ActivityDate = Date.Today().addDays(2);
                newTask.Priority = 'High';
                newTask.OwnerId = job.OwnerId;
                newTask.Status = 'Not Started';
                tasksToInsert.add(newTask);
            }
            //when 'Status2' {
                //newTask.Subject = 'Task for Status2';
                
            }
            //when ''
            //when else {
              //  newTask.Subject = 'Default Task';
                
        }
        insert tasksToInsert;

    }
        


   

    public override void afterUpdate() {


    } 

    public override void afterDelete () {

    }

    public override void afterUndelete () {


    }




}