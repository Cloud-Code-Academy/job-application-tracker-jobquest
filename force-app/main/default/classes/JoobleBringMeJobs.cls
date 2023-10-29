public class JoobleBringMeJobs implements Schedulable { //JoobleBringMeJobs takes Jooble callout and sticks it into fields for Salesforce custom object 'Job Application', you can schedule it
    static String adminEmail; 
    static { //this static method or static initialization block runs only one time, regardless of how many times you access the class. https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm
        User adminUser = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
        adminEmail = adminUser.Email;
    }  
    public static void fetchJobs() { //this will be scheduled but it can run at any time with apex anonymous or hello.apex by typing: JoobleBringMeJobs.fetchJobs(); 
        String endpoint = 'callout: Jooble Api';   
        String bodyContent = '{ keywords: "Junior Salesforce Developer", location: "Remote" }';  //these keyword categories are given by Jooble to search the jobs, and refer to Job Title and Location and the stuff in double quotes can be changed ie remote can be changed to Anchorage, Alaska
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST'); //this command is consistent with instructions from Jooble
        request.setHeader('Content-Type', 'application/json'); 
        request.setBody(bodyContent); 
        Http http = new Http();
        HttpResponse response;
        try {
            response = http.send(request); 
            if(response.getStatusCode() == 200) {
                processResponse(response.getBody());
            } 
            else {
                sendEmailToAdmin('Error in Jooble API Callout', 'Failed with status code: ' + response.getStatusCode());  
            }
        } 
        catch(Exception excep) {
            sendEmailToAdmin('Exception in Jooble API Callout', excep.getMessage());  //this is just another attempt to catch errors
        }
    }
    public void execute(SchedulableContext SC) {
        fetchJobs(); //this actually calls the method above
    }
    public class JoobleResponse { //this inner class particular to this callout tells us the expected stucture of the JSON when it is deserealized below
        public Integer totalCount;
        public List<Job> jobs;
    }
    public class Job { //this inner class is particular to this callout, see Salesforce Developer "JSON Class" gives example of car as an inner public class within another class https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Json.htm
        public String title;
        public String location;
        public String snippet;
        public String salary;
        public String link;
        public String company;  
        public String id; 
        public String updated;  
    }
    public static void processResponse(String responseBody) {   //the string responseBody is the JSON string we get from Jooble
        JoobleResponse joobleData;
        try{
            joobleData = (JoobleResponse) JSON.deserialize(responseBody, JoobleResponse.class);  //info is deserialized and called joobleData
        }
        catch (System.JSONException excep){
            sendEmailToAdmin('JSON Deserialization Error', 'Failed to parse the response from Jooble. Please check if the structure has changed. Error: ' + excep.getMessage());
            return; //exit so no null pointer
        }
        List<Job_Application__c> jobsToInsert = new List<Job_Application__c>(); 
        for(Job joobleJob : joobleData.jobs) {   //here each joobleJob is split into categories to correspond to the fields of custom object Job Application, as it is looped through joobleData
            Job_Application__c jobApp = new Job_Application__c();  //this is a new (instance) record for Job Application to be filled in with jooble job data, then added to list jobsToInsert
            jobApp.Job_Title__c = joobleJob.title;
            jobApp.Location__c = joobleJob.location;
            joobleJob.snippet = removeHtmlTagsAndEntities(joobleJob.snippet);
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
            List<String> errorMessages = new List<String>();
            Database.SaveResult[] saveResults = Database.insert(jobsToInsert, false); //this is where the list inserts, 'false' is so a partial insert can get inserted and it isn't all rolled back if I find a duplicate: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm   
            for(Database.SaveResult saveRest : saveResults) {     //loop
                if(!saveRest.isSuccess()) {
                        for(Database.Error err : saveRest.getErrors()) {
                            errorMessages.add(err.getMessage());
                        }
                    }
                }
                if(!errorMessages.isEmpty()) {
                    String errorMessageBody = 'The following errors occurred while inserting Job Application records from Jooble:\n\n';
                    errorMessageBody += String.join(errorMessages, '\n');
                    sendEmailToAdmin('DML Errors while inserting Job Applications', errorMessageBody); //This cuts down on all those error messages being sent to admin!
                }
        }
        }
        catch(DmlException excep) {
            sendEmailToAdmin('DML Exception in Jooble Job Insert', excep.getMessage());  //the System admin gets an email when there is a problem, if all these emails to admin prove to be a problem, some of the email lines can be commented out
        }
    } //here the process response method ends
    //the following method is just a little helper method to send email to System Administrator, it could be on a different file but I made the decision to include it here so I didn't mix it up with my other email helper
    public static void sendEmailToAdmin(String subject, String body) {  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { adminEmail });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    public static String removeHtmlTagsAndEntities(String input) {  //helper to get rid of some of the html tags showing up in the description
        if(String.isEmpty(input)) return input;
        String stripped = input.replaceAll('<[^>]+>', '');
        stripped = stripped.replace('&nbsp;', ' '); 
        return stripped.trim();
    }
    
}

