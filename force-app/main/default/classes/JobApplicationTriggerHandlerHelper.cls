
    
    public with sharing class JobApplicationTriggerHandlerHelper {
        public JobApplicationTriggerHandlerHelper(Job_Application__c jobApp) {
            if (jobApp == null || jobApp.Salary__c == null) {
                jobApp.Estimated_Federal_Tax__c = null;
                return;
            }
            
            Decimal standardDeduct = 13850;
            jobApp.Standard_Deduction__c = standardDeduct;
            Decimal salary = jobApp.Salary__c;
            Decimal taxableIncome = salary - standardDeduct;
    
            Decimal estimatedFederalTax = 0;
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
    
            Decimal socialSecurity = salary * .062;
            jobApp.Social_Security__c = socialSecurity;
            Decimal medicareWithholding = salary * .0145;
            jobApp.Medicare_Withholding__c = medicareWithholding;
            jobApp.Estimated_Federal_Tax__c = estimatedFederalTax;
            jobApp.Take_Home_Pay__c = salary - (estimatedFederalTax + medicareWithholding + socialSecurity);
            jobApp.Estimated_Monthly_Paycheck__c = jobApp.Take_Home_Pay__c / 12;
        }
    }
    
    