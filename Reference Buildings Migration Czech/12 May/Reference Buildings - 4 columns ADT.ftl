Reference Buildings - 4 columns

<#assign seeMoreButtonLabel = "Více" />
<#-- labels of buttons are taken from liferay laguage translations -->

<style>
    @media screen and (min-width: 620px) {
        .b-item-card {
        max-width: 50%;
        }
    }

    @media screen and (min-width: 920px) {
        .b-item-card {
        max-width: 33.33%;
        }
    }

    @media screen and (min-width: 1220px) {
        .b-item-card {
        max-width: 25%;
        }
    }

    .b-card-row {
        display: flex;
        flex-wrap: wrap;
    }

    .b-topbottomgap {
        margin-top: 40px;
        margin-bottom: 40px;
    }

    .b-communicated {
        margin-left: -15px;
        margin-right: -15px;
    }

    .b-item-card {
        display: flex;
        margin-bottom: -1px;
        border: 1px solid #ccc;
        border-left: 0;
        padding: 40px;
        min-width: 300px;
        width:100%;
        flex-direction: column;
    }

    .b-item-card .b-item-card__image {
        height: 180px;
    }

    .b-item-card .b-item-card__image .b-item-card__image-background {
        width: 100%;
        height: 100%;
        position: relative;
        background-repeat: no-repeat;
        background-position: center;
        background-size: cover;
        background-color: lightgray;
    }

    .b-item-card .b-item-card__info {
        padding-top: 20px;
    }

    .b-item-card__summary {
        font-size: 16px;
        line-height: 1.5;
        text-align: left;
        padding-top: 10px;
        overflow: hidden;
        margin-bottom: 20px;
        padding-bottom: 0 !important;
    }

    .b-ng-button-link {
        display: inline-block;
        border: 1px solid #000;
        color: #000;
        padding: 15px 36px;
        line-height: 1px;
    }

    .b-ng-button-link .b-ng-button-link__label {
        font-size: 10px;
        font-weight: 900;
        letter-spacing: 2px;
        text-align: center;
        text-transform: uppercase;
    }

    .b-item-card__info h4 {
        font-size: 16px;
        padding-top: 10px;
        overflow: hidden;
        width: 100%;
    }

</style>

<#if entries?has_content>
    <div class="b-communicated b-topbottomgap">
        <div class="container-fluid">
            <div class="row b-card-row">
            <#-- start item loop -->
            <#list entries as cur_entry>
                <#assign renderer = cur_entry.getAssetRenderer()>
                <#assign className = renderer.getClassName() >
                <#assign classPK = renderer.getClassPK() >

                <#if className == "com.liferay.journal.model.JournalArticle" >
                    <#assign journalArticle = renderer.getArticle() >
                    <#assign document = saxReaderUtil.read(journalArticle.getContentByLocale(locale)) >
                    <@printCard document cur_entry/>
                </#if>

            </#list>
            <#-- end item loop -->
            </div>
        </div>
    </div>
</#if>

<#-- start macro -->

<#macro printCard document entry>

<#assign entryViewURL = assetPublisherHelper.getAssetViewURL(renderRequest, renderResponse, entry, true)/>
<#assign entryTitle = document.valueOf("//dynamic-element[@name='Title']")?trim />
<#assign entryDescription = document.valueOf("//dynamic-element[@name='Description']")?trim />
<#assign entryCreationDate = document.valueOf("//dynamic-element[@name='CreationDate']")?trim />

<#assign entryMainImageURL=document.valueOf("//dynamic-element[@name='MainImageURL']")?trim/>

<#if entryDescription?length gt 300>
    <#assign entryDescription = entryDescription?substring(0,300)?keep_before_last(" ") + "...">
</#if>

<#-- start item html -->
<div class="b-item-card">
        <div class="b-item-card__image">
            <div class="b-item-card__image-background" style='background-image: url("${entryMainImageURL}");'></div>
        </div>
    <div class="b-item-card__info">
            <h3 class="b-item-card__title">${entryTitle}</h3>
            <#if entryCreationDate !="">
                <span class="b-item-card__publish-date"><@getPublishedDate entryCreationDate /></span>
            </#if>
            <p class="b-item-card__summary">${entryDescription}</p>
            <a class="b-ng-button-link" href="${entryViewURL?keep_before('?')}">
                <span class="b-ng-button-link__label">${seeMoreButtonLabel}</span>
            </a>
    </div>
</div>
<#-- end item html -->

</#macro>

<#macro getPublishedDate publishedDate>
    <#assign dateUtil = staticUtil["com.liferay.portal.kernel.util.DateUtil"] />
    <#assign formatedPublishedDate = dateUtil.parseDate("yyyy-MM-dd", publishedDate?trim, locale)>
    <#assign originalLocale = locale>
    <#setting locale = originalLocale>
        ${formatedPublishedDate?string("d. MMMM, yyyy")}
    <#setting locale = originalLocale>
</#macro>

<#-- end macro -->