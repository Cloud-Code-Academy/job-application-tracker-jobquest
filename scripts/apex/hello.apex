// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


//Below Have all Been Scheduled:
// String interviewCronExpression = '0 0 4 * * ?'; //  at 4 AM - checks for interviews for the next day every day & send email day before if it finds an interview
// String jobName = 'DailyInterviewReminder';
// System.schedule(jobName, interviewCronExpression, new ScheduledInterviewEmail());

// String cron1 = '0 0 0 1 * ? *';   //first of month - cleans up my old job apps
// System.schedule('JobApplicationBatch_1st', cron1, new ScheduleJobApplicationBatch());

// String cron2 = '0 0 0 15 * ? *';  //15th of month - cleans up my old job apps
// System.schedule('JobApplicationBatch_15th', cron2, new ScheduleJobApplicationBatch());

//JoobleBringMeJobs.fetchJobs(); //I can call this when ever I wish to see new jobs

// JoobleBringMeJobs job = new JoobleBringMeJobs();
// String joobleCronExpression = '0 0 4 * * ?';  // This specifies 4 AM daily
// System.schedule('DailyJoobleJobAt4AM', joobleCronExpression, job);


// ScheduledThankYouReminder reminder = new ScheduledThankYouReminder();
// String cronExp = '0 0 18 * * ?';  // This represents 6 pm every day
// System.schedule('ThankYouNoteReminderJob', cronExp, reminder);
