document.querySelector('.add-contact').addEventListener('click', function() {
    resetContactModel();
});

function resetContactModel() {
    document.getElementById('contactname').value = '';
    document.getElementById('emailaddress').value = '';
    document.getElementById('phonenumbermodal').value = '';
    document.getElementById('job-position').value = '';
    document.getElementById('save-contact').textContent = 'Save';
}

resetContactModel();

function setDataInContactModel(name, email, phone, job, update, updateId) {
    resetContactModel();
    
    if (name && name !== '-') {
        const contactInput = document.getElementById('contactname');
        contactInput.value = name;
        contactInput.parentElement.classList.add('move-form-label');
    }
    
    if (email && email !== '-') {
        const emailInput = document.getElementById('emailaddress');
        emailInput.value = email;
        emailInput.parentElement.classList.add('move-form-label');
    }
    
    if (job && job !== '-') {
        const jobInput = document.getElementById('job-position');
        jobInput.value = job;
        jobInput.parentElement.classList.add('move-form-label');
    }
    
    document.getElementById('phonenumbermodal').value = phone;
    
    if (update) {
        document.getElementById('save-contact').textContent = updateLabel;
        document.querySelector('.update-id').value = updateId;
    }
}

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.contact-card-remove')) {
        const contactCard = e.target.closest('.col-md-4');
        contactCard.remove();
        Toast.success(contactCardRemoveMessage);
    }
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.card-edit')) {
        const contactCard = e.target.closest('.contact-card');
        const contactName = Array.from(contactCard.querySelector('.contact-name').childNodes)
            .filter(node => node.nodeType === Node.TEXT_NODE)
            .map(node => node.textContent.trim())
            .join('');
            
        const contactJob = contactCard.querySelector('.contact-job').textContent.trim();
        const contactEmail = contactCard.querySelector('.contact-email a').textContent.trim();
        const contactPhone = contactCard.querySelector('.contact-phone').textContent.trim();
        const updateId = contactCard.getAttribute('id');

        setDataInContactModel(
            contactName,
            contactEmail,
            contactPhone,
            contactJob,
            true,
            updateId
        );
        document.getElementById('bs-contact-modal').classList.add('open');
    }
});

document.getElementById('save-contact').addEventListener('click', function(e) {
    const operationType = this.textContent;
    const contactName = document.getElementById('contactname').value || '-';
    const jobPosition = document.getElementById('job-position').value || '-';
    const emailAddress = document.getElementById('emailaddress').value || '-';
    const phoneNumber = document.getElementById('phonenumbermodal').value;

    const phoneInputtt = initializeIntlTelInput(
        preferredCountries, 
        countryCodeValueModal, 
        'phonenumbermodal',
        'phonenumbermodal-error'
    );

    if (phoneNumber === '' || !validatePhoneNumber(phoneInputtt, 'phonenumbermodal-error') && validateEmailAddress(emailAddress)) {
        Toast.error(allValidationMessage);
        return;
    }

    if (operationType === 'Save') {
        const contactDiv = '<div class="col-md-4">' +
            '<div class="contact-card" id="contact-card-id-' + (contactCardId++) + '">' +
            '<h2 class="contact-name">' + contactName + '</h2>' +
            '<a class="card-edit">' +
            '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
            '</a>' +
            '<a class="contact-card-remove">' +
            '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
            '</a>' +
            '<p class="contact-job">' + jobPosition + '</p>' +
            '<p class="contact-email"><a href="mailto:' + emailAddress + '">' + emailAddress + '</a></p>' +
            '<p class="contact-phone">' + phoneNumber + '</p>' +
            '</div>' +
            '</div>';
        document.getElementById('contact-card-container').insertAdjacentHTML('beforeend', contactDiv);
        Toast.success(tosterMessageSaveSuccess);
        document.getElementById('bs-contact-modal').classList.remove('open');
    } else {
        const contactCard = document.getElementById(document.querySelector('.update-id').value);
        contactCard.querySelector('.contact-name').textContent = contactName;
        contactCard.querySelector('.contact-job').textContent = jobPosition;
        contactCard.querySelector('.contact-email a').textContent = emailAddress;
        contactCard.querySelector('.contact-phone').textContent = phoneNumber;
        Toast.success(tosterMessageUpdateSuccess);
        document.getElementById('bs-contact-modal').classList.remove('open');
    }
    document.getElementById("bs-contact-modal").classList.remove("open");
    resetContactModel();
});
