public class JoobleBringMeJobs implements Schedulable {
    static String adminEmail; //trying to make it so only one admin email query is needed and then used throughout
    static {                  //below is 'static block'
        User adminUser = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        adminEmail = adminUser.Email;
    }  //email helper included at bottom of this code
    public static void fetchJobs() { 
        String endpoint = 'https://jooble.org/api/841aea51-b780-4bbb-ac8b-da65f2065d7f';
        String bodyContent = '{ keywords: "Jr. Salesforce Developer", location: "remote" }';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(bodyContent);
        Http http = new Http();
        HttpResponse response;
        try {
        response = http.send(request);
        if(response.getStatusCode() == 200) {
            processResponse(response.getBody());} 
            else {
            System.debug('Failed with status code: ' + response.getStatusCode());
            sendEmailToAdmin('Error in Jooble API Callout', 'Failed with status code: ' + response.getStatusCode());
            }
        } 
        catch(Exception excep) {
            sendEmailToAdmin('Exception in Jooble API Callout', excep.getMessage());
        }
    }
    public static void processResponse(String responseBody) {
        JoobleResponse joobleData = (JoobleResponse) JSON.deserialize(responseBody, JoobleResponse.class);
        List<Job_Application__c> jobsToInsert = new List<Job_Application__c>();
        for(Job joobleJob : joobleData.jobs) {
            Job_Application__c jobApp = new Job_Application__c();
            jobApp.Job_Title__c = joobleJob.title;
            jobApp.Location__c = joobleJob.location;
            jobApp.Job_Description__c = joobleJob.snippet;
            jobApp.Listing_Pay__c = String.valueOf(joobleJob.salary);  
            jobApp.Job_Post_Link__c = joobleJob.link;
            jobApp.Employer__c = joobleJob.company;
            jobApp.Jobble_Id__c = joobleJob.id;
            jobApp.Jooble_Last_Updated__c = joobleJob.updated;
            jobsToInsert.add(jobApp);
        }
        try{
            if(!jobsToInsert.isEmpty()) {
            insert jobsToInsert;
        }
        }
        catch(DmlException excep) {
            sendEmailToAdmin('DML Exception in Jooble Job Insert', excep.getMessage());
        }
    }
    public class JoobleResponse {
        public Integer totalCount;
        public List<Job> jobs;
    }
    public class Job {
        public String title;
        public String location;
        public String snippet;
        public String salary;
        public String link;
        public String updated;  
        public String id;    
        public String company;   
    }
    public void execute(SchedulableContext SC) {
        fetchJobs();
    }
    public static void sendEmailToAdmin(String subject, String body) { 
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { adminEmail });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
}
