import { LightningElement } from 'lwc';
export default class JobQuestCalc extends LightningElement {
    amount = 0;

    handleAmountChange(e) {
        this.amount = e.detail.value;
    }
}


