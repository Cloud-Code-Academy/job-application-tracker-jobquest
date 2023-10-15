import { LightningElement, track } from 'lwc';

export default class JobQuestCalc extends LightningElement {
   
    @track num1; 
    @track result = ''; 

    onInputChangeHandler(event) {
        const name = event.target.name;
        if (name === 'Number1') {
            this.num1 = parseFloat(event.target.value); 
        }
    }

    onButtonClick(event) {
        const operation = event.target.label;
        const standardDeduct = 13850;
        const socialSecurityRate = 0.062;
        const medicareWithholdingRate = 0.0145;
        const salary = this.num1;
        const taxableIncome = salary - standardDeduct;

        let estimatedFederalTax = 0;
        if (taxableIncome <= 11000) {
            estimatedFederalTax = taxableIncome * 0.10;
        } else if (taxableIncome <= 44725) {
            estimatedFederalTax = 1100 + (taxableIncome - 11000) * 0.12;
        } else if (taxableIncome <= 95375) {
            estimatedFederalTax = 5147 + (taxableIncome - 44725) * 0.22;
        } else if (taxableIncome <= 182100) {
            estimatedFederalTax = 16290 + (taxableIncome - 95375) * 0.24;
        } else if (taxableIncome <= 231250) {
            estimatedFederalTax = 37104 + (taxableIncome - 182100) * 0.32;
        } else if (taxableIncome <= 578125) {
            estimatedFederalTax = 52832 + (taxableIncome - 231250) * 0.35;
        } else {
            estimatedFederalTax = 174238.25 + (taxableIncome - 578125) * 0.37;
        }
        const socialSecurity = salary * socialSecurityRate;
        const medicareWithholding = salary * medicareWithholdingRate;
        const totalIncome = salary - estimatedFederalTax;
        const annualNetIncome = totalIncome - (medicareWithholding + socialSecurity);

        let tempResult;
        if (operation === 'Monthly Paycheck') {
            tempResult = (annualNetIncome / 12).toFixed(2); 
        } else if (operation === 'Annual Net Income') {
            tempResult = annualNetIncome.toFixed(2); 
        }
        this.result = tempResult;
    }
}
