import { LightningElement , wire} from 'lwc';
import getCampaignList from '@salesforce/apex/NominationCreationController.getCampaignList';
import createNomination from '@salesforce/apex/NominationCreationController.createNomination';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NominationCreationPage extends LightningElement {
    campaigns;
    nomination = '';
    selectedCampaign;
    @wire(getCampaignList)
    wiredCampaigns(response){
        this.campaigns = response.data;
    }

    handleClick(){
        console.log(this.selectedCampaign + '\n' +this.nomination);
        createNomination({campaignId: this.selectedCampaign, nominationName: this.nomination})
        .then( () => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Nomination has been created',
                    variant: 'success',
                })
            );
        })
        .catch(error =>{ 
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        });
    }

    handleTextChange(event){
        this.nomination = event.target.value;
    }

    get campaignOptions() {
        let listOfOptions = [];
        console.log(this.campaigns);
        this.campaigns.forEach(cam => {
            listOfOptions.push({ label: cam.Name, value: cam.Id });
        });
        return listOfOptions;
    }

    handleChange(event) {
        this.selectedCampaign = event.detail.value;
    }
}