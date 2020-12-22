import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, wire } from 'lwc';
import getCampaignList from '@salesforce/apex/VotingController.getCampaignList';
import getNominationList from '@salesforce/apex/VotingController.getNominationList';
import createVote from '@salesforce/apex/VotingController.createVote';
import getContactList from '@salesforce/apex/VotingController.getContactList';
// import getVoter from '@salesforce/apex/VotingController.getVoter';

export default class VotingPage extends LightningElement {
    queryTerm; 
    contacts;
    contactsInNominations;
    nominations;
    campaign;
    voterEmail;
    selectedNomination;
    selectedCampaign;
    posibleVotes = {};
    updateContacts = false;
    hasVoted = false;
    connectedCallback(){
        getCampaignList().then(result => { 
            this.campaign = result;
            getNominationList({campaign: this.campaign.Id}).then(result => { 
                this.nominations = result.slice();
                getContactList({nominations: this.nominations}).then(result => { 
                    this.contactsInNominations = result;
                    this.nominations.forEach(nominationItem => {
                        nominationItem.contacts = this.contactsInNominations[nominationItem.Id];
                    });
                    this.updateContacts = true;
                });
            });

        });
        
    }


    // @wire(getContactList, {queryTerm:'$queryTerm', nominationsId: '$selectedNomination'})
    // wiredContacts(response){
    //     this.contacts = response.data;
    // }
    // @wire(getNominationList, {campaign: '$selectedCampaign'})
    // wiredNominations(response){
    //     this.nominations = response.data;        
    // }
    // @wire(getCampaignList)
    // wiredCampaigns(response){
    //     this.campaigns = response.data;
    // }
    handleEmailChange(evt){
        this.voterEmail = evt.target.value;
    }
    
    // handleSearchChange(evt) {
    //     this.queryTerm = evt.target.value;
    // }

    // handleNominationChange(event) {
    //     this.selectedNomination = event.detail.value;
    // }
    
    // handleCampaignChange(event) {
    //     this.selectedCampaign = event.detail.value;
    // }

    handleClickButton() {
        if(!this.voterEmail){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Fill all required fields!',
                    variant: 'error',
                })
            );
        }else{
        // let voterContactId = getVoter({email: this.voterEmail});
        // console.log('voterContact ' + voterContactId);
        // console.log('selectedNomination ' + this.selectedNomination);
        // console.log('selectedContact ' + this.selectedContact);
        console.log('this.voterEmail ' + this.voterEmail);
        createVote({finalVotes : this.posibleVotes, email: this.voterEmail})
        .then( () => {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Success',
            //         message: 'Your vote has been submited',
            //         variant: 'success',
            //     })
            // );
            this.hasVoted = true;
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
    }

    handleClickViewForm(evt) {
        let selectedContact = evt.currentTarget.dataset.id1;
        let nomination = evt.currentTarget.dataset.id2;
        console.log('nomination: ' + nomination);
        console.log('this.selectedContact ' + selectedContact);
        // this.posibleVotes.set(nomination, selectedContact);
        this.posibleVotes[nomination] = selectedContact;
        // this.posibleVotes = {'nomination' : nomination , 'selectedContact' : selectedContact};
        console.log('this.posibleVotes: ', this.posibleVotes);
    }

    // get nominationOptions() {
    //     let listOfOptions = [];
    //     this.nominations.forEach(nom => {
    //         listOfOptions.push({ label: nom.Name, value: nom.Id });
    //     });
    //     return listOfOptions;
    // }

    // get campaignOptions() {
    //     console.log('this.campaigns: ' + this.campaigns);
    //     let listOfOptions = [];
    //     this.campaigns.forEach(cam => {
    //         listOfOptions.push({ label: cam.Name, value: cam.Id });
    //     });
    //     return listOfOptions;
    // }
}