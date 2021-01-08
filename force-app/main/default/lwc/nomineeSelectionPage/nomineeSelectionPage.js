import createNominee from '@salesforce/apex/NomineeSelectionController.createNominee';
import getCampaignList from '@salesforce/apex/NomineeSelectionController.getCampaignList';
import getContactList from '@salesforce/apex/NomineeSelectionController.getContactList';
import getNominationList from '@salesforce/apex/NomineeSelectionController.getNominationList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, wire } from 'lwc';

export default class NomineeSelectionPage extends LightningElement {
    queryTerm; 
    contacts;
    nominations;
    campaigns;
    selectedNomination;
    selectedCampaign
    selectedContact;
    description;
    hasVoted = false;
    @wire(getContactList, {queryTerm:'$queryTerm'})
    wiredContacts(response){
        this.contacts = response.data;
    }
    @wire(getNominationList, {campaign: '$selectedCampaign'})
    wiredNominations(response){
        this.nominations = response.data;        
    }
    @wire(getCampaignList)
    wiredCampaigns(response){
        this.campaigns = response.data;
    }
    
    handleDescriptionChange(evt){
        this.description = evt.target.value;
    }

    handleSearchChange(evt) {
        this.queryTerm = evt.target.value;
    }

    handleNominationChange(event) {
        this.selectedNomination = event.detail.value;
        console.log(this.selectedNomination);
    }

    handleClickButton(evt) {
        if(!this.description){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Fill all required fields!',
                    variant: 'error',
                })
            );
        }else{

            createNominee({nominationId: this.selectedNomination, contactId: this.selectedContact, description: this.description})
            .then( () => {
                this.hasVoted = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Nominee has been submited',
                        variant: 'success',
                    })
                );
            })
            .catch(error =>{ 
                console.log('error', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
        }
    }

    handleClickViewForm(evt) {
        evt.currentTarget.style.backgroundColor = 'rgb(40, 127, 241)';
        this.selectedContact = evt.currentTarget.dataset.id;
        console.log (this.selectedContact);
    }

    get nominationOptions() {
        let listOfOptions = [];
        this.nominations.forEach(nom => {
            listOfOptions.push({ label: nom.Name, value: nom.Id });
        });
        return listOfOptions;
    }

    get campaignOptions() {
        let listOfOptions = [];
        this.campaigns.forEach(cam => {
            listOfOptions.push({ label: cam.Name, value: cam.Id });
        });
        return listOfOptions;
    }

    handleCampaignChange(event) {
        this.selectedCampaign = event.detail.value;
    }

}