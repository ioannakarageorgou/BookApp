import RealmSwift

class BookObject: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var title: String = ""
    @Persisted var subtitle: String? = nil
    @Persisted var thumbnailURL: String? = nil
}
