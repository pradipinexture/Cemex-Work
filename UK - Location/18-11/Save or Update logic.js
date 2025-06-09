var coutryLanguageId = themeDisplay.getLanguageId();

var xmlBuilder;
    
function formDataToXMLString() {
    xmlBuilder = document.implementation.createDocument(null, null);

    const declaration = xmlBuilder.createProcessingInstruction('xml', 'version="1.0"');
    xmlBuilder.appendChild(declaration);

    var rootElement = xmlBuilder.createElement('root');
    rootElement.setAttribute('available-locales', '' + coutryLanguageId + '');
    rootElement.setAttribute('default-locale', '' + coutryLanguageId + '');
    xmlBuilder.appendChild(rootElement);

    for (var fieldId in locationFieldsIds) {

        var config = locationFieldsIds[fieldId];
        var instanceId = fieldId.toLowerCase();

        if (fieldId === 'OpeningHours') {
            processOpeningHours(fieldId, config);
        } else if (fieldId === 'ContactDetail') {
            
        } else if (fieldId === 'FileCard') {
            
        } else if (fieldId === 'PublisherImages') {
            
        } else if (fieldId === 'AddPage') {
            
        } else if (fieldId === 'ProductCard') {
            
        } else if (fieldId === 'LocationImage') {
            
        } else {
            processSimpleField(fieldId, config);
        }

    }

    return new XMLSerializer().serializeToString(xmlBuilder);
}

console.log(formDataToXMLString())

function getRandomString(length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * characters.length));
    }
    return result;
}

function processSimpleField(fieldId, config) {
    console.log(config)
    var field = document.querySelector(config.elementId);
    if (field) {
        var fieldValue;

        if(fieldId == "RichText") {
            fieldValue = document.querySelector("#div_editor1 iframe").contentDocument.body.innerHTML;
        } else if(fieldId == "isYextRestrict") {
            fieldValue = field.checked;
            if(!fieldValue) return;
        } else if(fieldId == "Geolocation") {
            fieldValue = '{"latitude":"' + document.querySelector(config.latitude.elementId).value + '","longitude":"' + document.querySelector(config.longitude.elementId).value + '"}';
        } else fieldValue = field.value;

        createDynamicElement(config.xmlFieldName, fieldId, config.type, fieldValue, true);
    }
}

function processOpeningHours(fieldId, config) {
    days.forEach(function(day, index) {
        var containerId = day.toLowerCase() + config.elementId;
        var dayHoursContainer = document.querySelector('#' + containerId).children;
        var isClosed = false;
        var dayDynamicElementParent = getDynamicElement(config.xmlFieldName, fieldId, config.type, '');

        dayDynamicElementParent.appendChild(createDynamicElement(config.nestedFields.dayName.xmlFieldName, "DayName", config.nestedFields.dayName.type, day, false));
        
        if(dayHoursContainer.length == 1 && dayHoursContainer[0].value == "Closed") {
            isClosed = true;
            var startCloseParent = getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');

            startCloseParent.appendChild(createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, '', false));
            startCloseParent.appendChild(createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, '', false));

            dayDynamicElementParent.appendChild(startCloseParent)
        } else {
            document.querySelectorAll('#' +containerId+ " input").forEach((element) => {
                var startCloseParent = getDynamicElement(config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.xmlFieldName, config.nestedFields.timeSlots.type, '');
                
                startCloseParent.appendChild(createDynamicElement(config.nestedFields.timeSlots.nestedFields.open.xmlFieldName, "Open", config.nestedFields.timeSlots.nestedFields.open.type, element.value.split("-")[0], false));
                startCloseParent.appendChild(createDynamicElement(config.nestedFields.timeSlots.nestedFields.close.xmlFieldName, "Close", config.nestedFields.timeSlots.nestedFields.close.type, element.value.split("-")[1], false));

                dayDynamicElementParent.appendChild(startCloseParent);
            })
        }
        
        dayDynamicElementParent.appendChild(createDynamicElement(config.nestedFields.isClosed.xmlFieldName, "isClosed", config.nestedFields.isClosed.type, isClosed, false));

        xmlBuilder.documentElement.appendChild(dayDynamicElementParent);
    });
}

function getDynamicElement(name, fieldReference, type, indexType) {
    var dynamicElement = xmlBuilder.createElement('dynamic-element');
    dynamicElement.setAttribute('name', name);
    dynamicElement.setAttribute('field-reference', fieldReference);
    dynamicElement.setAttribute('type', type);
    dynamicElement.setAttribute('instance-id', (fieldReference + name + getRandomString(5)));
    dynamicElement.setAttribute('index-type', indexType);
    return dynamicElement;
}

function createDynamicElement(name, fieldReference, type, value, appendToRoot) {
    var dynamicElement = xmlBuilder.createElement('dynamic-element');
    dynamicElement.setAttribute('name', name);
    dynamicElement.setAttribute('field-reference', fieldReference);
    dynamicElement.setAttribute('type', type);
    dynamicElement.setAttribute('index-type', 'keyword');
    dynamicElement.setAttribute('instance-id', (fieldReference + name + getRandomString(5)));
    
    var dynamicContent = xmlBuilder.createElement('dynamic-content');
    dynamicContent.setAttribute('language-id', '' + coutryLanguageId + '');

    var cdata = xmlBuilder.createCDATASection(value ?? '');
    dynamicContent.appendChild(cdata);
    dynamicElement.appendChild(dynamicContent);

    if (appendToRoot) {
        xmlBuilder.documentElement.appendChild(dynamicElement);
    }

    return dynamicElement;
}