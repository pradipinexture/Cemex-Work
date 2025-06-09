var productCardId = 1;

document.getElementById('save-product').addEventListener('click', function(e) {
    e.preventDefault();
    
    const operationType = document.getElementById('save-product').textContent;
    const productCatIdElement = document.getElementById('pro-link-name');
    const productCatId = productCatIdElement.value;
    const productName = productCatIdElement.options[productCatIdElement.selectedIndex].text;
    const productLink = document.getElementById('pro-link').value || '-';
    
    if (!productCatId || !productLink || productCatId=="-" || productLink=="-") {
        Toast.error(fillRequiredField);
        return;
    }
    
    if (operationType === "Save") {
        generateProductHTMLAndAppend(productName, productCatId, productLink);
        Toast.success(tosterMessageSaveSuccess);
        document.getElementById('bs-product-modal').classList.remove('open');
    } else {
        if (updateProductId) {
            const productCard = document.getElementById(updateProductId);
            productCard.querySelector('.pro-link-name').textContent = productName;
            productCard.querySelector('.pro-link').textContent = productLink;
            Toast.success(tosterMessageUpdateSuccess);
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
        Toast.success(tosterMessageDeletedSuccess);
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
