public with sharing class EventTriggerHandler extends TriggerHandler {
    private List<Event> newEventList;
    private Map<Id, Event> newEventMap;
    private List<Event> oldEventList;
    private Map<Id, Event> oldEventMap;

    public EventTriggerHandler() {
        this.newEventList = (List<Event>)Trigger.new;
        this.newEventMap = (Map<Id, Event>)Trigger.newMap;
        this.oldEventList = (List<Event>)Trigger.old;
        this.oldEventMap = (Map<Id, Event>)Trigger.oldMap;
    }

    /*The Unix epoch is the number of seconds that have elapsed since January 1, 1970 (midnight UTC/GMT), not counting leap seconds (in ISO 8601: 1970-01-01T00:00:00Z). 
    DateTime.getTime() found here -https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm. 
    Also, tried to use 'datetime' as my variable but its a keyword.
    Below we multiply 1000 by 60 to get minutes.  (source:  https://www.epochconverter.com/)*/
    private Long convertToEpochMinutes(DateTime dtTime) {
        return dtTime.getTime() / (1000 * 60);
    }

    public override void beforeInsert() {
        timeOverlaps(this.newEventList);
    }

    public override void beforeUpdate() {
        timeOverlaps(this.newEventList);
    }

    public void timeOverlaps(List<Event> events) {
        Map<Integer, Map<String, Long>> allEventEpochTimes = new Map<Integer, Map<String, Long>>(); ///pre-existing interview events (to be queried) sitting already in Salesforce org
        Map<Integer, Map<String, Long>> eventEpochTimes = new Map<Integer, Map<String, Long>>(); //pre insert or pre updated (trigger.new)

        for (Integer i = 0; i < events.size(); i++) {
            Event event = events[i];  //these are all the new events being scheduled or updated
            eventEpochTimes.put(i, new Map<String, Long> {   //for the new events(before insert or update), Integer 'i' is kind of like a pseudoId, a key in the map, then we have another map as the value                                     
                'start' => convertToEpochMinutes(event.StartDateTime), // the value in the map of a map is the string = 'start' or 'end' & the Long = the Epoch minutes (date & time) so we need to keep this pair together
                'end' => convertToEpochMinutes(event.EndDateTime)
            });
        }

        List<Event> allEvents = [SELECT Id, StartDateTime, EndDateTime   //we query existing interview date/time that we aren't already processing
                                 FROM Event 
                                 WHERE Subject = 'Job Interview' 
                                 AND Id NOT IN :this.newEventList];

        Integer counter = 0;
        for (Event existingEvent : allEvents) {
            allEventEpochTimes.put(counter++, new Map<String, Long>{     //another map with map as value same as above but this time for the pre existing dates
                'start' => convertToEpochMinutes(existingEvent.StartDateTime),
                'end' => convertToEpochMinutes(existingEvent.EndDateTime)
            });
        }
        for (Integer i = 0; i < events.size(); i++) { // This for overlaps with existing events in the database. It takes each new event and sees if it conflicts with the pre existing events
            Event event = events[i];
            Long eventStart = eventEpochTimes.get(i).get('start');
            Long eventEnd = eventEpochTimes.get(i).get('end');
        
            for (Integer j = 0; j < allEvents.size(); j++) {
                Long overlapStart = allEventEpochTimes.get(j).get('start');
                Long overlapEnd = allEventEpochTimes.get(j).get('end');
            
                if ((eventStart < overlapEnd) && (eventEnd > overlapStart)) {
                    event.addError('This interview may conflict with another event.');
                    break;
                }
            }
        }
        for (Integer i = 0; i < events.size(); i++) {  //I had to add this whole part because I made a test where two events that conflicted and had same owner updated at same time and above code didn't catch it, so another loop was needed
            Event eventI = events[i];                   //this represents new events; in this part of the code I'll compare the records being not yet inserted or updated to each other and checks for overlap
            Long startI = eventEpochTimes.get(i).get('start');
            Long endI = eventEpochTimes.get(i).get('end');
    
            for (Integer j = i + 1; j < events.size(); j++) {
                Long startJ = eventEpochTimes.get(j).get('start');
                Long endJ = eventEpochTimes.get(j).get('end');
        
                if ((startI < endJ) && (endI > startJ)) {
                    eventI.addError('This interview may conflict with another event.');
                    break;
                }
            }
        }
    }
}
