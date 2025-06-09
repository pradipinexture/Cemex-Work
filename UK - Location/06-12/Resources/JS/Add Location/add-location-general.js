
// Load countris in UI
var countries = [
   { code: "HR", name: "Croatia"},
   { code: "CZ", name: "Czech Republic"},
   { code: "FR", name: "France"},
   { code: "DE", name: "Germany"},
   { code: "PL", name: "Poland"},
   { code: "ES", name: "Spain"},
   { code: "GB", name: "United Kingdom"},
   { code: "BA", name: "Bosnia and Herzegovina"},
   { code: "ME", name: "Montenegro"},
   { code: "RS", name: "Serbia"}
];

var countrySelect = document.getElementById("country");
var options = '<option value="" disabled="" selected="">Country</option>';
countries.forEach(function (country) {
    options += '<option value="' + country.name + '" ' + (country.code === currentCountry ? 'selected' : '') + '>' + country.name + '</option>';
});
countrySelect.innerHTML = options;


function genericValidations() {
   var requiredValidateIds = [
       'LocationTitle', 'Address', 'TownCity', 'Country', 
       'Postcode', 'PhoneNumber', 'GeolocationData'
   ];

   for (var field of requiredValidateIds) {
       if (field === 'GeolocationData') {
           var longitude = document.getElementById("longitude").value;
           var latitude = document.getElementById("latitude").value;
           if (longitude === '' || isNaN(longitude) || latitude === '' || isNaN(latitude)) {
               return false;
           }
       } else {
           var fieldElement = document.querySelector('.' + field);
           var fieldValue = fieldElement ? fieldElement.value : '';

           if (field === 'PhoneNumber') {
               var phoneInput = initializeIntlTelInput(
                   preferredCountries, 
                   countryCodeValue, 
                   'phonenumber',
                   "phoneNumber-error"
               );
               
               if (fieldValue === '' || !validatePhoneNumber(phoneInput, "phoneNumber-error")) {
                   return false;
               }
           } else if (field === 'Postcode') {
               var postcode = document.getElementById("postcode").value;
               if (!validatePostalCode(postcode)) {
                   return false;
               }
           } else {
               if (fieldValue === '') return false;
           }
       }
   }
   return true;
}

// Products categories related oprations
var selectedCategoryIds = new Set();

   var container = document.getElementById('selectedContainer'),
       dropdown = document.getElementById('optionsContainer'),
       select = document.getElementById('hiddenSelect');
   container.addEventListener('click', () => dropdown.classList.add('show'));
   document.getElementById("plant-label").onclick = function () { setTimeout(() => document.getElementById('optionsContainer').classList.add('show'), 10) };
   document.addEventListener('click', e => !e.target.closest('.multiselect') && dropdown.classList.remove('show'));
   dropdown.addEventListener('click', e => {
       if (e.target.classList.contains('multiselect-option')) {
           var value = e.target.dataset.value;
           if(!value) return;
           if (!selectedCategoryIds.has(value)) {
               selectedCategoryIds.add(value);
               container.insertAdjacentHTML('beforeend',
                   '<span class="multiselect-tag" data-value="' + value + '">' + e.target.textContent + '<span class="multiselect-tag-remove">×</span></span>');
               e.target.classList.add('selected');
           } else {
               selectedCategoryIds.delete(value);
               container.querySelector('[data-value="' + value + '"]').remove();
               e.target.classList.remove('selected');
           }
           togglePlantTypeLabel()
       }
   });
   container.addEventListener('click', e => {
       if (e.target.classList.contains('multiselect-tag-remove')) {
           var tag = e.target.parentNode;
           var value = tag.dataset.value;
           selectedCategoryIds.delete(value);
           tag.remove();
           dropdown.querySelector('[data-value="' + value + '"]').classList.remove('selected');
           togglePlantTypeLabel()
       }
   });


function selectCategory(idOrName) {
   var dropdown = document.getElementById('optionsContainer'),
       option = dropdown.querySelector('[data-value="' + idOrName + '"]') ||
           Array.from(dropdown.getElementsByClassName('multiselect-option'))
               .find(opt => opt.textContent.toLowerCase() === idOrName.toLowerCase());
   option && !selectedCategoryIds.has(option.dataset.value) && option.click();
   togglePlantTypeLabel()
}

function togglePlantTypeLabel() {
   var selectedContainer = document.getElementById('selectedContainer');
   var plantLabel = document.getElementById('plant-label');
   if (selectedContainer && plantLabel) {
       (selectedContainer.children.length > 0) ? plantLabel.classList.add('plant-label-focus') : plantLabel.classList.remove('plant-label-focus');
   }
}

function getProductHTML(productName, productCatId, productLink) {
   return '<div class="col-md-4">' +
       '<div class="pro-link-card" id="pro-link-card-id-' + (productCardId++) + '">' +
           '<h2 class="pro-link-name" id="' + productCatId + '">' + productName + '</h2>' +
           '<a class="pro-link-card-edit">' +
               '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<a class="pro-link-card-remove">' +
               '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<p class="pro-link">' + productLink + '</p>' +
       '</div>' +
   '</div>';
}

function generateProductHTMLAndAppend(productName, productCatId, productLink) {
   var productCard = getProductHTML(productName, productCatId, productLink);
   document.getElementById('pro-link-card-container').insertAdjacentHTML('beforeend', productCard);
}

function generateContactElement(contactName, contactJob, contactEmail, contactPhone) {
   return '<div class="col-md-4">' +
       '<div class="contact-card" id="contact-card-id-' + (contactCardId++) + '">' +
           '<h2 class="contact-name">' + contactName + '</h2>' +
           '<a class="card-edit">' +
               '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<a class="contact-card-remove">' +
               '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<p class="contact-job">' + contactJob + '</p>' +
           '<p class="contact-email"><a href="mailto:' + contactEmail + '">' + contactEmail + '</a></p>' +
           '<p class="contact-phone">' + contactPhone + '</p>' +
       '</div>' +
   '</div>';
}

function generateGMBDiv(publisher, fileData, description) {
   return "<div class='col-md-4'>" +
        "<div class='GMB-card' id='GMB-card-id-" + (GMBCardId++) + "'>" +
        "<h2 class='file-Publisher'>" + publisher +
        "</h2>" +
        "<a class='GMB-card-edit'>" +
        "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
        "</a>" +
        "<a class='GMB-card-remove'>" +
        "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
        "</a>" +
        "<h2 class='file-Description'>" + description +
        "</h2>" +
        "<p class='file-value' data-file-response='" + JSON.stringify(fileData) + "'>" + fileData.title + "</p>" +
        "</div>" +
        "</div>";
}

function generateFileCard(fileName, fileData) {
   return "<div class='col-md-4'>" +
        "<div class='file-card' id='file-card-id-" + (fileCardId++) + "'>" +
        "<h2 class='file-name'>" + fileName +
        "</h2>" +
        "<a class='file-card-edit'>" +
        "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
        "</a>" +
        "<a class='file-card-remove'>" +
        "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
        "</a>" +
        "<p class='file-value' data-file-response='"+JSON.stringify(fileData)+"'>" + fileData.title + "</p>" +
        "</div>" +
        "</div>";;
}

function generatePageElement(pageName, PageURL) {
   return '<div class="col-md-4">' +
       '<div class="page-card" id="page-card-id-' + (pageCardId++) + '">' +
           '<h2 class="page-name">' + pageName + '</h2>' +
           '<a class="page-card-edit">' +
               '<cwc-icon name="edit" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<a class="page-card-remove">' +
               '<cwc-icon name="close" color="true-blue"></cwc-icon>' +
           '</a>' +
           '<p class="page-url">' + PageURL + '</p>' +
       '</div>' +
   '</div>';
}

//Location Image related script
document.getElementById('fileInput').addEventListener('change', async function() {    
   var result = await uploadFileToLiferay('fileInput', documentMediaFolderId, null, true);

   if(!result) {
       this.value = '';
       Toast.error(fileNotUploadedRenameIt);
       return;
   }

   this.dataset.fileResponse = JSON.stringify(result);
   Toast.success("File uploaded successfully");
});

var fileInput = document.getElementById("fileInput");
var imagePreview = document.getElementById("imagePreview");
var removeButton = document.getElementById("removeButton");

fileInput.addEventListener("change", handleFiles);

function handleFiles() {
   var file = this.files[0];
    if (validateImage()) {
        var reader = new FileReader();
        reader.onload = function () {
            imagePreview.style.backgroundImage = "url(" + reader.result + ")";
            imagePreview.style.display = "block";
            removeButton.style.display = "block";
            fileInput.style.display = "none";
       };
       reader.readAsDataURL(file);
   }
}

removeButton.addEventListener("click", () => {
   imagePreview.style.backgroundImage = "none";
   fileInput.value = "";
   removeButton.style.display = "none";
   fileInput.style.display = "block";
   imagePreview.style.display = "none";
});


function validateImage() {
  var fileInputImage = document.getElementById('fileInput');
  if (fileInputImage && fileInputImage.files && fileInputImage.files.length > 0) {      
    var fileExtension = fileInputImage.files[0].name.split('.').pop().toLowerCase();
    var allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];

    if (allowedExtensions.indexOf(fileExtension) === -1) {
        fileInputImage.value = '';
        return false;
       }
   }
  return true;
}

document.addEventListener("DOMContentLoaded", function() {
    var editor1 = new RichTextEditor("#div_editor1");
});


var inputs = document.querySelectorAll('.form-item input');

function handleLabelMovement(input) {
    if(!input) return;
    var formItem = input.closest('.form-item');
    (input.value.trim()) ? formItem.classList.add('move-form-label') : formItem.classList.remove('move-form-label');
}

inputs.forEach(function(input) {
    var originalDescriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    
    Object.defineProperty(input, 'value', {
        get: function() {
            return originalDescriptor.get.call(this);
        },
        set: function(val) {
            originalDescriptor.set.call(this, val);
            handleLabelMovement(this);
        }
    });

    input.addEventListener('focus', function() {this.closest('.form-item').classList.add('move-form-label');});
    input.addEventListener('blur', function() {handleLabelMovement(this)});
    input.addEventListener('input', () => handleLabelMovement(this));

    handleLabelMovement(input);
});

document.addEventListener('click', function (e) {
    e = e || window.event;
    var target = e.target || e.srcElement;

    if (target.hasAttribute('data-toggle') && target.getAttribute('data-toggle') === 'popup') {
        if (target.hasAttribute('data-target')) {
            var m_ID = target.getAttribute('data-target');
            document.getElementById(m_ID).classList.add('open');
            e.preventDefault();
        }
    }

    if ((target.hasAttribute('data-dismiss') && target.getAttribute('data-dismiss') === 'popup') || target.classList.contains('popup')) {
        var popupDivs = document.getElementsByClassName('popup');
        if (popupDivs.length > 0) {
            for (var i = 0; i < popupDivs.length; i++) {
                if (popupDivs[i].classList.contains('open')) {
                    popupDivs[i].classList.remove('open');
                }
            }
        }
        e.preventDefault();
    }
}, false);

