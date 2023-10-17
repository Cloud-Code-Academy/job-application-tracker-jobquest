import { LightningElement, wire, track } from 'lwc';
import getJobApplications from '@salesforce/apex/JobQuestDisplayApex.getJobApplications';
import deleteJobApplication from '@salesforce/apex/JobQuestDisplayApex.deleteJobApplication';
import { NavigationMixin } from 'lightning/navigation';


export default class JobQuestJobDisplay extends NavigationMixin(LightningElement) {
    @track jobApplications = [];
    @track error;

    @wire(getJobApplications)
    wiredJobApplications({ error, data }) {
        if (data) {
            console.log("Received Data:", data); 
            this.jobApplications = data.map(job => {
                return {
                    id: job.Id,
                    title: job.Job_Title__c,
                    pay: job.Listing_Pay__c ? job.Listing_Pay__c : job.Salary__c,
                    employer: job.Employer__c ? job.Employer__c : (job.Company__r ? job.Company__r.Name : 'N/A'),
                    followUpDate: job.Follow_up_Date__c
                };
            });
            this.error = undefined;
        } else if (error) {
            console.log("Error:", JSON.stringify(error)); 
            this.error = error;
            this.jobApplications = undefined;
        }
    }

    handleNavigateToRecord(event) {
        const jobId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: jobId,
                actionName: 'view'
            }
        });
    }
    
    
    handleDelete(event) {
        const jobId = event.target.dataset.id;  // Get Job Application Id from the button data attribute
        console.log("Deleting job with ID:", jobId);
        deleteJobApplication({ jobId: jobId })
            .then(result => {
                console.log("Deletion successful for job ID:", jobId);
                this.jobApplications = this.jobApplications.filter(job => job.id !== jobId);

                // Optionally, show a success message (using toast or other UI methods)
            })
            .catch(error => {
                console.log("Error deleting job ID:", jobId, "Error:", JSON.stringify(error)); 
                this.error = error;
                // Handle error, show a message, etc.
            });
    }
}
