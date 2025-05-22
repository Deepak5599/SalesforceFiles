import { LightningElement } from 'lwc';

export default class SingUpComponent extends LightningElement {

    email = '';
    password = '';
    confirmPassword = '';

    handleChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }

    handleSubmit(){
        let password2 = this.template.querySelector('.confirmPassword');
        if(this.password != this.confirmPassword){
            password2.setCustomValidity("Passwords do not match.")
            password2.reportValidity();
        }else{
            password2.setCustomValidity("")
            password2.reportValidity();
        }
    }

}