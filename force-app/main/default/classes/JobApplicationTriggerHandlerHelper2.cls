public with sharing class JobApplicationTriggerHandlerHelper2 { //this is the code for the LWC JobQuest Calculator 2
    private Boolean isSingle;
    public JobApplicationTriggerHandlerHelper2(Job_Application__c jobApp, Boolean isSingleFiler) { 
        isSingle = isSingleFiler;  

        if (jobApp == null || jobApp.Salary__c == null) {
            jobApp.Estimated_Federal_Tax__c = null;
            return;
        }
        Decimal salary = jobApp.Salary__c;                   //The 2023 standard deduction is $13,850 for single filers, $27,700 for those married filing jointly   https://www.nerdwallet.com/article/taxes/standard-deduction              
        Decimal standardDeduct = isSingle ? 13850 : 27700;   //This is also a ternary conditional operation, which acts as short hand for an if-then-else statement. if single file is true, deduct is 13850, if married & filing jointly standard deduct is 27600
        jobApp.Standard_Deduction__c = standardDeduct;

        Decimal taxableIncome = salary - standardDeduct;
        Decimal estimatedFederalTax = calculateTax(taxableIncome);   //calculateTax is the method with the tax brackets below

        Decimal socialSecurity = salary * .062;
        jobApp.Social_Security__c = socialSecurity;
        Decimal medicareWithholding = salary * .0145;
        jobApp.Medicare_Withholding__c = medicareWithholding;                                                                                         //HALF_UP	Rounds towards the “nearest neighbor” goes up if number after is 5 or over                                                          
        jobApp.Take_Home_Pay__c = (salary - (estimatedFederalTax + medicareWithholding + socialSecurity)).setScale(2, System.RoundingMode.HALF_UP);  // https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_decimal.htm
        jobApp.Estimated_Federal_Tax__c = estimatedFederalTax;                                                                                       //.setScale setScale(scale, roundingMode)  Returns the Decimal scaled to the specified number of decimal places, using the specified rounding mode, if necessary.
        jobApp.Estimated_Monthly_Paycheck__c = (jobApp.Take_Home_Pay__c / 12).setScale(2, System.RoundingMode.HALF_UP);                              //so the 2 means two decimal places and the rounding Mode is System.RoundingMode.HALF_UP
        jobApp.Estimated_Weekly_Paycheck__c = (jobApp.Take_Home_Pay__c / 52).setScale(2, System.RoundingMode.HALF_UP);
    }
    private Decimal calculateTax(Decimal taxableIncome) {   // source for tax brackets: https://www.forbes.com/advisor/taxes/taxes-federal-income-tax-bracket/  2023 tax brackets
        if (isSingle) {   //tax brackets and taxable income for single filer
            if (taxableIncome <= 11000) {
                return taxableIncome * 0.10;
            } //you are taxed the amount you make in each bracket actually, so the first 1,100 you are taxed .10, then excess $$ over that at .12 and on up...
            if (taxableIncome <= 44725){ 
                return 1100 + (taxableIncome - 11000) * 0.12;
            }
            if (taxableIncome <= 95375) { 
                return 5147 + (taxableIncome - 44725) * 0.22;
            }
            if (taxableIncome <= 182100) {
                return 16290 + (taxableIncome - 95375) * 0.24;}
            if (taxableIncome <= 231250) {
                return 37104 + (taxableIncome - 182100) * 0.32;}
            if (taxableIncome <= 578125) {
                return 52832 + (taxableIncome - 231250) * 0.35;
                }
            else{
                return 174238.25 + (taxableIncome - 578125) * 0.37;
            }
        } 
        else {                                          //tax brackets and taxable income for married joint filing
            if (taxableIncome <= 22000) { 
                return taxableIncome * 0.10;
            }
            if (taxableIncome <= 89450) {
                return 2200 + (taxableIncome - 22000) * 0.12;
            }
            if (taxableIncome <= 190750) {
                return 10294 + (taxableIncome - 89450) * 0.22;
            }
            if (taxableIncome <= 364200) {
                return 32580 + (taxableIncome - 190750) * 0.24;
            }
            if (taxableIncome <= 462500) {
                return 74208 + (taxableIncome - 364200) * 0.32;
            }
            if (taxableIncome <= 693750) {
                return 105664 + (taxableIncome - 462500) * 0.35;
            }
            else{    
                return 186601.50 + (taxableIncome - 693750) * 0.37;
            }
        }
    }
    @AuraEnabled(cacheable=true)   //this part is for the lwc (JobQuest Calculator2)
    public static Decimal calculateTakeHomePay(Decimal salary, String filingStatus, String period) {   //calculateTakeHomePay method defined here is utilized by JobQuest_Paycheck_Calculator.js for the LWC  as well as the record fields on the Job Application object
        Job_Application__c jobApp = new Job_Application__c();
        jobApp.Salary__c = salary;

        Boolean isSingleFiler = (filingStatus == 'single') ? true : false;   //This is also a ternary conditional operation, which acts as short hand for an if-then-else statement. The syntax is as follows:  x ? y : z  (if x, a Boolean, is true, then the result is y; otherwise it is z.)
        new JobApplicationTriggerHandlerHelper2(jobApp, isSingleFiler); //so we'd put either true or false where it takes isSingleFiler

        if(period == 'monthly') {
            return jobApp.Estimated_Monthly_Paycheck__c;
        } 
        else if(period == 'weekly') {
            return jobApp.Estimated_Weekly_Paycheck__c;
        } 
        else {
            return jobApp.Take_Home_Pay__c;
        }
    }
}
 // source for tax brackets: https://www.forbes.com/advisor/taxes/taxes-federal-income-tax-bracket/  2023 tax brackets