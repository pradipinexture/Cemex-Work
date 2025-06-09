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
</style>

<div class="container">
    <div class="row">
    <#if entries?has_content>
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
            <#assign fileVersion = fileEntry.getLatestFileVersion() />
            <#assign downloadURL = themeDisplay.getPortalURL() + themeDisplay.getPathContext() + "/documents/" + fileEntry.getGroupId() + StringPool.SLASH + fileEntry.getFolderId() + StringPool.SLASH + HttpUtil.encodeURL(HtmlUtil.unescape(fileEntry.getTitle())) + StringPool.SLASH + fileEntry.getUuid() + "?version=" + fileVersion.getVersion() />
            <div class="col-xs-12 col-md-4">
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
</div>