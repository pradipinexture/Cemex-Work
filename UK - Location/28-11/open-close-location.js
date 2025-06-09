document.addEventListener('click', async function(e) {
    if (e.target.matches('.open-location, .close-location')) {
        e.preventDefault();
        showLoader(true);

        const entryId = e.target.getAttribute('data-entry-value');
        const isOpen = e.target.classList.contains('open-location');
        const row = e.target.closest('tr');
        
        if (!checkLocationStatus(row, isOpen ? 'Open' : 'Closed')) return;

        try {
            var opclLoc = await openOrCloseLocation(entryId, !isOpen);
            Toast.success(opclLoc.titleCurrentValue + " location marked as " + (isOpen ? "Open" : "Close") + " successfully.");
            updateLocationCloseField(row, !isOpen);
        } catch (error) {
            console.error("Error updating location:", error);
            Toast.error("Location is not "+(isOpen ? "opened":"closed"));
        }
        showLoader();
    } else if (e.target.matches('#open-locations, #close-locations')) {
        e.preventDefault();
        const isOpen = e.target.id.includes('open-locations');
        const selectedRows = getSelectedRows();

        if (!selectedRows?.length) {
            Toast.error(warnExportSelect);
            return;
        }

        try {
            await Promise.all(
                selectedRows.map(async (row) => {
                    var opclLoc = await openOrCloseLocation(row.id, !isOpen);
                    Toast.success(opclLoc.titleCurrentValue + " location marked as " + (isOpen ? "Open" : "Close") + " successfully.");

                    const cells = document.querySelectorAll('td.location-id');
                    const matchingCell = Array.from(cells).find(cell => cell.textContent.trim() === row.id);
                    const tableRow = matchingCell?.closest('tr');

                    if (tableRow) {
                        updateLocationCloseField(tableRow, !isOpen);
                        delete selectedRowsMap[row.id];
                    }
                })
            );
        } catch (error) {
            Toast.error("Failed to update locations as " + (isOpen ? "opened":"closed"));
            console.error("Error updating locations:", error);
        }
    }
});

function checkLocationStatus(row, desiredStatus) {
    const currentStatus = row.querySelector('td:first-child div').textContent.trim();
    
    if (currentStatus === desiredStatus) {
        Toast.error("Location is already "+currentStatus);
        showLoader();
        return false;
    }
    return true;
}

function updateLocationCloseField(row, isClosed) {
    const checkbox = row.querySelector('input.checkbox');
    
    if (checkbox) {
        checkbox.checked = false;
    }

    const statusCell = row.querySelector('td:first-child div');
    if (statusCell) {
        statusCell.className = isClosed ? 'red' : 'green';
        statusCell.textContent = isClosed ? 'Closed' : 'Open';
    }
}

async function openOrCloseLocation(locationId, isClosed) {

    try {
        const webContent = await getArticle(locationId);
        const updatedXMLString = isClosedXMlOperations(webContent.content, isClosed);
        const categories = await getWebcontentCategories(webContent.resourcePrimKey);

        let articleProductCategories = [];
        if (categories && categories.length !== 0) {
            articleProductCategories = await Promise.all(categories.map(async (cat) => {
                return cat.categoryId;
            }));
        }

        console.log(webContent);
        return new Promise((resolve, reject) => {
            Liferay.Service(
                '/journal.journalarticle/update-article',
                createWebContentObject(webContent, updatedXMLString, articleProductCategories),
                (result) => {
                    if (result) {resolve(result);} 
                    else {reject(new Error('Failed to update article'));}
                }
            );
        });
    } catch (error) {
        console.error("Error in openOrCloseLocation:", error);
        Toast.error("Failed to update "+ webContent.titleCurrentValue+" location as "+(isClosed ? "Close":"Open"));
    }
}

function isClosedXMlOperations(webContentData, valueForUpdateOfClosed) {
    const parser = new DOMParser();
    const xmlDocIsCls = parser.parseFromString(webContentData, 'application/xml');
    const isClosedElement = xmlDocIsCls.querySelector('dynamic-element[field-reference="isLocationClosed"]');

    if (isClosedElement) {
        const dynamicContent = isClosedElement.querySelector('dynamic-content');

        if(dynamicContent) {
            dynamicContent.textContent = '';
            dynamicContent.appendChild(xmlDocIsCls.createCDATASection(valueForUpdateOfClosed));
        } else {
            const newDynamicContent = xmlDocIsCls.createElement('dynamic-content');
            newDynamicContent.setAttribute('language-id', themeDisplay.getLanguageId());
            newDynamicContent.appendChild(xmlDocIsCls.createCDATASection(valueForUpdateOfClosed));
            isClosedElement.appendChild(newDynamicContent);
        }

    } else {
        const dynamicElement = xmlDocIsCls.createElement('dynamic-element');
        var isClosedConfig = locationFieldsIds.isLocationClosed;
        const attributes = {
            'name': isClosedConfig.xmlFieldName,
            'field-reference': "isLocationClosed",
            'type': isClosedConfig.type,
            'index-type': 'keyword',
            'instance-id': generateRandomString(6)
        };
        
        Object.entries(attributes).forEach(([key, value]) => {dynamicElement.setAttribute(key, value);});

        const dynamicContent = xmlDocIsCls.createElement('dynamic-content');
        dynamicContent.setAttribute('language-id', themeDisplay.getLanguageId());
        dynamicContent.appendChild(xmlDocIsCls.createCDATASection(valueForUpdateOfClosed));
        dynamicElement.appendChild(dynamicContent);
        xmlDocIsCls.documentElement.appendChild(dynamicElement);
    }

    return new XMLSerializer().serializeToString(xmlDocIsCls);
}