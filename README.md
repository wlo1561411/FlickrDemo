# FlickrDemo

本App是透過Flickr API來做的一個簡單Demo，內容實現無限加載CollectionView, CoreData本地儲存。

# ViewControllers 

SearchViewController : 
處理Textfeilds的狀態，檢查是否有輸入正確數值。
當搜尋名稱與顯示數量輸入正確時，才能按下搜尋按鈕。

ResultViewController :
透過prepareForSegue，拿到前一頁的搜尋名稱與顯示數量，並呼叫WebService執行搜尋。
此WebService為獨立擁有，並不會與Photo Model裡的做衝突。

FavoritePhotoViewController :
透過PhotoCoreDataHelper，取到CoreData裡所儲存的資料。

# Cell

PhotoCollectionViewCell : 
依據是Search或是Favorite去做變化，addBtn的動作為呼叫PhotoCoreDataHelper去做儲存的動作。

# Models

Photo :
儲存從Flickr下載下來的資料，並Init ImgDownloadTask，準備處理下載的行為。

ImgDownloadTask : 
儲存Photo的URL、下載完的圖片、欲更新的Row Number。
每個ImgDownloadTask都會擁有一個獨立的WebService，用來處理下載事宜。
startDownloadImg() 裡會透過ImgDownloadDelegate 實現下載完更新Cell。

ImgDownloadDelegate :
updateLoadedImg(indexRow:Int) 遵從Delegate的View，必須透過此Fucntion來更新Cell。

# Functions

WebService : 
網路層的封裝，處理下載的任務，isDownloading, isFinish為Flag，用來判斷是否下載完成。

PhotoCoreDataHelper : 
處理CoreData的封裝，新增、刪除、取得。
