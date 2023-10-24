public with sharing class JobApplicationTriggerHandlerHelper2 {
    private Boolean isSingle;
    public JobApplicationTriggerHandlerHelper2(Job_Application__c jobApp, Boolean isSingleFiler) { 
        isSingle = isSingleFiler;  

        if (jobApp == null || jobApp.Salary__c == null) {
            jobApp.Estimated_Federal_Tax__c = null;
            return;
        }
        Decimal salary = jobApp.Salary__c;
        Decimal standardDeduct = isSingle ? 13850 : 27600;
        jobApp.Standard_Deduction__c = standardDeduct;

        Decimal taxableIncome = salary - standardDeduct;
        Decimal estimatedFederalTax = calculateTax(taxableIncome);

        Decimal socialSecurity = salary * .062;
        jobApp.Social_Security__c = socialSecurity;
        Decimal medicareWithholding = salary * .0145;
        jobApp.Medicare_Withholding__c = medicareWithholding;
        jobApp.Estimated_Federal_Tax__c = estimatedFederalTax;
        jobApp.Take_Home_Pay__c = (salary - (estimatedFederalTax + medicareWithholding + socialSecurity)).setScale(2, System.RoundingMode.HALF_UP);
        jobApp.Estimated_Monthly_Paycheck__c = (jobApp.Take_Home_Pay__c / 12).setScale(2, System.RoundingMode.HALF_UP);
        jobApp.Estimated_Weekly_Paycheck__c = (jobApp.Take_Home_Pay__c / 52).setScale(2, System.RoundingMode.HALF_UP);
    }
    private Decimal calculateTax(Decimal taxableIncome) {
        if (isSingle) {
            if (taxableIncome <= 11000) return taxableIncome * 0.10;
            if (taxableIncome <= 44725) return 1100 + (taxableIncome - 11000) * 0.12;
            if (taxableIncome <= 95375) return 5147 + (taxableIncome - 44725) * 0.22;
            if (taxableIncome <= 182100) return 16290 + (taxableIncome - 95375) * 0.24;
            if (taxableIncome <= 231250) return 37104 + (taxableIncome - 182100) * 0.32;
            if (taxableIncome <= 578125) return 52832 + (taxableIncome - 231250) * 0.35;
            return 174238.25 + (taxableIncome - 578125) * 0.37;
        } else {
            if (taxableIncome <= 22000) return taxableIncome * 0.10;
            if (taxableIncome <= 89450) return 2200 + (taxableIncome - 22000) * 0.12;
            if (taxableIncome <= 190750) return 10294 + (taxableIncome - 89450) * 0.22;
            if (taxableIncome <= 364200) return 32580 + (taxableIncome - 190750) * 0.24;
            if (taxableIncome <= 462500) return 74208 + (taxableIncome - 364200) * 0.32;
            if (taxableIncome <= 693750) return 105664 + (taxableIncome - 462500) * 0.35;
            return 186601.50 + (taxableIncome - 693750) * 0.37;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Decimal calculateTakeHomePay(Decimal salary, String filingStatus, String period) {
        Job_Application__c jobApp = new Job_Application__c();
        jobApp.Salary__c = salary;

        Boolean isSingleFiler = (filingStatus == 'single') ? true : false;

        new JobApplicationTriggerHandlerHelper2(jobApp, isSingleFiler); 

        if(period == 'monthly') {
            return jobApp.Estimated_Monthly_Paycheck__c;
        } else if(period == 'weekly') {
            return jobApp.Estimated_Weekly_Paycheck__c;
        } else {
            return jobApp.Take_Home_Pay__c;
        }
    }
}
 // source for tax brackets: https://www.forbes.com/advisor/taxes/taxes-federal-income-tax-bracket/  2023 tax brackets