let pageCardId = 1;

document.querySelector('.add-page').addEventListener('click', function() {
    resetPageModal();
});

function resetPageModal() {
    document.getElementById('pagename').value = '';
    document.getElementById('fileUrl').value = '';
    document.getElementById('save-page').textContent = saveLabel;
}

resetPageModal();

let updatePageId = null;

function setDataInPageModal(name, value, update) {
    resetPageModal();
    
    if (name && name !== '-') {
        const pagenameEl = document.getElementById('pagename');
        pagenameEl.value = name;
        pagenameEl.parentElement.classList.add('move-form-label');
    }

    if (value && value !== '-') {
        const fileUrlEl = document.getElementById('fileUrl');
        fileUrlEl.value = value;
        fileUrlEl.parentElement.classList.add('move-form-label');
    }

    if (update) {
        document.getElementById('save-page').textContent = updateLabel;
    }
}

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.page-card-remove')) {
        const pageCard = e.target.closest('.col-md-4');
        pageCard.remove();
        Toast.success(tosterMessageDeletedSuccess);
    }
});

document.body.addEventListener('click', function(e) {
    if (e.target.closest('.page-card-edit')) {
        const pageCard = e.target.closest('.page-card');
        const pageName = pageCard.querySelector('.page-name').textContent.trim();
        const pageValue = pageCard.querySelector('.page-url').textContent.trim();
        const updateIdd = pageCard.getAttribute('id');
        updatePageId = updateIdd;

        setDataInPageModal(
            pageName,
            pageValue,
            true
        );
        document.getElementById('bs-page-modal').classList.add('open');
    }
});

document.getElementById('save-page').addEventListener('click', function(e) {
    e.preventDefault();
    
    const operationType = this.textContent;
    const pagename = document.getElementById('pagename').value || '-';
    const fileUrl = document.getElementById('fileUrl').value || '-';

    if (!pagename || !fileUrl || fileUrl=="-" || pagename == "-") {
        Toast.error(fillRequiredField);
        return;
    }

    if (operationType === "Save") {
       const pageCard = "<div class='col-md-4'>" +
            "<div class='page-card' id='page-card-id-" + pageCardId++ + "'>" +
            "<h2 class='page-name'>" + pagename + "</h2>" +
            "<a class='page-card-edit'>" +
            "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<a class='page-card-remove'>" +
            "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
            "</a>" +
            "<p class='page-url'>" + fileUrl + "</p>" +
            "</div>" +
            "</div>";

        document.getElementById('page-card-container').insertAdjacentHTML('beforeend', pageCard);
        Toast.success(tosterMessageSaveSuccess);
    } else {
        if (updatePageId) {
            const pageCard = document.getElementById(updatePageId);
            pageCard.querySelector('.page-name').textContent = pagename;
            pageCard.querySelector('.page-url').textContent = fileUrl;
            Toast.success(tosterMessageUpdateSuccess);
        }
    }
	 document.getElementById("bs-page-modal").classList.remove("open");
    resetPageModal();
});
