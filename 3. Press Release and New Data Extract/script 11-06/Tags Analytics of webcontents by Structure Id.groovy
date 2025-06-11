import com.liferay.journal.service.JournalArticleLocalServiceUtil
import com.liferay.journal.model.JournalArticle
import com.liferay.asset.kernel.service.AssetEntryLocalServiceUtil

// ===== CONFIGURATION =====
def countryToProcess = "United Kingdom"

def configurations = [
    "United Kingdom": [
        country: "United Kingdom", 
        groupId: 45807659, 
        structureKey: "169349", 
        localeId: "en_GB"
    ]
]

// ===== VARIABLES =====
def currentConfig = configurations[countryToProcess]
def tagStats = [:]
def articlesWithTags = 0
def articlesWithoutTags = 0
def articleTagDetails = []

// ===== VALIDATION =====
if (currentConfig == null) {
    println "Error: Configuration not found for country '${countryToProcess}'"
    println "Available countries: ${configurations.keySet()}"
    return
}

println "🏷️  Analyzing tags for: ${countryToProcess}"
println "📊 Group ID: ${currentConfig.groupId}"
println "🏗️  Structure Key: ${currentConfig.structureKey}"
println "=" * 60

// ===== GET ARTICLES =====
def articles = JournalArticleLocalServiceUtil.getArticlesByStructureId(
    currentConfig.groupId, 
    currentConfig.structureKey, 
    -1, -1, null
)

println "📄 Found ${articles.size()} articles to analyze\n"

// ===== ANALYZE TAGS =====
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

// ===== DISPLAY RESULTS =====
println "🏷️  TAG ANALYSIS RESULTS"
println "=" * 60
println "📈 Total Articles Analyzed: ${articles.size()}"
println "✅ Articles with Tags: ${articlesWithTags}"
println "❌ Articles without Tags: ${articlesWithoutTags}"
println "🏷️  Total Unique Tags Found: ${tagStats.size()}"

if (tagStats.size() > 0) {
    println "\n🔥 TAG USAGE STATISTICS"
    println "=" * 60
    
    // Sort tags by usage count (descending)
    def sortedTags = tagStats.sort { -it.value }
    
    sortedTags.each { tagName, count ->
        def percentage = Math.round((count / articles.size()) * 100)
        println sprintf("%-30s | %3d articles (%2d%%)", tagName, count, percentage)
    }
    
    println "\n🏆 TOP 10 MOST USED TAGS"
    println "=" * 60
    sortedTags.take(10).eachWithIndex { entry, index ->
        println "${index + 1}. ${entry.key} - ${entry.value} articles"
    }
    

    // Show tag distribution stats
    println "\n📊 TAG DISTRIBUTION ANALYSIS"
    println "=" * 60
    def tagCountDistribution = [:]
    articleTagDetails.each { article ->
        def tagCount = article.tags.size()
        def key = tagCount == 0 ? "0 tags" : 
                 tagCount == 1 ? "1 tag" : 
                 "${tagCount} tags"
        tagCountDistribution[key] = (tagCountDistribution[key] ?: 0) + 1
    }
    
    tagCountDistribution.sort { it.key }.each { tagCount, articleCount ->
        def percentage = Math.round((articleCount / articles.size()) * 100)
        println "📊 ${tagCount}: ${articleCount} articles (${percentage}%)"
    }
    
    println "\n📋 DETAILED ARTICLE-TAG MAPPING"
    println "=" * 60
    articleTagDetails.findAll { it.tags.size() > 0 }.each { article ->
        println "📄 ${article.articleId} - ${article.title}"
        println "   🏷️  Tags: ${article.tags.join(', ')}"
        println ""
    }
    
    // Show alphabetical tag list
    println "\n📝 ALL TAGS (ALPHABETICAL)"
    println "=" * 60
    def alphabeticalTags = tagStats.keySet().sort()
    alphabeticalTags.eachWithIndex { tag, index ->
        if (index % 4 == 0) print "\n"
        print sprintf("%-20s", tag)
    }
    println "\n"
    
} else {
    println "\n⚠️  NO TAGS FOUND"
    println "All articles are untagged or have no asset entries."
}

println "\n✅ Tag analysis completed!"
println "=" * 60

/*

🏷️  Analyzing tags for: United Kingdom
📊 Group ID: 45807659
🏗️  Structure Key: 169349
============================================================
📄 Found 1185 articles to analyze

🏷️  TAG ANALYSIS RESULTS
============================================================
📈 Total Articles Analyzed: 1185
✅ Articles with Tags: 79
❌ Articles without Tags: 1106
🏷️  Total Unique Tags Found: 23

🔥 TAG USAGE STATISTICS
============================================================
lendahand                      |  47 articles ( 4%)
moreton valance                |   3 articles ( 0%)
driffield                      |   3 articles ( 0%)
bristol                        |   3 articles ( 0%)
scarborough                    |   3 articles ( 0%)
pershore                       |   2 articles ( 0%)
york                           |   2 articles ( 0%)
eversley                       |   1 articles ( 0%)
sheffield                      |   1 articles ( 0%)
immingham                      |   1 articles ( 0%)
gorton                         |   1 articles ( 0%)
cardiff                        |   1 articles ( 0%)
swindon                        |   1 articles ( 0%)
tinto                          |   1 articles ( 0%)
stepney                        |   1 articles ( 0%)
northfleet                     |   1 articles ( 0%)
newton aycliffe                |   1 articles ( 0%)
luton                          |   1 articles ( 0%)
basingstoke                    |   1 articles ( 0%)
southampton                    |   1 articles ( 0%)
totton                         |   1 articles ( 0%)
malton                         |   1 articles ( 0%)
press                          |   1 articles ( 0%)

🏆 TOP 10 MOST USED TAGS
============================================================
1. lendahand - 47 articles
2. moreton valance - 3 articles
3. driffield - 3 articles
4. bristol - 3 articles
5. scarborough - 3 articles
6. pershore - 2 articles
7. york - 2 articles
8. eversley - 1 articles
9. sheffield - 1 articles
10. immingham - 1 articles

📊 TAG DISTRIBUTION ANALYSIS
============================================================
📊 0 tags: 1106 articles (93%)
📊 1 tag: 79 articles (7%)

📋 DETAILED ARTICLE-TAG MAPPING
============================================================
📄 46476120 - BSO team lend a sandy hand…
   🏷️  Tags: lendahand

📄 46565364 - Porofoam Foamed Concrete in Stonehouse Provided as an Infill
   🏷️  Tags: moreton valance

📄 47688476 - Cemex Permatite- watertight concrete system supplied in Hook
   🏷️  Tags: eversley

📄 45854133 - Sooty Box Volunteers
   🏷️  Tags: lendahand

📄 45854217 - Dignity Day to help those with Dementia
   🏷️  Tags: lendahand

📄 45854126 - Northfleet Block Blokes Lend a Hand
   🏷️  Tags: lendahand

📄 45854189 - Five Lend-A-Hand At Monks Kirby Church Graveyard
   🏷️  Tags: lendahand

📄 45854301 - Leith Team Lends a Hand at Local Rugby Club
   🏷️  Tags: lendahand

📄 45854315 - Preston Brook Planners Lend-a-Hand in Runcorn
   🏷️  Tags: lendahand

📄 45854322 - North West team Lends a Hand at Morecambe Allotments
   🏷️  Tags: lendahand

📄 45854329 - Beach Clean Up Lend-a-Hand in Norfolk
   🏷️  Tags: lendahand

📄 45854357 - Bulk Planners Lend-A-Hand
   🏷️  Tags: lendahand

📄 45854371 - Operation Christmas Child Lend-a-Hand
   🏷️  Tags: lendahand

📄 45854609 - Proudly Lending a Hand at Darwen
   🏷️  Tags: lendahand

📄 45854651 - Planning Team Lendahand at Crick Woodlands
   🏷️  Tags: lendahand

📄 45854637 - Greg and His Sales Team Lendahand to Primary School
   🏷️  Tags: lendahand

📄 45854658 - Leyburn and Pallett Hill Task Force Lendahand
   🏷️  Tags: lendahand

📄 46009430 - Asphalt Litter-Pickers Lend a Hand near Barnsley
   🏷️  Tags: lendahand

📄 46009507 - Middleton Quarry Team Lend a Walking Hand
   🏷️  Tags: lendahand

📄 46009542 - Packed and Concrete Products Team Lend a Helping Hand at RSPCA Coventry
   🏷️  Tags: lendahand

📄 46053547 - Lendahand in Birmingham for the Stroke Association
   🏷️  Tags: lendahand

📄 46053533 - Hallkyn Bowled Over
   🏷️  Tags: lendahand

📄 46090855 - Local Team Lends a Hand at Middleton on the Wolds
   🏷️  Tags: lendahand

📄 46139469 - Beam & block floor systems benefit house builds in Driffield
   🏷️  Tags: driffield

📄 46158120 - Promptis Fast Setting Concrete Supplied to Kent Worx in Driffield
   🏷️  Tags: driffield

📄 46161096 - Denge Lend-A-Hand At RNLI
   🏷️  Tags: lendahand

📄 46212310 - Collessie Quarry Team Lends A ‘Seaside’ Hand
   🏷️  Tags: lendahand

📄 46243343 - Porofoam Foamed Concrete Supplied For Sheffield Student Accomodation
   🏷️  Tags: sheffield

📄 46358477 - Taffs Well team Lend a Hand with local school
   🏷️  Tags: lendahand

📄 46359194 - Roller Compacted Concrete Supplied in Killingholme for BMW Car Storage Area
   🏷️  Tags: immingham

📄 46243830 - Porofoam Foamed Concrete Supplied in Ashton Under Lyne Bridge Replacement
   🏷️  Tags: gorton

📄 46359832 - Somercotes Team goes back to school
   🏷️  Tags: lendahand

📄 46393093 - Supply Chain and Logistics Lendahand at White Lodge Centre
   🏷️  Tags: lendahand

📄 46393119 - Cambusmore team gets down at Doune
   🏷️  Tags: lendahand

📄 46453519 - Scarborough Lend-A-Hand
   🏷️  Tags: lendahand

📄 46461789 - Cowieslinn Lend a Festival Hand
   🏷️  Tags: lendahand

📄 46543766 - South Ferriby Team Lends a hand
   🏷️  Tags: lendahand

📄 46476159 - Bridlington - Pump Readymix Concrete Supplied For Gypsey Park Regeneration Scheme
   🏷️  Tags: driffield

📄 46565038 - Slipform Concrete In Cardiff Supplied for Project in City Centre
   🏷️  Tags: cardiff

📄 46565269 - Concrete in Tetbury & Witcombe Provided for Housing Development
   🏷️  Tags: moreton valance

📄 46565320 - Waterproof Concrete in Stonehouse Gloucestershire Provided for a Waste Processing Site
   🏷️  Tags: moreton valance

📄 46683372 - “Doune Your Way” for a Lend a Hand
   🏷️  Tags: lendahand

📄 46705888 - Foamed Concrete in Pershore Supplied for Arch Infill
   🏷️  Tags: pershore

📄 46706002 - Foamed Concrete in Pershore Supplied for Arch Infill
   🏷️  Tags: pershore

📄 46706081 - Foamed Concrete in Marlborough Supplied for Low Density, Technical Fill
   🏷️  Tags: swindon

📄 46706189 - Foamed Concrete in Kirkfieldbank supplied for void fill
   🏷️  Tags: tinto

📄 46706332 - Foamed Concrete in Barking Supplied for TBM Extraction
   🏷️  Tags: stepney

📄 46706392 - Foamed Concrete in Bristol Supplied for Nightclub Basement Infill
   🏷️  Tags: bristol

📄 46737211 - Washwood Heath Rail Team Lend-A-Hand At Local Nursery
   🏷️  Tags: lendahand

📄 46737225 - A Different Kind Of Step Challenge For Somercotes Rail Solutions Teams
   🏷️  Tags: lendahand

📄 46824192 - Willington Quarry Team Work With Parish Volunteers On Footpath Lend-A-Hand
   🏷️  Tags: lendahand

📄 46824425 - South Coast Readymix Team Lend-A-Hand At Hove Hospice
   🏷️  Tags: lendahand

📄 46873428 - Lend a scouting hand
   🏷️  Tags: lendahand

📄 46946961 - Foamed Concrete Supplied in Maidstone for Sink Hole Fill
   🏷️  Tags: northfleet

📄 47036690 - Dying to Help Out
   🏷️  Tags: lendahand

📄 47076128 - Lend A Paw Day near Rugby
   🏷️  Tags: lendahand

📄 47130339 - Lending a Sporting Hand in Prestwich
   🏷️  Tags: lendahand

📄 47168407 - Keeping Healthy and Lending a Hand Too
   🏷️  Tags: lendahand

📄 47197123 - Readymix Concrete Hungate York Supplied For Area Development Project
   🏷️  Tags: york

📄 47253325 - Northwest Readymix Team Lend a Leafy Hand at Hospice
   🏷️  Tags: lendahand

📄 47310844 - Lendahand Days are Good for Our Mental Health
   🏷️  Tags: lendahand

📄 47484261 - Bulk Cement Planning Team Lend a Hand
   🏷️  Tags: lendahand

📄 47568260 - Lowest density Porofoam ever supplied
   🏷️  Tags: bristol

📄 47620375 - Concrete in Darlington Provided for New Aldi Store
   🏷️  Tags: newton aycliffe

📄 47685336 - Concrete Supplied to Luton Dart Project
   🏷️  Tags: luton

📄 47688404 - Beam & block floor systems benefit house builds in Basingstoke
   🏷️  Tags: basingstoke

📄 47689052 - Readymix Concrete Supplied for Southampton Solent University Sports Centre
   🏷️  Tags: southampton

📄 47689335 - Early Strength Screed Supplied for Southampton Solent University Sports Centre
   🏷️  Tags: totton

📄 47811632 - Flowing Screed In Scarborough Supplied For New Build
   🏷️  Tags: scarborough

📄 47811699 - Concrete supplied In Kirby Misperton For Flamingo Land
   🏷️  Tags: malton

📄 47812194 - Hatfield Quarry Lend-A-Hand
   🏷️  Tags: lendahand

📄 47880509 - Advanced Concrete Scarborough Supplied To Brambles Construction
   🏷️  Tags: scarborough

📄 47887107 - Concrete In Bristol Supplied For New Wind Turbine
   🏷️  Tags: bristol

📄 47913556 - Self Levelling Screed Supplied In Kelfield York
   🏷️  Tags: york

📄 48105523 - Farmpave Concrete In Ganton Supplied To Dairy Farm
   🏷️  Tags: scarborough

📄 48121560 - CEMEX and GB Railfreight Launch New Branded Locomotive at Official Naming Ceremony
   🏷️  Tags: press

📄 48274224 - Rugby Plant Lend a Hand at Local School
   🏷️  Tags: lendahand

📄 48541836 - Dove Holes Supports Whaley Dam Efforts
   🏷️  Tags: lendahand

📄 49529512 - Readymix Midlands Team Lend-A-Hand
   🏷️  Tags: lendahand


📝 ALL TAGS (ALPHABETICAL)
============================================================

basingstoke         bristol             cardiff             driffield           
eversley            gorton              immingham           lendahand           
luton               malton              moreton valance     newton aycliffe     
northfleet          pershore            press               scarborough         
sheffield           southampton         stepney             swindon             
tinto               totton              york                


✅ Tag analysis completed!
============================================================


*/