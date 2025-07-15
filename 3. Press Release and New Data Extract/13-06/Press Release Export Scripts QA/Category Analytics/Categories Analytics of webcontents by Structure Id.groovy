import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.journal.model.JournalArticle
import com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil

def countryToProcess = "United Kingdom"

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659, 
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

def currentConfig = configurations[countryToProcess]
def categoryStats = [:]
def articlesWithCategories = 0
def articlesWithoutCategories = 0
def articleCategoryDetails = []

if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}"
    return
}

println "🔍 Analyzing categories for: ${countryToProcess}"
println "📊 Group ID: ${currentConfig.groupId}"
println "🏗️  Structure Key: ${currentConfig.structureKey}"
println "=" * 60

def articles = JournalArticleLocalServiceUtil.getArticlesByStructureId(
    currentConfig.groupId, 
    currentConfig.structureKey, 
    -1, -1, null
)

println "📄 Found ${articles.size()} articles to analyze\n"

articles.each { article ->
    def assetEntry = AssetEntryLocalServiceUtil.fetchEntry(
        JournalArticle.class.name, 
        article.resourcePrimKey
    )
    
    def articleData = [
        articleId: article.getArticleId(),
        title: article.getTitle(currentConfig.localeId),
        categories: []
    ]
    
    if (assetEntry != null) {
        def categories = assetEntry.getCategories().collect { it.getName() }
        articleData.categories = categories
        
        if (categories.size() > 0) {
            articlesWithCategories++
            categories.each { categoryName ->
                categoryStats[categoryName] = (categoryStats[categoryName] ?: 0) + 1
            }
        } else {
            articlesWithoutCategories++
        }
    } else {
        articlesWithoutCategories++
    }
    
    articleCategoryDetails.add(articleData)
}

println "📊 CATEGORY ANALYSIS RESULTS"
println "=" * 60
println "📈 Total Articles Analyzed: ${articles.size()}"
println "✅ Articles with Categories: ${articlesWithCategories}"
println "❌ Articles without Categories: ${articlesWithoutCategories}"
println "🏷️  Total Unique Categories Found: ${categoryStats.size()}"

if (categoryStats.size() > 0) {
    println "\n🔥 CATEGORY USAGE STATISTICS"
    println "=" * 60
    
    def sortedCategories = categoryStats.sort { -it.value }
    
    sortedCategories.each { categoryName, count ->
        def percentage = Math.round((count / articles.size()) * 100)
        println sprintf("%-30s | %3d articles", categoryName, count)
    }

    println "\n📋 DETAILED ARTICLE-CATEGORY MAPPING"
    println "=" * 60
    articleCategoryDetails.findAll { it.categories.size() > 0 }.each { article ->
        println "📄 ${article.articleId} - ${article.title}"
        println "   🏷️  Categories: ${article.categories.join(', ')}"
        println ""
    }
    
} 
// else {
//     println "\n⚠️  NO CATEGORIES FOUND"
//     println "All articles are uncategorized or have no asset entries."
// }

println "\n✅ Category analysis completed!"
println "=" * 60