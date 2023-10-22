@isTest
private class JoobleBringMeJobsTest {
    
    // Implement mock callout class
    private class MockJoobleResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);//testing for best scenerio will also need to test for when it doesn't work 
           
            res.setBody('{"totalCount":1,"jobs":[{"title":"Salesforce Developer","location":"Remote","snippet":"Job description...","salary":"1000","link":"https://joblink.com","company":"TechCorp","id":"1234","updated":"2023-10-21T10:10:10Z"}]}');
            return res;
        }
    }
    
    @isTest static void testBringMeJobs() {
        Test.setMock(HttpCalloutMock.class, new MockJoobleResponse());
        
        Test.startTest();
        JoobleBringMeJobs.fetchJobs(); 
        Test.stopTest();
        
        List<Job_Application__c> insertedJobs = [SELECT Job_Title__c, Location__c, Job_Description__c FROM Job_Application__c];
        Assert.areEqual(1, insertedJobs.size(), 'Expected 1 job listing to be inserted.');
        Assert.areEqual('Salesforce Developer', insertedJobs[0].Job_Title__c);
        Assert.areEqual('Remote', insertedJobs[0].Location__c);
        Assert.areEqual('Job description...', insertedJobs[0].Job_Description__c);
    }
}
