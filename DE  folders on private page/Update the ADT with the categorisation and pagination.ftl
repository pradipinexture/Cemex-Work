<style type="text/css">
    @media screen and (min-width: 1024px) {
    	.item-card {
    		margin-right:22px;
    	}
    }
    
    .item-card {
    	margin-bottom: 20px;
    	border: 1px solid #ccc;
    }
    
    .item-card .item-card__image {
    	border-bottom: 1px solid #ccc;
    }

    .item-card .item-card__image > img {
    	width: 100%;
    	min-height: 180px;
    	max-height: 180px;
    }
    
    .item-card .item-card__image .item-card__image-background {
    	width: 100%;
    	height: 180px;
    	position: relative;
    	background-repeat: no-repeat;
    	background-position: center;
    	background-size: cover;
    }
    
    .item-card .item-card__info {
    	padding: 20px;
    }
    
    .item-card__publish-date, .item-card__category {
    	font-size: 12px;
    	text-align: left;
    	color: #5a5d66;
    }

    .item-card__category {
    	font-weight: bold;
    }
    
    .item-card__title {
    	margin-top: 10px;
    	height: 100px;
    	word-break: break-word;
    	font-weight: 500;
    }
    
    .download-button-link {
    	display: inline-block;
		border: 1px solid #000;
		color: #000;
		padding: 10px 36px;
	}
	
	.download-button-link__label {
		font-size: 10px;
		font-weight: 900;
		line-height: 1;
		letter-spacing: 2px;
		text-align: center;
		text-transform: uppercase;
	}
    
    .item-card__separator {
    	background-color: #5a5d66;
    	display: inline-block;
    	width: 1px;
    	height: 11px;
    	margin: 0 3px;
    	margin-bottom: -1px;
    }

    .item-card__features {
    	height: 45px;
    }
    
    .item-no-results {
      margin-bottom:20px;
    }
    
    .lfr-pagination.js-documents-and-downloads .pager li>a:focus {
      background-color: inherit;
    }
    .category-filter {
        max-width: 200px;
        margin-bottom: 20px;
    }

    .pagination-container {
        margin-top: 20px;
    }
    
    .pagination {
        display: inline-flex;
        list-style: none;
        padding: 0;
    }
    
    .pagination li {
        margin: 0 5px;
    }
    
    .pagination li a {
        padding: 8px 12px;
        border: 1px solid #ddd;
        cursor: pointer;
    }
    
    .pagination li.active a {
        background-color: #007bff;
        color: white;
        border-color: #007bff;
    }
    .category-filter {
        display: flex;
        align-items: center;
        gap: 15px;
        margin: 20px 0;
    }

    .category-filter select {
        appearance: none;
        background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' fill='%23333' viewBox='0 0 16 16'%3E%3Cpath d='M8 11L3 6h10z'/%3E%3C/svg%3E") no-repeat right 12px center;
        border: 1px solid #ddd;
        border-radius: 4px;
        color: #333;
        cursor: pointer;
        font-size: 14px;
        width: 120px;
        padding: 8px 35px 8px 12px;
        transition: border-color 0.2s;
    }

    .category-filter select:hover {
        border-color: #999;
    }

    .category-filter select:focus {
        border-color: #666;
        outline: none;
        box-shadow: 0 0 0 2px rgba(0,0,0,0.1);
    }

    .category-filter label {
        color: #333;
        font-size: 14px;
        font-weight: 500;
    }
    .item-card {
        transition: opacity 0.3s ease, transform 0.3s ease;
    }

    .item-card.fade-out {
        opacity: 0;
        transform: scale(0.95);
    }

    .item-card.fade-in {
        opacity: 1;
        transform: scale(1);
    }
</style>

<#assign parentVocId = 96167972 />
<#assign assetCategoryLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetCategoryLocalService")/>
<#assign topLevelCategories = assetCategoryLocalService.getVocabularyRootCategories(parentVocId, -1, -1, null)>

<div class="container">
    <div class="category-filter mb-4">
        <label>Filter by Category:</label>
        <select class="form-control" id="categoryFilter">
            <option value="all">All</option>
                <#if topLevelCategories?? && topLevelCategories?has_content>
                    <#list topLevelCategories as category>
                        <option value="${category.getName()}">${category.getName()}</option>
                    </#list>
                </#if>
        </select>
    </div>

    <div class="row" id="documentCards">
    <#if entries?has_content>
        ${entries?size}
        <#assign PortalAssetRenderer = staticUtil["com.liferay.asset.kernel.model.AssetRenderer"] />
        <#assign FileVersion = staticUtil["com.liferay.portal.kernel.repository.model.FileVersion"] />
        <#assign StringPool = staticUtil["com.liferay.portal.kernel.util.StringPool"] />
        <#assign HttpUtil = staticUtil["com.liferay.portal.kernel.util.HttpUtil"] />
        <#assign HtmlUtil = staticUtil["com.liferay.portal.kernel.util.HtmlUtil"] />
        <#assign DLAppLocalService = serviceLocator.findService("com.liferay.document.library.kernel.service.DLAppLocalService") />
        <#assign defaultCommonFolder = DLAppLocalService.getFolder(themeDisplay.getScopeGroupId(), 0, "Common") />
        <#assign defaultIconFolder = DLAppLocalService.getFolder(themeDisplay.getScopeGroupId(), defaultCommonFolder.getFolderId(), "Icons") />
        <#assign defaultImage = DLAppLocalService.getFileEntry(themeDisplay.getScopeGroupId(), defaultIconFolder.getFolderId(), "document-default.jpg") />
        <#assign defaultImageURL = themeDisplay.getPortalURL() + themeDisplay.getPathContext() + "/documents/" + defaultImage.getGroupId() + StringPool.SLASH + defaultImage.getFolderId() + StringPool.SLASH + HttpUtil.encodeURL(HtmlUtil.unescape(defaultImage.getTitle())) + StringPool.SLASH + defaultImage.getUuid() />
        <#list entries as entry>
            <#assign assetRenderer = entry.getAssetRenderer() />
            <#assign entryTitle = htmlUtil.escape(assetRenderer.getTitle(locale)) />
            <#assign dateFormat = "MMMMM dd, yyyy" />
            <#assign dlFileEntryId = assetRenderer.getClassPK() />
            <#assign fileEntry = DLAppLocalService.getFileEntry(dlFileEntryId)  />
            <#assign assetEntryLocalService = serviceLocator.findService("com.liferay.asset.kernel.service.AssetEntryLocalService")/>
            <#assign className = "com.liferay.document.library.kernel.model.DLFileEntry" />
            <#assign assetEntry = assetEntryLocalService.getEntry(className, dlFileEntryId) />
            <#assign categories = assetEntry.getCategories() />

            <#assign fileVersion = fileEntry.getLatestFileVersion() />
            <#assign downloadURL = themeDisplay.getPortalURL() + themeDisplay.getPathContext() + "/documents/" + fileEntry.getGroupId() + StringPool.SLASH + fileEntry.getFolderId() + StringPool.SLASH + HttpUtil.encodeURL(HtmlUtil.unescape(fileEntry.getTitle())) + StringPool.SLASH + fileEntry.getUuid() + "?version=" + fileVersion.getVersion() />

            <#assign categoryName = (categories?? && categories?has_content && categories[0].getVocabularyId()?number == parentVocId)?then(categories[0].getName(), "") />
            
            <div class="col-xs-12 col-md-4" data-category-id="${categoryName}">
                <div class="item-card">
                    <div class="item-card__image">
                        <div class="item-card__image-background" style="background-image: url(${defaultImageURL})"></div>
                    </div>
                    <div class="item-card__info">
                        <div class="item-card__features">
                            <span class="item-card__category">${dateUtil.getDate(entry.getCreateDate(), dateFormat, locale)}</span>
                        </div>
                        <h4 class="item-card__title">${entryTitle}</h4>
                        <a class="download-button-link" target="_blank" href="${downloadURL}">
                            <span class="download-button-link__label">Download</span>
                        </a>
                    </div>
                </div>
            </div>
        </#list>
    <#else>
        <span class="b-no-results">Keine Dokumente gefunden.</span>
    </#if>
    </div>
    <div class="pagination-container text-center mt-4">
        <ul class="pagination" id="pagination"></ul>
    </div>
</div>

<script>
(function() {
    var categoryFilter = document.getElementById('categoryFilter');
    var cards = document.querySelectorAll('[data-category-id]');
    var itemsPerPage = 6;
    var currentPage = 1;
    
    function filterAndPaginate() {
        var selectedCategory = categoryFilter.value;
        var visibleCards = Array.from(cards).filter(function(card) {
            if (selectedCategory === 'all' || card.dataset.categoryId === selectedCategory) {
                card.classList.add('fade-out');
                return true;
            }
            return false;
        });
        
        setTimeout(function() {
            var totalPages = Math.ceil(visibleCards.length / itemsPerPage);
            updatePagination(totalPages);
            
            var startIndex = (currentPage - 1) * itemsPerPage;
            var endIndex = startIndex + itemsPerPage;
            
            cards.forEach(function(card) {
                card.style.display = 'none';
            });
            
            visibleCards.slice(startIndex, endIndex).forEach(function(card) {
                card.style.display = '';
                setTimeout(function() {
                    card.classList.remove('fade-out');
                    card.classList.add('fade-in');
                }, 50);
            });
        }, 200);
    }
    function updatePagination(totalPages) {
        var paginationEl = document.getElementById('pagination');
        var html = '';
        
        for (var i = 1; i <= totalPages; i++) {
            html += '<li class="' + (currentPage === i ? 'active' : '') + '">' +
                   '<a onclick="changePage(' + i + ')">' + i + '</a>' +
                   '</li>';
        }
        
        paginationEl.innerHTML = html;
    }
    
    window.changePage = function(page) {
        currentPage = page;
        filterAndPaginate();
    };
    
    categoryFilter.addEventListener('change', function() {
        currentPage = 1;
        filterAndPaginate();
    });
    
    filterAndPaginate();
})();
</script>