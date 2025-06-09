$(document).ready(function () {

    var submitButton = document.getElementById("save");
    var modelHading = document.getElementById("myModalLabel");
    if (articleIdFromUrl) {
        submitButton.innerText = updateLocationLabel;
        modelHading.innerText = updateLocationLabel;
    }
    if (articleIdFromUrl) {
        Liferay.Service(
            '/journal.journalarticle/get-article',
            {
                groupId: countryGroupId,
                articleId: articleIdFromUrl
            },
            function (webContent) {
                webData = webContent;

                (async () => {
                    const categories = await getWebcontentCategories(webContent.resourcePrimKey);
                    console.log(categories);
                    if (categories && categories.length !== 0) {
                        categories.forEach(function (cat) {
                            selectCategory(cat.categoryId)
                        })
                    }
                })();

                const parser = new DOMParser();
                const locationXmlDoc = parser.parseFromString(webContent.content, 'application/xml');

                const locationXMLRootChilds = locationXmlDoc.childNodes;
                if (locationXMLRootChilds && locationXMLRootChilds.length != 0) {
                    var allFieldElements = locationXMLRootChilds[0].children;

                    for (let i = 0; i < allFieldElements.length; i++) {
                        const locationElement = allFieldElements[i];
                        const elementName = locationElement.getAttribute('name');
                        if (!locationFieldsIds[elementName]) continue;

                        console.log(locationElement);
                        const elementContent = locationElement.querySelector('dynamic-content');
                        const elementContentValue = locationElement.querySelector('dynamic-content')?.textContent ?? ''

                        if (!elementContentValue) continue;
                        const elelemtChildren = locationElement.children;

                        if (elelemtChildren && elelemtChildren.length == 0) continue;

                        if (elementName == 'ContactDetail') {
                            var contactName = "", contactPhone = "", contactEmail = "", contactJob = "";

                            for (let j = 0; j < elelemtChildren.length; j++) {
                                const contactField = elelemtChildren[j];
                                var attrName = contactField.getAttribute('name');
                                var attrContent = contactField.querySelector('dynamic-content').textContent;

                                if (attrName == "JobPosition") contactJob = attrContent;
                                else if (attrName == "EmailAddress") contactEmail = attrContent;
                                else if (attrName == "PhoneNumber1") contactPhone = attrContent;
                                else if (attrName == "ContactName") contactName = attrContent;
                            }

                            $(locationFieldsIds[elementName]).append(generateContactElement(contactName, contactJob, contactEmail, contactPhone));
                        } else if (elementName == 'Products') {
                            if (elementContent.textContent) addProductDynamic(elementContent.textContent);
                        } else if (elementName.includes('day_Separator')) {
                            $(locationFieldsIds[elementName]).html("");

                            for (let j = 0; j < elelemtChildren.length; j++) {
                                const dayElem = elelemtChildren[j];
                                var attrName = dayElem.getAttribute('name'), timeValue = '';

                                if (attrName.includes('TimingSeparator')) {
                                    var openCloseElem = dayElem.children;
                                    const startTime = openCloseElem[0].querySelector('dynamic-content').textContent;
                                    const closeTime = openCloseElem[1].querySelector('dynamic-content').textContent;

                                    if (startTime && closeTime) timeValue = (startTime + " - " + closeTime);
                                }

                                var openCloseElemValue = dayElem.querySelector('dynamic-content').textContent;
                                if (openCloseElemValue == 'true') timeValue = "Closed";

                                if (timeValue) $(locationFieldsIds[elementName]).append("<input type='text' placeholder='—:— - —:—' value='" + timeValue + "'> ");
                            }
                        } else if (elementName == 'Country') {
                            var parts = elementContentValue.split(' - ');
                            if (parts.length === 2) $(locationFieldsIds[elementName]).val(parts[0].trim());
                            else $(locationFieldsIds[elementName]).val(elementContentValue);
                        } else if (elementName == 'GeolocationData') {
                            const geolocationData = JSON.parse(elementContentValue);
                            $(locationFieldsIds[elementName]['latitude']).val(geolocationData.latitude);
                            $(locationFieldsIds[elementName]['longitude']).val(geolocationData.longitude);
                            updateMap();
                        } else if (elementName == 'isYextRestrict') {
                            var isYext = false;
                            if (elementContentValue && elementContentValue == 'true') isYext = true;

                            $(locationFieldsIds[elementName]).attr("checked", isYext);
                        } else if (elementName == 'LocationImage') {
                            const imagePre = elementContentValue;
                            imageGlobal = locationElement;

                            $(locationFieldsIds[elementName]).css({
                                "background-image": "url(" + imagePre + ")",
                                "display": "block"
                            });
                        } else if (elementName == 'AddPage') {
                            var pageName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                            var pageURL = elelemtChildren[1].querySelector('dynamic-content').textContent;

                            if (pageName && pageURL) $(locationFieldsIds[elementName]).append(generatePageElement(pageName, pageURL));
                        } else if (elementName == 'ProductCard') {
                            (async function () {
                                var productName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                                var productLink = elelemtChildren[1].querySelector('dynamic-content').textContent;
                                const categoryId = await getCategoryIdByName(productName);
                                if (productName && categoryId) generateProductHTMLAndAppend(productName, categoryId, productLink);
                            })();
                        } else if (elementName == 'FileCard') {
                            var pageName = elelemtChildren[0].querySelector('dynamic-content').textContent;
                            var pageURL = elelemtChildren[1].querySelector('dynamic-content').textContent;

                            if (!pageURL || !pageName) continue;

                            const urlParts = pageURL.substring(1).split("/");

                            const locationPriceList = {
                                id: fileCardId,
                                groupId: urlParts[1],
                                folderId: urlParts[2],
                                fileName: urlParts[3],
                                uuid: urlParts[4].split("?")[0],
                                modifiedDate: urlParts[4].split("?")[1].split("=")[1]
                            };
                            fileValues.push(locationPriceList);

                            $(locationFieldsIds[elementName]).append(generateFileCard(pageName, pageURL.split('/').slice(-2, -1)[0]));
                        } else if (elementName == 'RichText') {
                            $("#div_editor1 iframe").contents().find("body").html(elementContentValue);
                        } else if (elementName == 'PublisherImages') {
                            var publisher = elelemtChildren[0].querySelector('dynamic-content').textContent;
                            var gmbFile = elelemtChildren[1].querySelector('dynamic-content').textContent;
                            var description = elelemtChildren[2].querySelector('dynamic-content').textContent;

                            if (!publisher || !gmbFile || !description) continue;

                            const urlPartss = gmbFile.substring(1).split("/");

                            if (urlPartss.length >= 5) {
                                GMBfileValues.push({
                                    id: GMBCardId,
                                    groupId: urlPartss[1],
                                    folderId: urlPartss[2],
                                    fileName: urlPartss[3],
                                    uuid: urlPartss[4].split("?")[0],
                                    modifiedDate: urlPartss[4].split("?")[1].split("=")[1]
                                });
                            }

                            $(locationFieldsIds[elementName]).append(generateGMBDiv(publisher, description, gmbFile.split('/').slice(-2, -1)[0]));
                        } else {
                            $(locationFieldsIds[elementName]).val(elementContentValue);
                        }
                    }

                    needFocusOnElement();
                }
            }
        );
    }

});