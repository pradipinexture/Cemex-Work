function getProductHTML(productName, productCatId, productLink) {
   return "<div class='col-md-4'>" +
             "<div class='pro-link-card' id='pro-link-card-id-" + (productCardId++) + "'>" +
                 "<h2 class='pro-link-name' id='"+productCatId+"'>" + productName + "</h2>" +
                 "<a class='pro-link-card-edit'>" +
                  "<cwc-icon name='edit' color='true-blue'></cwc-icon>" +
                  "</a>" +
                  "<a class='pro-link-card-remove'>" +
                  "<cwc-icon name='close' color='true-blue'></cwc-icon>" +
                  "</a>" +
                 "<p class='pro-link'>" + productLink + "</p>" +
             "</div>" +
         "</div>"
}

function generateProductHTMLAndAppend(productName, productCatId, productLink) {
      var productCard = getProductHTML(productName, productCatId, productLink);
      $('#pro-link-card-container').append(productCard);
}

$("#save-product").on("click", function (e) {
   
   e.preventDefault(); 
   var operationType = $("#save-product").text();

   var productCatId = $("#pro-link-name").val();
   var productName = $("#pro-link-name :selected").text();
   var productLink = $("#pro-link").val() || "-";
   
   if (!productCatId || !productLink) {
       Toast.danger("Please fill in all required fields.");
       return;
   }
  
   if (operationType === "Save") {
      generateProductHTMLAndAppend(productName, productCatId, productLink)

      Toast.success("${(tosterMessageSaveSuccess?has_content)?then(tosterMessageSaveSuccess, 'Data added successfully')}");
      $("#bs-product-modal").removeClass("open");
   }else {
        if(updateProductId) {
          var productCard = $('#' + updateProductId);   
          productCard.find(".pro-link-name").text(productName);
          productCard.find(".pro-link").text(productLink);
          Toast.success("${(tosterMessageUpdateSuccess?has_content)?then(tosterMessageUpdateSuccess, 'Data updated successfully')}");
          $("#bs-product-modal").removeClass("open");
       } else {
       }
   }
  resetProductModal();
}); 


$(".add-product").on("click", function () {
   resetProductModal();
});

function resetProductModal() {
   $("#pro-link-name").val("");
   $("#pro-link").val("");
   $("#save-product").text(saveLabel);
}

function setDataInProductModal(name, value, update) {
   resetProductModal();
   if (name && name !== '-') {
      (async function() {
         const categoryId = await getCategoryIdByName(name);
         $("#pro-link-name").val(categoryId); 
      })();
   }

   if (value && value !== '-') {
       $("#pro-link").val(value); 
       $("#pro-link").parent().addClass("focused");
   }

   if (update) {
       $("#save-product").text(updateLabel);
   }
}