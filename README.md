# Personal Log

This is an app I made for myself. I had a minor health issue and started journaling to keep track of my thoughts through the process of healing.  I was using the Notes app on my iPhone, but I quickly found that it got unwieldy to keep one very long text note.

This app lets you journal by adding distinct chunks of text that are automatically timestamped. It lets you record your mood via an emoji, offers writing prompts if you're not sure what to write about, presents the entries in chronological order, and lets you easily search all entries or jump to a specific day.

## Architecture

### User Interface
The UI is a mixture of UIKit and SwiftUI using MVVM, all done without a storyboard.

I chose to use UITableViewController for the list because I find its datasource approach to be less resource-intensive for a use case like this where there's potentially an enormous amount of data but only a little will be on the screen at a time. Given that I store each journal entry in a separate file, this makes for pretty quick scrolling and keeps just a few entries in memoory at a time. The table cells are SwiftUI views implemented with UIHostingConfiguration. For an updating strategy, I stuck with simple reloadData() calls.

All other views are implemented in SwiftUI, using view models when necessary. I've found it easiest to define view models within the view that they are meant to service.

### Model Layer
The model layer stores each entry as an individual json file named with its creation date as a Double. Only the names are loaded at startup and the created date is used as an opaque identifier for the entry until its content is needed. The layer is made up of:

    * JournalArchive: maintains the files for the entries
    * SearchArchive: maintains a search index matching words to the entries where they can be found
    * Journal: acts as an interface for the model layer, loading entries from the archiver, converting them to view models, filtering results based on the search string, passing on CRUD operations to the archiver and indexer
    
### Controller Layer
The TopViewController is loaded at startup by the SceneDelegate. It maintains a layout composed of 3 smaller view controllers. Only the list of entries is implemented as a classic UIKit view controller.  The others are UIHostingControllers.



#####################################
## Design
The design is meant to be immediately intuitible and focused on the user's need at the time. Most quickly-accessed functions are accessible from the bottom of the screen, while less   

On first launch, the most prominent UI element is the button to create a new entry:

  
######################################