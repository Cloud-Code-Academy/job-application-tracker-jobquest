import { LightningElement, track, api } from 'lwc';
import calculateTakeHomePay from '@salesforce/apex/JobApplicationTriggerHandlerHelper2.calculateTakeHomePay';

export default class JobQuestCalculator extends LightningElement {
    @track num1 = 0;
    @track result = 0;
    @track formattedResult = '$0.00';  // this is a default value
    @track filingStatusValue = 'single';

    get options() {
        return [
            { label: 'Single', value: 'single' },
            { label: 'Married Filing Jointly', value: 'jointly' }
        ];
    }

    onInputChangeHandler(event) {
        this.num1 = event.target.value;
    }

    onFilingStatusChange(event) {
        this.filingStatusValue = event.detail.value;
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(value);
    }

    calculateMonthlyPay() {
        calculateTakeHomePay({ salary: this.num1, filingStatus: this.filingStatusValue, period: 'monthly' })
            .then(result => {
                this.result = result;
                this.formattedResult = this.formatCurrency(this.result);  // format and set to formattedResult
            })
            .catch(error => {
                console.error('Error fetching take-home pay:', error);
            });
    }

    calculateAnnualPay() {
        calculateTakeHomePay({ salary: this.num1, filingStatus: this.filingStatusValue, period: 'annual' })
            .then(result => {
                this.result = result;
                this.formattedResult = this.formatCurrency(this.result);  // format and set to formattedResult
            })
            .catch(error => {
                console.error('Error fetching take-home pay:', error);
            });
    }

    calculateWeeklyPay() {
        calculateTakeHomePay({ salary: this.num1, filingStatus: this.filingStatusValue, period: 'weekly' })
            .then(result => {
                this.result = result;
                this.formattedResult = this.formatCurrency(this.result);  // format and set to formattedResult
            })
            .catch(error => {
                console.error('Error fetching take-home pay:', error);
            });
    }
}
