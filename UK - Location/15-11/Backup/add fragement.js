document.addEventListener("DOMContentLoaded", function() {
    var editor1 = new RichTextEditor("#div_editor1");
    // editor1.setHTMLCode("Use inline HTML or setHTMLCode to init the default content.");
});


const inputs = document.querySelectorAll('.form-item input');

function handleLabelMovement(input) {
    if(!input) return;
    const formItem = input.closest('.form-item');
    (input.value.trim()) ? formItem.classList.add('move-form-label') : formItem.classList.remove('move-form-label');
}

inputs.forEach(function(input) {
    const originalDescriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    
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

// Product Type logic
var selectedCategoryIds = new Set();

document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('selectedContainer'),
        dropdown = document.getElementById('optionsContainer'),
        select = document.getElementById('hiddenSelect');
    container.addEventListener('click', () => dropdown.classList.add('show'));
    document.getElementById("plant-label").onclick = function () { setTimeout(() => document.getElementById('optionsContainer').classList.add('show'), 10) };
    document.addEventListener('click', e => !e.target.closest('.multiselect') && dropdown.classList.remove('show'));
    dropdown.addEventListener('click', e => {
        if (e.target.classList.contains('multiselect-option')) {
            const value = e.target.dataset.value;
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
            const tag = e.target.parentNode;
            const value = tag.dataset.value;
            selectedCategoryIds.delete(value);
            tag.remove();
            dropdown.querySelector('[data-value="' + value + '"]').classList.remove('selected');
            togglePlantTypeLabel()
        }
    });
});

function selectCategory(idOrName) {
    const dropdown = document.getElementById('optionsContainer'),
        option = dropdown.querySelector('[data-value="' + idOrName + '"]') ||
            Array.from(dropdown.getElementsByClassName('multiselect-option'))
                .find(opt => opt.textContent.toLowerCase() === idOrName.toLowerCase());
    option && !selectedCategoryIds.has(option.dataset.value) && option.click();
    togglePlantTypeLabel()
}
function togglePlantTypeLabel() {
    const selectedContainer = document.getElementById('selectedContainer');
    const plantLabel = document.getElementById('plant-label');
    if (selectedContainer && plantLabel) {
        (selectedContainer.children.length > 0) ? plantLabel.classList.add('plant-label-focus') : plantLabel.classList.remove('plant-label-focus');
    }
}

document.addEventListener('click', function (e) {
    // Prevent default behavior
    e = e || window.event;
    var target = e.target || e.srcElement;

    // Check if the element has a 'data-toggle' attribute for opening the modal
    if (target.hasAttribute('data-toggle') && target.getAttribute('data-toggle') === 'popup') {
        if (target.hasAttribute('data-target')) {
            var m_ID = target.getAttribute('data-target');
            document.getElementById(m_ID).classList.add('open');
            e.preventDefault();
        }
    }

    // Check if the element has a 'data-dismiss' attribute for closing the modal or if it's a background overlay
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