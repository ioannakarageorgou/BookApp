import FavoritesClient
import Models
import RealmSwift

extension FavoritesClient {
    /// Realm implementation. Each call opens the Realm described by `configuration`.
    ///
    /// The closures are deliberately synchronous: inside an `async` closure, `Realm(configuration:)`
    /// would resolve to Realm's async initializer, which runs on the main actor.
    public static func live(configuration: Realm.Configuration = .defaultConfiguration) -> FavoritesClient {
        FavoritesClient(
            favorites: {
                let realm = try Realm(configuration: configuration)
                return realm.objects(BookObject.self).map(Book.init(object:))
            },
            isFavorite: { id in
                do {
                    let realm = try Realm(configuration: configuration)
                    return realm.object(ofType: BookObject.self, forPrimaryKey: id) != nil
                } catch {
                    print("Realm error when checking favorite: \(error)")
                    return false
                }
            },
            add: { book in
                let realm = try Realm(configuration: configuration)
                try realm.write {
                    realm.add(BookObject(book: book), update: .modified)
                }
            },
            remove: { id in
                let realm = try Realm(configuration: configuration)
                guard let object = realm.object(ofType: BookObject.self, forPrimaryKey: id) else { return }
                try realm.write {
                    realm.delete(object)
                }
            }
        )
    }
}
