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
def tagStats = [:]
def articlesWithTags = 0
def articlesWithoutTags = 0
def articleTagDetails = []

if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}"
    return
}

println "🏷️  Analyzing tags for: ${countryToProcess}"
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
        tags: []
    ]
    
    if (assetEntry != null) {
        def tags = assetEntry.getTags().collect { it.getName() }
        articleData.tags = tags
        
        if (tags.size() > 0) {
            articlesWithTags++
            tags.each { tagName ->
                tagStats[tagName] = (tagStats[tagName] ?: 0) + 1
            }
        } else {
            articlesWithoutTags++
        }
    } else {
        articlesWithoutTags++
    }
    
    articleTagDetails.add(articleData)
}

println "🏷️  TAG ANALYSIS RESULTS"
println "=" * 60
println "📈 Total Articles Analyzed: ${articles.size()}"
println "✅ Articles with Tags: ${articlesWithTags}"
println "❌ Articles without Tags: ${articlesWithoutTags}"
println "🏷️  Total Unique Tags Found: ${tagStats.size()}"

if (tagStats.size() > 0) {
    println "\n🔥 TAG USAGE STATISTICS"
    println "=" * 60
    
    def sortedTags = tagStats.sort { -it.value }
    
    sortedTags.each { tagName, count ->
        def percentage = Math.round((count / articles.size()) * 100)
        println sprintf("%-30s | %3d articles", tagName, count)
    }

    println "\n📋 DETAILED ARTICLE-TAG MAPPING"
    println "=" * 60
    articleTagDetails.findAll { it.tags.size() > 0 }.each { article ->
        println "📄 ${article.articleId} - ${article.title}"
        println "   🏷️  Tags: ${article.tags.join(', ')}"
        println ""
    }
   
} else {
    println "\n⚠️  NO TAGS FOUND"
    println "All articles are untagged or have no asset entries."
}

println "\n✅ Tag analysis completed!"
println "=" * 60