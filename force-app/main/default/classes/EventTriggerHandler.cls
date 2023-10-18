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
Java: long epoch = System.currentTimeMillis()/1000; Returns epoch in seconds. Below we multiply 1000 by 60 to get minutes.  (source:  https://www.epochconverter.com/)*/
    private Long convertToEpochMinutes(DateTime dateTm) {
        return dateTm.getTime() / (1000 * 60);  
    }
    public override void beforeInsert() {
        timeOverlaps(newEventList);
    }
    public override void beforeUpdate() {
        timeOverlaps(newEventList);
    }
    public void timeOverlaps(List<Event> events) {
        Map<Integer, Map<String, Long>> eventEpochTimes = new Map<Integer, Map<String, Long>>();
        for (Integer i = 0; i < events.size(); i++) {
            Event event = events[i];
            eventEpochTimes.put(i, new Map<String, Long>{    
                'start' => convertToEpochMinutes(event.StartDateTime),
                'end' => convertToEpochMinutes(event.EndDateTime)
            });
        }
        List<Event> allEvents = [SELECT Id, StartDateTime, EndDateTime 
                                FROM Event 
                                WHERE Subject = 'Job Interview' 
                                AND Id 
                                NOT IN :events];

        Map<Id, Map<String, Long>> allEventEpochTimes = new Map<Id, Map<String, Long>>();
        for (Event event : allEvents) {
            allEventEpochTimes.put(event.Id, new Map<String, Long>{
                'start' => convertToEpochMinutes(event.StartDateTime),
                'end' => convertToEpochMinutes(event.EndDateTime)
            });
        }
        for (Integer i = 0; i < events.size(); i++) {
            Event event = events[i];
            Long eventStart = eventEpochTimes.get(i).get('start');
            Long eventEnd = eventEpochTimes.get(i).get('end');
            for (Event overlappingEvent : allEvents) {
                Long overlapStart = allEventEpochTimes.get(overlappingEvent.Id).get('start');
                Long overlapEnd = allEventEpochTimes.get(overlappingEvent.Id).get('end');
                if ((eventStart < overlapEnd) && (eventEnd > overlapStart)) {
                    event.addError('This interview may conflict with another event.');
                    break; 
                }
            }
        }
    }
}