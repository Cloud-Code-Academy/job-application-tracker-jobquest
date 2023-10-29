global class ScheduledThankYouReminder implements Schedulable {
    global void execute(SchedulableContext SC) {
        InterviewEmailReminder.ThankYouNoteReminderMethod();
    }
}
