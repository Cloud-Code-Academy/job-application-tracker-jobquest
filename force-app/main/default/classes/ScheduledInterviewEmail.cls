global class ScheduledInterviewEmail implements Schedulable {
    global void execute(SchedulableContext SC) {
        InterviewEmailReminder.InterviewEmailReminderMethod();
    }
}