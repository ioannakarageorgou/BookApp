import Testing
@testable import BookApp

@Suite
struct LoadingTests {
    @Test
    func loadedExposesValue() {
        let loading = Loading<Int>.loaded(42)

        #expect(loading.value == 42)
        #expect(!loading.isLoading)
        #expect(loading.errorMessage == nil)
    }

    @Test
    func loadingIsLoading() {
        let loading = Loading<Int>.loading

        #expect(loading.value == nil)
        #expect(loading.isLoading)
        #expect(loading.errorMessage == nil)
    }

    @Test
    func errorExposesMessage() {
        let loading = Loading<Int>.error("Offline")

        #expect(loading.value == nil)
        #expect(!loading.isLoading)
        #expect(loading.errorMessage == "Offline")
    }

    @Test
    func idleExposesNothing() {
        let loading = Loading<Int>.idle

        #expect(loading.value == nil)
        #expect(!loading.isLoading)
        #expect(loading.errorMessage == nil)
    }
}
