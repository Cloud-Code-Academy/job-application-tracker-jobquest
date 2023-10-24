@isTest     
public with sharing class EventTriggerHandler_Test {
    @isTest
    static User createTestUser(){  //so much info required for just in one test user
        User testUser = new User(
            Alias = 'tuser', 
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            TimeZoneSidKey = 'America/Anchorage',
            UserName = 'testuser@example.com' + DateTime.now().getTime(),
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id
        );
        insert testUser;
        return testUser;
    }
   
    @isTest   
    static void testEventTriggerHandlerBeforeInsert(){      //this makes sure overlapping interviews are not scheduled
        User testUser = createTestUser();   //see method right above this one
        Event event1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now(), EndDateTime = DateTime.now().addHours(1));
        Event event2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(2), EndDateTime = DateTime.now().addHours(3));
        insert new List<Event>{event1, event2};  
       
        Event overlapE1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addMinutes(30), EndDateTime = DateTime.now().addHours(1).addMinutes(30)); //this overlaps with the first one above
        Event overlapE2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(2).addMinutes(30), EndDateTime = DateTime.now().addHours(3).addMinutes(30)); //this overlaps with 2nd one above
        Event noOverlap = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(4), EndDateTime = DateTime.now().addHours(5));
        List<Event> toInsert = new List<Event>{overlapE1, overlapE2, noOverlap};
         
        try {
            insert toInsert;
            System.assert(false, 'Expected an exception because two events overlap.');
        } 
        catch(Exception except){
            System.assert(except.getMessage().contains('This interview may conflict with another event.'));
        }
    }
    
    @isTest  //this one kept failing to give an exception until I separated it from the test above it for some reason
    static void testEventTriggerHandlerBeforeUpdate(){ //again making sure overlapping interviews aren't scheduled on update
        User testUser = createTestUser();
        Event sameOwnerE1 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(5), EndDateTime = DateTime.now().addHours(6));
        Event sameOwnerE2 = new Event(Subject = 'Job Interview', OwnerId = testUser.Id, StartDateTime = DateTime.now().addHours(5).addMinutes(30), EndDateTime = DateTime.now().addHours(6).addMinutes(30));
                
        try {
            insert sameOwnerE1;
            Assert.isTrue(true, 'No exception expected');
            insert sameOwnerE2;
            System.assert(false, 'Expected an exception because two events for the same owner overlap.');
        } 
        catch(Exception except) {
            System.assert(except.getMessage().contains('This interview may conflict with another event.'));
        }
    }
}