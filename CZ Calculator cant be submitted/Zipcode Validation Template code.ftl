<style>
    .-cproject-img {
        width: 120px;
        height: 90px;
    }
    a{
        cursor:pointer;
    }
    .liferay-ddm-form-field-checkbox .liferay-ddm-form-field-tip{
    display:block!important;
    }
    .remove-margin {
        margin-bottom: 0px !important;
    }
    .grey-image {
        filter: grayscale(100%);
    }
    .new-element img {
        width: 250px;
        height: 170px;
        border-radius: 7px;
        border: 1px solid #ccc;
    }
    .drop-message{
        color: #003876;
        font-weight: 400;
        line-height: 16px;
        margin-top: 10px;
    }
    .suggestion-container {
        border: 1px solid #ccc;
        border-radius: 4px;
    }
    .loader {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #3498db;
        border-radius: 50%;
        width: 30px;
        height: 30px;
        animation: spin 1s linear infinite;
        margin: 5px 0 5px 49%;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
</style>

<script>
$(document).ready(function() {
    var timeoutId;
    
    // Handle address input and suggestions
    $(document).on("keyup", ".form-control[id*='AdresaStavby']", function() {
        var inputValue = $(this).val().trim();
        
        // Clear other fields when typing in address
        $("[id*='PSČ']").val(''); 
        $("[id*='Town']").val(''); 
        $("[id*='Street']").val('');
        
        // Enable PSC field for editing
        $("[id*='PSČ']").attr("disabled", false);
        
        // Show and clear suggestion container
        var parentOfGenAddress = $(this).parent();
        if ($(".suggestion-container").length === 0) {
            parentOfGenAddress.append("<div class='suggestion-container'></div>");
        }
        
        $(".suggestion-container").show().empty().html("<div class='loader'></div>");

        clearTimeout(timeoutId);
        
        timeoutId = setTimeout(function() {
            // Try geocode endpoint first (more accurate for addresses)
            const geocodeEndpoint = "https://api.mapy.cz/v1/geocode";
            $.ajax({
                url: geocodeEndpoint + "?lang=cs" + "&type=regional.address" + "&apikey=05iurSVgM4tRio7uAQRgnHNpIK4FoXDdJ8jcBHm-n6E" + "&query=" + inputValue + "&limit=5",
                type: "GET",
                success: function(response) {
                    var items = response.items;
                    var addrSuggestionContainer = $(".suggestion-container");
                    
                    $(".suggestion-container").empty();
                    
                    if(!items || items.length == 0) {
                        // If no results from geocode, try suggest endpoint as fallback
                        const suggestEndpoint = "https://api.mapy.cz/v1/suggest";
                        $.ajax({
                            url: suggestEndpoint + "?lang=cs" + "&apikey=05iurSVgM4tRio7uAQRgnHNpIK4FoXDdJ8jcBHm-n6E" + "&query=" + inputValue + "&limit=5",
                            type: "GET",
                            success: function(response) {
                                processResults(response);
                            },
                            error: function() {
                                addrSuggestionContainer.html('<p class="list-group-item list-group-item-action py-1">No results found.</p>');
                            }
                        });
                    } else {
                        processResults(response);
                    }
                },
                error: function() {
                    $(".suggestion-container").html('<p class="list-group-item list-group-item-action py-1">An error occurred. Please try again.</p>');
                }
            });
        }, 300);
    });

    function processResults(response) {
        var items = response.items;
        var addrSuggestionContainer = $(".suggestion-container");
        
        if(!items || items.length == 0) {
            addrSuggestionContainer.html('<p class="list-group-item list-group-item-action py-1">No results found.</p>');
        } else if (items && Array.isArray(items)) {
            addrSuggestionContainer.empty();
            for (var i = 0; i < items.length; i++) {
                var itemText = (items[i].name ? items[i].name : '') + 
                               (items[i].location ? ', ' + items[i].location : '') + 
                               (items[i].zip ? ', ' + items[i].zip : '');
                
                var itemElement = '<a class="list-group-item list-group-item-action py-1" ' + 
                                'name="' + (items[i].name || '') + '" ' +
                                'locationname="' + (items[i].location || '') + '" ' + 
                                'zipValues="' + (items[i].zip || '') + '">' + 
                                itemText + '</a>';
                addrSuggestionContainer.append(itemElement);
            }
        }
    }

    // Handle suggestion selection
    $(document).on("mousedown", "div.suggestion-container a", function(event) {
        event.stopPropagation();

        var selectedName = $(this).attr("name");
        var selectedLocation = $(this).attr("locationname");
        var selectedZipCode = $(this).attr("zipValues");
        
        // Fill all relevant fields
        $("[id*='AdresaStavby']").val(selectedName + ', ' + selectedLocation);
        
        if(selectedZipCode) {
            $("[id*='PSČ']").val(selectedZipCode);
            clearError();
        }
        
        // Try to extract town from location (first part before comma)
        if(selectedLocation) {
            var town = selectedLocation.split(',')[0];
            $("[id*='Town']").val(town);
        }
        
        // Set street from name
        $("[id*='Street']").val(selectedName);
        
        // Enable PSC field for manual editing
        $("[id*='PSČ']").attr("disabled", false);
        
        // Hide suggestions
        $('.suggestion-container').empty().hide();
    });

    // Hide suggestions when clicking outside
    $('body').on('click', function() { 
        $('.suggestion-container').hide(); 
    });

    // Validate PSC field
    async function validateZipCode(zipCode) {
        try {
            const response = await fetch("https://app.zipcodebase.com/api/v1/search?apikey=dabedd20-8c59-11ef-83b8-bf77ea0917a1&codes=" + zipCode + "&country=CZ");
            if (!response.ok) throw new Error('Network response was not ok');
            
            const data = await response.json();
            return !!data.results?.[zipCode]?.length;
        } catch (error) {
            console.error('Error validating zip code:', error);
            return false;
        }
    }

    // Error handling functions
    function showError(element, message) {
        $(element).parent().parent()
            .addClass("has-error")
            .find(".error-message")
            .removeClass('hide')
            .prop('hidden', false)
            .css('display', 'block')
            .text(message);
    }

    function clearError() {
        $('[id*="PSČ"]').parent().parent()
            .removeClass("has-error")
            .find(".error-message")
            .addClass('hide')
            .prop('hidden', true)
            .css('display', 'none')
            .text("");
    }

    // Validate PSC on blur
    $(document).on("blur", '[id*="PSČ"]', async function() {
        var pscValue = $(this).val();
        var currentElement = this;

        if(!pscValue) {
            showError(currentElement, "Toto pole je vyžadováno.");
            return;
        }

        try {
            const isValid = await validateZipCode(pscValue);
            isValid ? clearError() : showError(currentElement, 'Zadejte prosím platné české poštovní směrovací číslo.');
        } catch (error) {
            console.error('Error validating PSČ:', error);
        }
    });

    // Form validation helpers
    function checkRequiredFields(form) {
        let isValid = true;
        
        // Check PSC field
        form.find("[id*='PSČ']").each(function() {
            if(!$(this).val()) {
                showError(this, "Toto pole je vyžadováno.");
                isValid = false;
            }
        });

        // Check other required fields
        let emptyFields = form.find('.icon-asterisk')
            .closest('.form-group')
            .find('input[id*="_com_liferay_dynamic_data_lists_form_web_portlet_DDLFormPortlet_ddm"]')
            .filter(function() {
                return !this.value.trim();
            });

        if(emptyFields.length > 0) {
            isValid = false;
        }

        return isValid;
    }

    function areAllErrorsHidden(form) {
        var $visibleErrors = form.find('.error-message').filter(function() {
            return $(this).css('display') !== 'none';
        });
        return $visibleErrors.length === 0;
    }

    // Handle form submission
    $(document).on("click", '.btn-primary.lfr-ddm-form-submit', async function(event) {
        event.preventDefault();
        
        var currentForm = $(this).closest('form');
        var pscField = currentForm.find("[id*='PSČ']");
        var pscValue = pscField.val();
        
        if(checkRequiredFields(currentForm)) {
            try {
                const isValid = await validateZipCode(pscValue);
                if (isValid) {
                    clearError();
                    if (areAllErrorsHidden(currentForm)) {
                        currentForm.submit();
                    }
                } else {
                    showError(pscField, 'Zadejte prosím platné české poštovní směrovací číslo.');
                }
            } catch (error) {
                console.error('Error validating PSČ:', error);
            }
        }
    });

    // Image handling for projects
    if ($(".-cproject-img").length > 0) {
        var images = $(".-cproject-img");
    
        var newImageSources = [
            "/documents/46856796/71856702/zaklady-stropy.jpg",
            "/documents/46856796/71856702/podlahy-zpevnene-plochy.jpg",
            "/documents/46856796/71856702/ostatni-konstrukce.jpg",
            "/documents/46856796/71856702/monoliticke-konstrukce.jpg"
        ];
    
        images.each(function(index) {
            $(this).attr("src", newImageSources[index]);
        });
    }

    // Radio button image handling
    const imageSources = {
        'PožadavekNačerpáníBetonu': 'https://liferayqa.cemex.com/documents/46856796/46979694/1080_Aspect_Ratio-Podebrady-foundation-CZ-2021.jpeg',
        'DopravaBetonu': 'https://liferayqa.cemex.com/documents/46856796/46979694/1080_Aspect_Ratio-Readymix+truck+with+new+branding.jpeg'
    };
    
    var messages = {
        'DopravaBetonu': {
            unchecked: 'Vlastní doprava, přijedu si pro beton sám.',
            checked: 'Beton Vám dovezeme na stavbu.'
        },
        'PožadavekNačerpáníBetonu': {
            unchecked: 'Ne, nepotřebuji beton čerpat.',
            checked: 'Ano, potřebuji beton čerpat.'
        }
    };

    function updateDropdownAndSetupClickEvents() {
        ['PožadavekNačerpáníBetonu', 'DopravaBetonu'].forEach(function (idName) {
            updateDropdownInDom(idName);
            setupClickEvent(idName);
        });
    }

    function updateDropdownInDom(currentElem) {
        var commonId = '[id^="_com_liferay_dynamic_data_lists_form_web_portlet_DDLFormPortlet_ddm$$';
     
        var radioSpe = $('' + commonId + currentElem + '"]').first();
        if (radioSpe.length === 0) return; // Skip if element not found
        
        var radioValue = $('input[name="' + radioSpe.attr('name') + '"]:checked').val() === 'Ano';
        var parentEleTip = radioSpe.parent().parent().parent();
        var containerClass = 'new-element';
        var imageSrc = imageSources[currentElem];
        var messageForDrop = radioValue ? messages[currentElem].checked : messages[currentElem].unchecked;

        if (parentEleTip.find('.' + containerClass).length === 0) {
            parentEleTip.append(
                '<div class="' + containerClass + '">' +
                '<img class="' + (radioValue ? '' : 'grey-image') + '" src="' + imageSrc + '" alt="Cemex">' +
                '<p class="drop-message ' + currentElem + '-message' +'">'+ messageForDrop +'</p>' +
                '</div>'
            );
        } else {
            var imgElement = parentEleTip.find('.' + containerClass + ' img');
            var messagePara = parentEleTip.find('.drop-message');
            imgElement.attr('src', imageSrc);
            imgElement.toggleClass('grey-image', !radioValue);
            messagePara.text(messageForDrop);
        }
    }

    function setupClickEvent(currentElem) {
        var commonId = '[id^="_com_liferay_dynamic_data_lists_form_web_portlet_DDLFormPortlet_ddm$$';
        var radioSpe = $('' + commonId + currentElem + '"]').first();
        if (radioSpe.length === 0) return; // Skip if element not found
        
        var radioName = radioSpe.attr('name');
        $('input[name="' + radioName + '"]').off('click').on('click', function () {
            updateDropdownInDom(currentElem);
        });
    }

    // Initialize elements with retry logic
    var initCounter = 0;
    var initInterval = setInterval(function () {
        if (initCounter >= 10) {
            clearInterval(initInterval);
        } else {
            updateDropdownAndSetupClickEvents();
            initCounter++;
        }
    }, 1000);
});
</script>

<style>
    .suggestion-container {
        background-color: white;
        border: 1px solid #ccc;
        max-height: 200px;
        overflow-y: auto;
        position: absolute;
        width: 100%;
        z-index: 1000;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }

    .suggestion-container a {
        display: block;
        padding: 8px 12px;
        text-decoration: none;
        color: #333;
        border-bottom: 1px solid #eee;
    }

    .suggestion-container a:hover {
        background-color: #f5f5f5;
    }

    .loader {
        border: 2px solid #f3f3f3;
        border-radius: 50%;
        border-top: 2px solid #3498db;
        width: 20px;
        height: 20px;
        animation: spin 1s linear infinite;
        margin: 10px auto;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    .error-message {
        color: #dc3545;
        font-size: 0.875rem;
        margin-top: 0.25rem;
    }

    .has-error .form-control {
        border-color: #dc3545;
    }
</style>