import Foundation

public extension Book {
    static let fixture = Book(
        id: "1",
        title: "Test Driven Development",
        subtitle: "By Example",
        thumbnailURL: URL(string: "https://picsum.photos/50/75")
    )

    static let fixtures: [Book] = [
        fixture,
        Book(
            id: "2",
            title: "Mastering SwiftUI",
            subtitle: "UI the Apple Way",
            thumbnailURL: URL(string: "https://picsum.photos/50/71")
        ),
        Book(
            id: "3",
            title: "Clean Code",
            subtitle: "A Handbook of Agile Software Craftsmanship",
            thumbnailURL: URL(string: "https://picsum.photos/40/71")
        ),
        Book(
            id: "4",
            title: "Using Combine",
            subtitle: "Modern Swift APIs for Reactive Programming",
            thumbnailURL: URL(string: "https://example.com/combine.jpg")
        ),
        Book(
            id: "5",
            title: "Design Patterns",
            subtitle: "Elements of Reusable Object-Oriented Software",
            thumbnailURL: URL(string: "https://picsum.photos/50/82")
        ),
        Book(
            id: "6",
            title: "Refactoring",
            subtitle: "Improving the Design of Existing Code",
            thumbnailURL: URL(string: "https://picsum.photos/50/10")
        ),
        Book(
            id: "7",
            title: "Domain-Driven Design",
            subtitle: "Tackling Complexity in the Heart of Software",
            thumbnailURL: URL(string: "https://example.com/ddd.jpg")
        ),
        Book(
            id: "8",
            title: "The Pragmatic Programmer",
            subtitle: "Your Journey to Mastery",
            thumbnailURL: URL(string: "https://picsum.photos/70/75")
        )
    ]
}
