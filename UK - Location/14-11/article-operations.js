document.addEventListener('DOMContentLoaded', function () {
    const submitButton = document.getElementById("save");
    const modelHeading = document.getElementById("myModalLabel");
    
    if (articleIdFromUrl) {
        submitButton.innerText = updateLocationLabel;
        modelHeading.innerText = updateLocationLabel;
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
                            selectCategory(cat.categoryId);
                        });
                    }
                })();

                const parser = new DOMParser();
                const locationXmlDoc = parser.parseFromString(webContent.content, 'application/xml');

                const locationXMLRootChilds = locationXmlDoc.childNodes;
                if (locationXMLRootChilds && locationXMLRootChilds.length != 0) {
                    const allFieldElements = locationXMLRootChilds[0].children;

                    for (let i = 0; i < allFieldElements.length; i++) {
                        const locationElement = allFieldElements[i];
                        const elementName = locationElement.getAttribute('name');
                        if (!locationFieldsIds[elementName]) continue;

                        console.log(locationElement);
                        const elementContent = locationElement.querySelector('dynamic-content');
                        const elementContentValue = locationElement.querySelector('dynamic-content')?.textContent ?? '';

                        if (!elementContentValue) continue;
                        const elementChildren = locationElement.children;

                        if (elementChildren && elementChildren.length == 0) continue;

                        if (elementName == 'ContactDetail') {
                            let contactName = "", contactPhone = "", contactEmail = "", contactJob = "";

                            for (let j = 0; j < elementChildren.length; j++) {
                                const contactField = elementChildren[j];
                                const attrName = contactField.getAttribute('name');
                                const attrContent = contactField.querySelector('dynamic-content').textContent;

                                if (attrName == "JobPosition") contactJob = attrContent;
                                else if (attrName == "EmailAddress") contactEmail = attrContent;
                                else if (attrName == "PhoneNumber1") contactPhone = attrContent;
                                else if (attrName == "ContactName") contactName = attrContent;
                            }

                            document.querySelector(locationFieldsIds[elementName])
                                .insertAdjacentHTML('beforeend', generateContactElement(contactName, contactJob, contactEmail, contactPhone));
                        } else if (elementName == 'Products') {
                            if (elementContent.textContent) addProductDynamic(elementContent.textContent);
                        } else if (elementName.includes('day_Separator')) {
                            const element = document.querySelector(locationFieldsIds[elementName]);
                            element.innerHTML = "";

                            for (let j = 0; j < elementChildren.length; j++) {
                                const dayElem = elementChildren[j];
                                const attrName = dayElem.getAttribute('name');
                                let timeValue = '';

                                if (attrName.includes('TimingSeparator')) {
                                    const openCloseElem = dayElem.children;
                                    const startTime = openCloseElem[0].querySelector('dynamic-content').textContent;
                                    const closeTime = openCloseElem[1].querySelector('dynamic-content').textContent;

                                    if (startTime && closeTime) timeValue = (startTime + " - " + closeTime);
                                }

                                const openCloseElemValue = dayElem.querySelector('dynamic-content').textContent;
                                if (openCloseElemValue == 'true') timeValue = "Closed";

                                if (timeValue) {
                                    element.insertAdjacentHTML('beforeend', 
                                        `<input type='text' placeholder='—:— - —:—' value='${timeValue}'> `);
                                }
                            }
                        } else if (elementName == 'Country') {
                            const element = document.querySelector(locationFieldsIds[elementName]);
                            const parts = elementContentValue.split(' - ');
                            element.value = parts.length === 2 ? parts[0].trim() : elementContentValue;
                        } else if (elementName == 'GeolocationData') {
                            const geolocationData = JSON.parse(elementContentValue);
                            document.querySelector(locationFieldsIds[elementName]['latitude']).value = geolocationData.latitude;
                            document.querySelector(locationFieldsIds[elementName]['longitude']).value = geolocationData.longitude;
                            updateMap();
                        } else if (elementName == 'isYextRestrict') {
                            const isYext = elementContentValue && elementContentValue == 'true';
                            document.querySelector(locationFieldsIds[elementName]).checked = isYext;
                        } else if (elementName == 'LocationImage') {
                            const imagePre = elementContentValue;
                            imageGlobal = locationElement;

                            const element = document.querySelector(locationFieldsIds[elementName]);
                            element.style.backgroundImage = `url(${imagePre})`;
                            element.style.display = "block";
                        } else if (elementName == 'AddPage') {
                            const pageName = elementChildren[0].querySelector('dynamic-content').textContent;
                            const pageURL = elementChildren[1].querySelector('dynamic-content').textContent;

                            if (pageName && pageURL) {
                                document.querySelector(locationFieldsIds[elementName])
                                    .insertAdjacentHTML('beforeend', generatePageElement(pageName, pageURL));
                            }
                        } else if (elementName == 'ProductCard') {
                            (async function () {
                                const productName = elementChildren[0].querySelector('dynamic-content').textContent;
                                const productLink = elementChildren[1].querySelector('dynamic-content').textContent;
                                const categoryId = await getCategoryIdByName(productName);
                                if (productName && categoryId) generateProductHTMLAndAppend(productName, categoryId, productLink);
                            })();
                        } else if (elementName == 'FileCard') {
                            const pageName = elementChildren[0].querySelector('dynamic-content').textContent;
                            const pageURL = elementChildren[1].querySelector('dynamic-content').textContent;

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

                            document.querySelector(locationFieldsIds[elementName])
                                .insertAdjacentHTML('beforeend', generateFileCard(pageName, pageURL.split('/').slice(-2, -1)[0]));
                        } else if (elementName == 'RichText') {
                            const editorIframe = document.querySelector("#div_editor1 iframe");
                            editorIframe.contentDocument.body.innerHTML = elementContentValue;
                        } else if (elementName == 'PublisherImages') {
                            const publisher = elementChildren[0].querySelector('dynamic-content').textContent;
                            const gmbFile = elementChildren[1].querySelector('dynamic-content').textContent;
                            const description = elementChildren[2].querySelector('dynamic-content').textContent;

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

                            document.querySelector(locationFieldsIds[elementName])
                                .insertAdjacentHTML('beforeend', generateGMBDiv(publisher, description, gmbFile.split('/').slice(-2, -1)[0]));
                        } else {
                            document.querySelector(locationFieldsIds[elementName]).value = elementContentValue;
                        }
                    }

                    needFocusOnElement();
                }
            }
        );
    }
});