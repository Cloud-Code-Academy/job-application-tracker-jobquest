public with sharing class JobAppTaskHelper {

Job_Application__c job = new Job_Application__c();   
    public static void configureTask(List<Task> tasksToInsert, Id jobId, Id jobOwnerID, String taskSubject, Integer daysToAdd) {
        Task newTask = new Task(); 
        newTask.WhatId = jobId;
        newTask.ActivityDate = Date.Today().addDays(daysToAdd);
        newTask.Priority = 'High';
        newTask.OwnerId = jobOwnerID;
        newTask.Subject = taskSubject;
        newTask.Status = 'Not Started';
        tasksToInsert.add(newTask);
        
    }
}
