const productParentCatId = 41361;
const productTypeVocId = 41357;
let productTypeCategories = [];

async function getAllProductCategories() {
    try {
        const response = await new Promise((resolve, reject) => {
            Liferay.Service(
                '/assetcategory/get-vocabulary-categories',
                {
                    parentCategoryId: productParentCatId,
                    vocabularyId: productTypeVocId,
                    start: -1,
                    end: -1,
                    "-orderByComparator": ""
                },
                (result) => resolve(result),
                (error) => reject(error)
            );
        });
        productTypeCategories = response;
        return response;
    } catch (error) {
        console.error("Error updating product dropdown options:", error);
        throw error;
    }
}

async function findCategoryId(productName) {
    try {
        const category = productTypeCategories.find(
            cat => cat.titleCurrentValue.toLowerCase() === productName.toLowerCase()
        );
        return category ? category.categoryId : null;
    } catch (error) {
        console.error("Error finding category:", error);
        throw error;
    }
}

async function getCategoryIdByName(productName) {
    try {
        if (!productTypeCategories || productTypeCategories.length === 0) {
            await getAllProductCategories();
        }

        const categoryId = await findCategoryId(productName);
        return categoryId;
    } catch (error) {
        console.error("Error getting category ID by name:", error);
        throw error;
    }
}

(async () => {
    try {
        await getAllProductCategories();
        console.log("Initial categories loaded successfully");
    } catch (error) {
        console.error("Error in initial categories load:", error);
    }
})();


const categoryId = await getCategoryIdByName("Screed");