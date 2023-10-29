global class ScheduledInterviewEmail implements Schedulable {
    global void execute(SchedulableContext SC) {
        InterviewEmailReminder.InterviewEmailReminderMethod();
    }
}

//every morning at 4 am it will check if I have any interviews on the following day, it is does, it will send an email reminder
// to schedule it for 4 am to check every morning for interviews, I have to put it in hello.apex for:
    //String cronExpression = '0 0 4 * * ?'; //  at 4 AM
    //String jobName = 'DailyInterviewReminder';
    //System.schedule(jobName, cronExpression, new ScheduledInterviewEmail());