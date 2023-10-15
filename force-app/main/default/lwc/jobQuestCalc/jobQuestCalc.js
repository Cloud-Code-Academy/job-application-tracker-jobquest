// import { LightningElement } from 'lwc';
// export default class JobQuestCalc extends LightningElement {
// //     amount = 0;

// //     handleAmountChange(e) {
// //         this.amount = e.detail.value;
// //     }
// // }

// @track result;
//     num1;
    
//     onInputChangeHandler(event) {
//         const name = event.target.name;
//         if (name === 'Number1') {
//             this.num1 = event.target.value;
       
//         }
//     }

//     onButtonCLick(event) {
//         var operation = event.target.label;
//         if (!isNaN(this.num1) ) {
//             const numb1 = parseInt(this.num1, 10);
           
//             var tempResult = 0;
//             if (operation === 'Monthly Paycheck') {
//                 tempResult = `${numb1 + numb2}`;
//             } else if (operation === 'Annual Net Income') {
//                 tempResult = `${numb1 - numb2}`;
           
//             if (tempResult !== null && tempResult !== '' && tempResult !== undefined && !isNaN(tempResult)) {
//                 this.result = tempResult;
//             }
//         }
//     }
// }
// }
// import { LightningElement, track } from 'lwc';

// export default class JobQuestCalc extends LightningElement {
//     @track num1; // Salary input
//     @track result = ''; // To display the result

//     onInputChangeHandler(event) {
//         const name = event.target.name;
//         if (name === 'Number1') {
//             this.num1 = parseFloat(event.target.value);
//         }
//     }

//     onButtonClick(event) {
//         const operation = event.target.label;
//         if (!isNaN(this.num1)) {
//             // Define your tax rates and standard deduction here
//             const standardDeduct = 13850;
//             const socialSecurityRate = 0.062;
//             const medicareWithholdingRate = 0.0145;
//             const taxBrackets = [
//                 { start: 0, end: 11000, rate: 0.10 },
//                 { start: 11000, end: 44725, rate: 0.11 },
//                 { start: 44725, end: 95375, rate: 0.15 },
//                 { start: 95375, end: 182100, rate: 0.19 },
//                 { start: 182100, end: 231250, rate: 0.22 },
//                 { start: 231250, end: 578125, rate: 0.28 },
//             ];

//             // Perform the calculations
//             const salary = this.num1;
//             const socialSecurity = salary * socialSecurityRate;
//             const medicareWithholding = salary * medicareWithholdingRate;
//             const taxableIncome = salary - standardDeduct;

//             let estimatedFederalTax = 0;
//             for (const bracket of taxBrackets) {
//                 if (taxableIncome > bracket.start && taxableIncome <= bracket.end) {
//                     estimatedFederalTax = taxableIncome * bracket.rate;
//                     break;
//                 }
//             }

//             let tempResult;

//             if (operation === 'Monthly Paycheck') {
//                 tempResult = (salary - estimatedFederalTax - (medicareWithholding + socialSecurity)) / 12;
//             } else if (operation === 'Annual Net Income') {
//                 tempResult = salary - estimatedFederalTax - (medicareWithholding + socialSecurity);
//             }

//             this.result = tempResult.toLocaleString(undefined, { maximumFractionDigits: 2 }); // Format the number
//         }
//     }
// }
// import { LightningElement, track } from 'lwc';

// export default class JobQuestCalc extends LightningElement {
//     @track num1; // Salary input
//     @track result = ''; // To display the result

//     onInputChangeHandler(event) {
//         const name = event.target.name;
//         if (name === 'Number1') {
//             this.num1 = parseFloat(event.target.value);
//         }
//     }

//     onButtonClick(event) {
//         const operation = event.target.label;
//         if (!isNaN(this.num1)) {
//             // Define your tax rates and standard deduction here
//             const standardDeduct = 13850;
//             const socialSecurityRate = 0.062;
//             const medicareWithholdingRate = 0.0145;
//             const taxBrackets = [
//                 { start: 0, end: 11000, rate: 0.10 },
//                 { start: 11000, end: 44725, rate: 0.11 },
//                 { start: 44725, end: 95375, rate: 0.15 },
//                 { start: 95375, end: 182100, rate: 0.19 },
//                 { start: 182100, end: 231250, rate: 0.22 },
//                 { start: 231250, end: 578125, rate: 0.28 },
//             ];

//             // Perform the calculations
//             const salary = this.num1;
//             const socialSecurity = salary * socialSecurityRate;
//             const medicareWithholding = salary * medicareWithholdingRate;
//             const taxableIncome = salary - standardDeduct;

//             let estimatedFederalTax = 0;
//             for (const bracket of taxBrackets) {
//                 if (taxableIncome > bracket.start && taxableIncome <= bracket.end) {
//                     estimatedFederalTax = (taxableIncome - bracket.start) * bracket.rate;
//                     break;
//                 }
//             }

//             const totalIncome = salary - estimatedFederalTax;
//             const annualNetIncome = totalIncome - (medicareWithholding + socialSecurity);
//             let tempResult;

//             if (operation === 'Monthly Paycheck') {
//                 tempResult = (annualNetIncome / 12).toFixed(2); // Format to two decimal places
//             } else if (operation === 'Annual Net Income') {
//                 tempResult = annualNetIncome.toFixed(2); // Format to two decimal places
//             }

//             this.result = tempResult; // Assign the formatted number directly
//         }
//     }
// }
// import { LightningElement, track } from 'lwc';

// export default class JobQuestCalc extends LightningElement {
//     @track num1; // Salary input
//     @track result = ''; // To display the result

//     onInputChangeHandler(event) {
//         const name = event.target.name;
//         if (name === 'Number1') {
//             this.num1 = parseFloat(event.target.value);
//         }
//     }

//     onButtonClick(event) {
//         const operation = event.target.label;
//         if (!isNaN(this.num1)) {
//             const standardDeduct = 13850;
//             const socialSecurityRate = 0.062;
//             const medicareWithholdingRate = 0.0145;
//             const taxBrackets = [
//                 { start: 0, end: 11000, rate: 0.10 },
//                 { start: 11000, end: 44725, rate: 0.11 },
//                 { start: 44725, end: 95375, rate: 0.15 },
//                 { start: 95375, end: 182100, rate: 0.19 },
//                 { start: 182100, end: 231250, rate: 0.22 },
//                 { start: 231250, end: 578125, rate: 0.28 },
//             ];

//             const salary = this.num1;
//             const socialSecurity = salary * socialSecurityRate;
//             const medicareWithholding = salary * medicareWithholdingRate;
//             const taxableIncome = salary - standardDeduct;

//             let estimatedFederalTax = 0;
//             for (const bracket of taxBrackets) {
//                 if (taxableIncome > bracket.start && taxableIncome <= bracket.end) {
//                     estimatedFederalTax += (taxableIncome - bracket.start) * bracket.rate;
//                     break;
//                 } else if (taxableIncome > bracket.start) {
//                     estimatedFederalTax += (bracket.end - bracket.start) * bracket.rate;
//                 }
//             }

//             const totalIncome = salary - estimatedFederalTax;
//             const annualNetIncome = totalIncome - (medicareWithholding + socialSecurity);
//             let tempResult;

//             if (operation === 'Monthly Paycheck') {
//                 tempResult = (annualNetIncome / 12).toFixed(2); // Format to two decimal places
//             } else if (operation === 'Annual Net Income') {
//                 tempResult = annualNetIncome.toFixed(2); // Format to two decimal places
//             }

//             this.result = tempResult; // Assign the formatted number directly
//         }
//     }
// }
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
