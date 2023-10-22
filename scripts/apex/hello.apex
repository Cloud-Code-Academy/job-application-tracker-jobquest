// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

String cronExpression = '0 0 4 * * ?'; //  at 4 AM
String jobName = 'DailyInterviewReminder';
System.schedule(jobName, cronExpression, new ScheduledInterviewEmail());


String cron1 = '0 0 0 1 * ? *';   //first of month
System.schedule('JobApplicationBatch_1st', cron1, new ScheduleJobApplicationBatch());
String cron2 = '0 0 0 15 * ? *';  //15th of month
System.schedule('JobApplicationBatch_15th', cron2, new ScheduleJobApplicationBatch());



JoobleBringMeJobs.fetchJobs();
