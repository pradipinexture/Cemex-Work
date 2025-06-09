let productCardId = 1;

function getProductHTML(productName, productCatId, productLink) {
    return "<div class='col-md-4'>" +
           "<div class='pro-link-card' id='pro-link-card-id-" + (productCardId++) + "'>" +
           "<h2 class='pro-link-name' id='" + productCatId + "'>" + productName + "</h2>" +
           "<a class='pro-link-card-edit'>" +
           "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
           "</a>" +
           "<a class='pro-link-card-remove'>" +
           "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
           "</a>" +
           "<p class='pro-link'>" + productLink + "</p>" +
           "</div>" +
           "</div>";
}

function generateProductHTMLAndAppend(productName, productCatId, productLink) {
    const productCard = getProductHTML(productName, productCatId, productLink);
    document.getElementById('pro-link-card-container').insertAdjacentHTML('beforeend', productCard);
}

document.getElementById('save-product').addEventListener('click', function(e) {
    e.preventDefault();
    
    const operationType = document.getElementById('save-product').textContent;
    const productCatIdElement = document.getElementById('pro-link-name');
    const productCatId = productCatIdElement.value;
    const productName = productCatIdElement.options[productCatIdElement.selectedIndex].text;
    const productLink = document.getElementById('pro-link').value || '-';
    
    if (!productCatId || !productLink || productCatId=="-" || productLink=="-") {
        console.log(fillRequiredField);
        return;
    }
    
    if (operationType === "Save") {
        generateProductHTMLAndAppend(productName, productCatId, productLink);
        console.log(tosterMessageSaveSuccess);
        document.getElementById('bs-product-modal').classList.remove('open');
    } else {
        if (updateProductId) {
            const productCard = document.getElementById(updateProductId);
            productCard.querySelector('.pro-link-name').textContent = productName;
            productCard.querySelector('.pro-link').textContent = productLink;
            console.log(tosterMessageUpdateSuccess);
            document.getElementById('bs-product-modal').classList.remove('open');
        }
    }
    resetProductModal();
});

document.querySelector('.add-product').addEventListener('click', function() {
    resetProductModal();
});

function resetProductModal() {
    document.getElementById('pro-link-name').value = "";
    document.getElementById('pro-link').value = "";
    document.getElementById('save-product').textContent = saveLabel;
}

function setDataInProductModal(name, value, update) {
    resetProductModal();
    
    if (name && name !== '-') {
        document.getElementById('pro-link-name').value = name;
    }
    
    if (value && value !== '-') {
        const proLinkElement = document.getElementById('pro-link');
        proLinkElement.value = value;
        proLinkElement.parentElement.classList.add('move-form-label');
    }
    
    if (update) {
        document.getElementById('save-product').textContent = updateLabel;
    }
}

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.pro-link-card-remove')) {
        const productCard = e.target.closest('.col-md-4');
        productCard.remove();
        console.log(tosterMessageDeletedSuccess);
    }
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.pro-link-card-edit')) {
        const productCard = e.target.closest('.pro-link-card');
        const productName = productCard.querySelector('.pro-link-name').textContent.trim();
        const productLink = productCard.querySelector('.pro-link').textContent.trim();
        updateProductId = productCard.getAttribute('id');
        
        setDataInProductModal(
            productName,
            productLink,
            true
        );
        document.getElementById('bs-product-modal').classList.add('open');
    }
});