import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, wire, track} from 'lwc';
import getCampaignList from '@salesforce/apex/VotingController.getCampaignList';
import getNominationList from '@salesforce/apex/VotingController.getNominationList';
import createVote from '@salesforce/apex/VotingController.createVote';
import getContactList from '@salesforce/apex/VotingController.getContactList';
import getDescription from '@salesforce/apex/VotingController.getDescription';
import { NavigationMixin } from 'lightning/navigation';

export default class VotingPage extends NavigationMixin(LightningElement) {
    queryTerm; 
    contacts;
    @track contactsInNominations;
    @track nominations;
    campaign;
    voterEmail;
    selectedNomination;
    selectedCampaign;
    posibleVotes = {};
    hasVoted = false;
    connectedCallback(){
        getCampaignList().then(result => { 
            this.campaign = result;
            getNominationList({campaign: this.campaign.Id}).then(result => { 
                this.nominations = result.slice();
                getContactList({nominations: this.nominations}).then(result => { 
                    this.contactsInNominations = result;
                    this.nominations.forEach(nominationItem => {
                        this.contactsInNominations[nominationItem.Id].forEach(contactItem => {
                            getDescription({contactId: contactItem.Id, nominationId: nominationItem.Id}).then(result => {
                                contactItem.description =  result;
                            });            
                        });
                        nominationItem.contacts = this.contactsInNominations[nominationItem.Id];
                    });
                });
            });

        });
        
    }
    handleEmailChange(evt){
        this.voterEmail = evt.target.value;
    }
    
    handleClickButton(evt) {
        if(!this.voterEmail){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Fill all required fields!',
                    variant: 'error',
                })
            );
        }else{
        createVote({finalVotes : this.posibleVotes, email: this.voterEmail})
        .then( () => {
            this.hasVoted = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your vote has been submited',
                    variant: 'success',
                })
            );
        })
        .catch(error =>{ 
            console.log('error.body.message', error.body.message);
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
        let selectedContact = evt.currentTarget.dataset.id1;
        let nomination = evt.currentTarget.dataset.id2;
        this.posibleVotes[nomination] = selectedContact;
    }

    navigateToHome() {
        // Use the built-in 'Navigate' method
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }
}